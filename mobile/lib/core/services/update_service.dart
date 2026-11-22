import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUpdateInfo {
  final String versionName;
  final int versionCode;
  final String downloadUrl;
  final String changelog;
  final bool isMandatory;
  final int sizeBytes;

  const AppUpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.downloadUrl,
    required this.changelog,
    this.isMandatory = false,
    this.sizeBytes = 0,
  });
}

class UpdateService {
  static const int currentVersionCode = 5;
  static const String currentVersionName = "1.0.1";
  static const MethodChannel _channel = MethodChannel("com.tkmingle.app/updater");

  /// Checks Supabase `app_releases` table first, with fallback to GitHub Releases API.
  static Future<AppUpdateInfo?> checkForUpdate() async {
    // 1. Try Supabase `app_releases` table if configured
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('app_releases')
          .select()
          .eq('platform', 'android')
          .order('version_code', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final remoteCode = response['version_code'] as int? ?? 0;
        if (remoteCode > currentVersionCode) {
          return AppUpdateInfo(
            versionName: response['version_name'] as String? ?? "v$remoteCode",
            versionCode: remoteCode,
            downloadUrl: response['download_url'] as String? ?? "",
            changelog: response['changelog'] as String? ?? "Performance updates and bug fixes.",
            isMandatory: response['is_mandatory'] as bool? ?? false,
          );
        }
      }
    } catch (e) {
      debugPrint("Notice: Supabase app_releases query error or not migrated: $e. Checking GitHub releases.");
    }

    // 2. Fallback to GitHub Releases API directly
    try {
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse("https://api.github.com/repos/creatorspara/tkmingle/releases/latest"),
      );
      request.headers.set("User-Agent", "TKMingle-Flutter-App");
      request.headers.set("Accept", "application/vnd.github.v3+json");

      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;

        final tagName = json['tag_name'] as String? ?? "";
        final releaseName = json['name'] as String? ?? tagName;
        final bodyNotes = json['body'] as String? ?? "";
        final assets = json['assets'] as List<dynamic>? ?? [];

        // Find APK asset
        String? apkDownloadUrl;
        int apkSize = 0;
        for (final a in assets) {
          final assetName = a['name'] as String? ?? "";
          if (assetName.endsWith(".apk")) {
            apkDownloadUrl = a['browser_download_url'] as String?;
            apkSize = a['size'] as int? ?? 0;
            if (assetName.contains("tkmmingle") || assetName.contains("release")) {
              break;
            }
          }
        }

        if (apkDownloadUrl != null) {
          // Parse version code or compare tag
          int remoteCode = _extractVersionCode(tagName, releaseName);
          if (remoteCode > currentVersionCode) {
            return AppUpdateInfo(
              versionName: releaseName,
              versionCode: remoteCode,
              downloadUrl: apkDownloadUrl,
              changelog: _cleanChangelog(bodyNotes),
              isMandatory: false,
              sizeBytes: apkSize,
            );
          }
        }
      }
    } catch (e) {
      debugPrint("GitHub release check error: $e");
    }

    return null;
  }

  /// Downloads the APK directly from GitHub or Supabase Storage and triggers Android Package Installer
  static Future<void> downloadAndInstall({
    required String downloadUrl,
    required void Function(double progress, int receivedBytes, int totalBytes) onProgress,
  }) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(downloadUrl));
    request.headers.set("User-Agent", "TKMingle-Flutter-App");

    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception("Failed to download update package: HTTP ${response.statusCode}");
    }

    final totalBytes = response.contentLength;
    final tempDir = await getTemporaryDirectory();
    final file = File("${tempDir.path}/tkmingle_update.apk");
    if (await file.exists()) {
      await file.delete();
    }

    final sink = file.openWrite();
    int receivedBytes = 0;

    await response.listen(
      (List<int> chunk) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        final progress = totalBytes > 0 ? (receivedBytes / totalBytes) : 0.0;
        onProgress(progress, receivedBytes, totalBytes);
      },
      onDone: () async {
        await sink.flush();
        await sink.close();
      },
      onError: (err) {
        sink.close();
        throw err;
      },
      cancelOnError: true,
    ).asFuture();

    // Trigger Native Android installation
    final bool success = await _channel.invokeMethod('installApk', {
      'filePath': file.path,
    }) as bool? ?? false;

    if (!success) {
      throw Exception("Could not trigger installation prompt on this device.");
    }
  }

  static int _extractVersionCode(String tag, String name) {
    // Try to extract from v1.0.1 (k1) or v1.0.1+5
    final match = RegExp(r'\+(\d+)').firstMatch(tag) ?? RegExp(r'\+(\d+)').firstMatch(name);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? currentVersionCode;
    }

    // Try semver: 1.0.1 -> major*1000 + minor*100 + patch
    final semver = RegExp(r'v?(\d+)\.(\d+)\.(\d+)').firstMatch(tag);
    if (semver != null) {
      final major = int.tryParse(semver.group(1)!) ?? 1;
      final minor = int.tryParse(semver.group(2)!) ?? 0;
      final patch = int.tryParse(semver.group(3)!) ?? 0;
      return (major * 100) + (minor * 10) + patch + 2; // e.g. 1.0.1 -> 100 + 0 + 1 + 2 = 103 (or higher)
    }

    return currentVersionCode;
  }

  static String _cleanChangelog(String rawNotes) {
    if (rawNotes.trim().isEmpty) {
      return "General performance improvements and bug fixes for campus students.";
    }
    // Limit to first 400 chars for clean dialog display
    if (rawNotes.length > 400) {
      return "${rawNotes.substring(0, 400).trim()}...";
    }
    return rawNotes.trim();
  }
}

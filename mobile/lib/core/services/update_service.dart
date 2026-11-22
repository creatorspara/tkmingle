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
  static const int currentVersionCode = 9;
  static const String currentVersionName = "1.0.5";
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
        final remoteName = response['version_name'] as String? ?? "v$remoteCode";
        if (remoteCode > currentVersionCode || _isRemoteNewer(remoteName, currentVersionName)) {
          return AppUpdateInfo(
            versionName: remoteName,
            versionCode: remoteCode,
            downloadUrl: response['download_url'] as String? ?? "",
            changelog: response['changelog'] as String? ?? "Performance updates and bug fixes.",
            isMandatory: response['is_mandatory'] as bool? ?? false,
          );
        } else {
          // Installed app is equal to or newer than Supabase registry
          debugPrint("TKMingle is up to date via Supabase registry (Installed: $currentVersionCode, Remote: $remoteCode)");
          return null;
        }
      }
    } catch (e) {
      debugPrint("Notice: Supabase app_releases query notice: $e. Checking GitHub releases.");
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
          // Strictly compare SemVer and Build Code to prevent update loops
          final isNewer = _isRemoteNewer(tagName, releaseName);
          if (isNewer) {
            return AppUpdateInfo(
              versionName: releaseName,
              versionCode: _extractVersionCode(tagName, releaseName),
              downloadUrl: apkDownloadUrl,
              changelog: _cleanChangelog(bodyNotes),
              isMandatory: false,
              sizeBytes: apkSize,
            );
          } else {
            debugPrint("TKMingle is up to date (Current: $currentVersionName, Remote: $tagName)");
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

  /// Validates whether the remote release is strictly strictly newer than currently installed
  static bool _isRemoteNewer(String remoteTag, String remoteName) {
    // 1. SemVer comparison: e.g. v1.0.2 vs v1.0.1
    final remoteMatch = RegExp(r'v?(\d+)\.(\d+)\.(\d+)').firstMatch(remoteTag) ??
        RegExp(r'v?(\d+)\.(\d+)\.(\d+)').firstMatch(remoteName);
    final currentMatch = RegExp(r'v?(\d+)\.(\d+)\.(\d+)').firstMatch(currentVersionName);

    if (remoteMatch != null && currentMatch != null) {
      final rMajor = int.parse(remoteMatch.group(1)!);
      final rMinor = int.parse(remoteMatch.group(2)!);
      final rPatch = int.parse(remoteMatch.group(3)!);

      final cMajor = int.parse(currentMatch.group(1)!);
      final cMinor = int.parse(currentMatch.group(2)!);
      final cPatch = int.parse(currentMatch.group(3)!);

      if (rMajor > cMajor) return true;
      if (rMajor < cMajor) return false;
      if (rMinor > cMinor) return true;
      if (rMinor < cMinor) return false;
      if (rPatch > cPatch) return true;
      if (rPatch < cPatch) return false;
    }

    // 2. Build / Version code suffix check (+6 > +5)
    final rCodeMatch = RegExp(r'\+(\d+)').firstMatch(remoteTag) ?? RegExp(r'\+(\d+)').firstMatch(remoteName);
    if (rCodeMatch != null) {
      final rCode = int.tryParse(rCodeMatch.group(1)!) ?? currentVersionCode;
      return rCode > currentVersionCode;
    }

    return false;
  }

  static int _extractVersionCode(String tag, String name) {
    final match = RegExp(r'\+(\d+)').firstMatch(tag) ?? RegExp(r'\+(\d+)').firstMatch(name);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? currentVersionCode;
    }

    final semver = RegExp(r'v?(\d+)\.(\d+)\.(\d+)').firstMatch(tag) ?? RegExp(r'v?(\d+)\.(\d+)\.(\d+)').firstMatch(name);
    if (semver != null) {
      final major = int.tryParse(semver.group(1)!) ?? 1;
      final minor = int.tryParse(semver.group(2)!) ?? 0;
      final patch = int.tryParse(semver.group(3)!) ?? 0;
      return (major * 100) + (minor * 10) + patch;
    }

    return currentVersionCode;
  }

  static String _cleanChangelog(String rawNotes) {
    if (rawNotes.trim().isEmpty) {
      return "General performance improvements and bug fixes for campus students.";
    }
    if (rawNotes.length > 400) {
      return "${rawNotes.substring(0, 400).trim()}...";
    }
    return rawNotes.trim();
  }
}

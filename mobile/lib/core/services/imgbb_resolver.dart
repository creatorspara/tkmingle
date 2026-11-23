import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart implementation of imgbb_direct_link.py
/// Converts ImgBB page links (e.g. https://ibb.co/GvsTj5Nn) into direct image URLs (e.g. https://i.ibb.co/...).
class ImgbbResolver {
  static const MethodChannel _channel = MethodChannel('com.tkmingle.app/updater');

  /// Opens an external URL (e.g. https://imgbb.com) in browser
  static Future<bool> openBrowser(String url) async {
    try {
      final res = await _channel.invokeMethod('openUrl', {'url': url}) as bool? ?? false;
      return res;
    } catch (e) {
      debugPrint('Error opening browser URL: $e');
      return false;
    }
  }
  /// Validates whether a URL belongs to the ImgBB domain
  static bool isImgbbHost(String rawUrl) {
    try {
      final uri = Uri.parse(rawUrl.trim());
      final host = uri.host.toLowerCase();
      return host == 'ibb.co' || host == 'www.ibb.co' || host == 'i.ibb.co';
    } catch (_) {
      return false;
    }
  }

  /// Checks if the link is already a direct image link (i.ibb.co)
  static bool isDirectImage(String rawUrl) {
    try {
      final uri = Uri.parse(rawUrl.trim());
      return uri.host.toLowerCase() == 'i.ibb.co';
    } catch (_) {
      return false;
    }
  }

  /// Resolves an ImgBB page link to its direct image URL
  static Future<String> resolveToDirectUrl(String pageUrl, {int timeoutSeconds = 15}) async {
    final cleanUrl = pageUrl.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      throw const FormatException('URL must start with http:// or https://');
    }

    final uri = Uri.parse(cleanUrl);
    final host = uri.host.toLowerCase();

    // Already direct image
    if (host == 'i.ibb.co') {
      return cleanUrl;
    }

    if (host != 'ibb.co' && host != 'www.ibb.co') {
      throw const FormatException('Only ImgBB links (ibb.co) are supported on TKMingle.');
    }

    final client = HttpClient();
    client.autoUncompress = true;

    try {
      final request = await client.getUrl(uri).timeout(Duration(seconds: timeoutSeconds));
      request.headers.set('User-Agent', 'Mozilla/5.0 (compatible; TKMingleImgBB/1.0)');
      request.followRedirects = true;

      final response = await request.close().timeout(Duration(seconds: timeoutSeconds));
      if (response.statusCode != 200) {
        throw HttpException('ImgBB returned HTTP ${response.statusCode}');
      }

      final html = await response.transform(utf8.decoder).join();

      // 1. Check Open Graph or Twitter metadata tags
      final ogRegex = RegExp(
        r'''<meta[^>]+(?:property|name)=["'](?:og:image|twitter:image|twitter:image:src)["'][^>]+content=["']([^"']+)["']''',
        caseSensitive: false,
      );
      final ogMatch = ogRegex.firstMatch(html);
      if (ogMatch != null && ogMatch.group(1) != null) {
        final candidate = ogMatch.group(1)!;
        if (candidate.contains('i.ibb.co')) {
          debugPrint('ImgbbResolver: Extracted direct image via metadata: $candidate');
          return candidate;
        }
      }

      // 2. Fallback: Search the HTML for i.ibb.co image links
      final directRegex = RegExp(
        r'''https?://i\.ibb\.co/[^"'<>\s\\]+''',
        caseSensitive: false,
      );
      final match = directRegex.firstMatch(html);
      if (match != null) {
        final candidate = match.group(0)!.replaceAll('&amp;', '&');
        debugPrint('ImgbbResolver: Extracted direct image via fallback regex: $candidate');
        return candidate;
      }

      throw const FormatException('No direct image URL found on this ImgBB page.');
    } finally {
      client.close();
    }
  }
}

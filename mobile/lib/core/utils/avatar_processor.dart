import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarProcessResult {
  final Uint8List bytes;
  final int byteSize;
  final int width;
  final int height;

  const AvatarProcessResult({
    required this.bytes,
    required this.byteSize,
    required this.width,
    required this.height,
  });
}

class AvatarProcessor {
  static const int maxFileSizeBytes = 100 * 1024; // 100 KB strict limit
  static const int targetDimension = 128; // 128x128 px
  static const String avatarBucket = 'profile-avatars';

  /// Picks an image from [source] (camera or gallery), validates size,
  /// crops square from center, strips EXIF metadata (via bakeOrientation),
  /// resizes to 128x128 px, and progressively compresses as JPEG <= 100 KB.
  static Future<AvatarProcessResult?> pickAndProcessImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );

    if (pickedFile == null) return null;

    final rawBytes = await pickedFile.readAsBytes();
    if (rawBytes.lengthInBytes > 5 * 1024 * 1024) {
      throw Exception('Selected image exceeds 5 MB. Please choose a smaller photo.');
    }

    return processRawBytes(rawBytes);
  }

  /// Crops square, resizes to 128x128 px, and compresses raw image bytes.
  static AvatarProcessResult processRawBytes(Uint8List rawBytes) {
    img.Image? decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw Exception('Failed to decode image data.');
    }

    // Automatically correct orientation and strip EXIF
    decoded = img.bakeOrientation(decoded);

    // Crop center square
    final minDim = min(decoded.width, decoded.height);
    final cropX = (decoded.width - minDim) ~/ 2;
    final cropY = (decoded.height - minDim) ~/ 2;

    final square = img.copyCrop(
      decoded,
      x: cropX,
      y: cropY,
      width: minDim,
      height: minDim,
    );

    // Resize to exact target dimension (128x128 px)
    final resized = img.copyResize(
      square,
      width: targetDimension,
      height: targetDimension,
      interpolation: img.Interpolation.linear,
    );

    // Progressive compression <= 100 KB
    int quality = 85;
    Uint8List compressed = Uint8List.fromList(img.encodeJpg(resized, quality: quality));

    while (compressed.lengthInBytes > maxFileSizeBytes && quality > 30) {
      quality -= 10;
      compressed = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    }

    return AvatarProcessResult(
      bytes: compressed,
      byteSize: compressed.lengthInBytes,
      width: resized.width,
      height: resized.height,
    );
  }

  /// Uploads processed image bytes to Supabase Storage at:
  /// profile-avatars/{userId}/avatar.jpg
  /// Returns the versioned public URL for immediate cache invalidation.
  static Future<String> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    final client = Supabase.instance.client;
    final path = '$userId/avatar.jpg';

    // Upload with upsert: true
    await client.storage.from(avatarBucket).uploadBinary(
      path,
      imageBytes,
      fileOptions: const FileOptions(
        upsert: true,
        contentType: 'image/jpeg',
      ),
    );

    // Generate public URL with cache bust query param
    final publicUrl = client.storage.from(avatarBucket).getPublicUrl(path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final versionedUrl = '$publicUrl?v=$timestamp';

    // Update profiles table (with fallback if avatar_type migration pending)
    try {
      await client.from('profiles').update({
        'profile_image': versionedUrl,
        'avatar_type': 'upload',
        'avatar_id': null,
      }).eq('id', userId);
    } catch (e) {
      debugPrint('Notice on avatar_type (pending migration): $e');
      await client.from('profiles').update({
        'profile_image': versionedUrl,
      }).eq('id', userId);
    }

    return versionedUrl;
  }

  /// Selects a built-in brand preset avatar (no Supabase storage upload needed)
  static Future<void> selectPresetAvatar({
    required String userId,
    required String avatarId,
  }) async {
    final client = Supabase.instance.client;
    final presetReference = 'preset:$avatarId';

    try {
      await client.from('profiles').update({
        'profile_image': presetReference,
        'avatar_type': 'preset',
        'avatar_id': avatarId,
      }).eq('id', userId);
    } catch (e) {
      debugPrint('Notice on avatar_type (pending migration): $e');
      await client.from('profiles').update({
        'profile_image': presetReference,
      }).eq('id', userId);
    }
  }

  /// Removes custom avatar and resets to initial-based deterministic gradient
  static Future<void> removeAvatar({
    required String userId,
  }) async {
    final client = Supabase.instance.client;

    // Try deleting from storage (ignore if not found)
    try {
      await client.storage.from(avatarBucket).remove(['$userId/avatar.jpg', '$userId/avatar.webp']);
    } catch (e) {
      debugPrint('Storage file cleanup note: $e');
    }

    // Reset profile avatar fields
    try {
      await client.from('profiles').update({
        'profile_image': null,
        'avatar_type': 'initial',
        'avatar_id': null,
      }).eq('id', userId);
    } catch (e) {
      debugPrint('Notice on avatar_type (pending migration): $e');
      await client.from('profiles').update({
        'profile_image': null,
      }).eq('id', userId);
    }
  }
}

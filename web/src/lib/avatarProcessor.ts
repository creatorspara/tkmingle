import { supabase } from "@/lib/supabaseClient";

export interface ProcessedAvatarResult {
  blob: Blob;
  dataUrl: string;
  sizeBytes: number;
  format: "webp" | "jpeg";
}

/**
 * Maximum allowed size for raw user-selected image (5 MB)
 */
export const MAX_RAW_IMAGE_SIZE_BYTES = 5 * 1024 * 1024;

/**
 * Strict maximum allowed size for processed upload to Supabase Storage (300 KB)
 */
export const MAX_PROCESSED_SIZE_BYTES = 300 * 1024;

/**
 * Target output dimensions (512x512 px for high-definition rendering)
 */
export const AVATAR_OUTPUT_DIMENSION = 512;

/**
 * Reads a raw File, validates size, and returns an HTMLImageElement and aspect info.
 */
export async function loadSourceImage(file: File): Promise<HTMLImageElement> {
  if (file.size > MAX_RAW_IMAGE_SIZE_BYTES) {
    throw new Error("Selected image exceeds 5 MB limit. Please select a smaller photo.");
  }

  if (!file.type.startsWith("image/")) {
    throw new Error("Invalid file format. Please select a valid JPEG, PNG, or WebP photo.");
  }

  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => resolve(img);
      img.onerror = () => reject(new Error("Could not decode selected image file."));
      img.src = e.target?.result as string;
    };
    reader.onerror = () => reject(new Error("Failed to read file from disk."));
    reader.readAsDataURL(file);
  });
}

/**
 * Crops a region of an image and renders it into a 128x128 Canvas,
 * progressively compressing to WebP (or JPEG fallback) under 100 KB.
 */
export async function processAndCompressImage(
  img: HTMLImageElement,
  cropArea: { x: number; y: number; width: number; height: number }
): Promise<ProcessedAvatarResult> {
  const canvas = document.createElement("canvas");
  canvas.width = AVATAR_OUTPUT_DIMENSION;
  canvas.height = AVATAR_OUTPUT_DIMENSION;
  const ctx = canvas.getContext("2d");

  if (!ctx) {
    throw new Error("HTML Canvas 2D context is not available.");
  }

  // High quality smoothing
  ctx.imageSmoothingEnabled = true;
  ctx.imageSmoothingQuality = "high";

  // Draw square cropped slice scaled into 128x128
  ctx.drawImage(
    img,
    cropArea.x,
    cropArea.y,
    cropArea.width,
    cropArea.height,
    0,
    0,
    AVATAR_OUTPUT_DIMENSION,
    AVATAR_OUTPUT_DIMENSION
  );

  // Progressive compression routine
  let format: "webp" | "jpeg" = "webp";
  let quality = 0.85;
  let blob: Blob | null = null;

  // Test webp support
  const testData = canvas.toDataURL("image/webp");
  if (!testData.startsWith("data:image/webp")) {
    format = "jpeg";
  }

  const mimeType = format === "webp" ? "image/webp" : "image/jpeg";

  // Iteratively adjust quality until blob <= 100 KB (target 30-60 KB)
  for (let attempt = 0; attempt < 5; attempt++) {
    blob = await new Promise<Blob | null>((resolve) =>
      canvas.toBlob((b) => resolve(b), mimeType, quality)
    );

    if (blob && blob.size <= MAX_PROCESSED_SIZE_BYTES) {
      break;
    }
    // Step down quality
    quality = Math.max(0.4, quality - 0.15);
  }

  if (!blob) {
    throw new Error("Failed to encode compressed avatar.");
  }

  if (blob.size > MAX_PROCESSED_SIZE_BYTES) {
    throw new Error(
      `Could not compress avatar below 100 KB limit (current: ${(blob.size / 1024).toFixed(1)} KB). Please choose a less complex image.`
    );
  }

  const dataUrl = canvas.toDataURL(mimeType, quality);

  return {
    blob,
    dataUrl,
    sizeBytes: blob.size,
    format,
  };
}

/**
 * Uploads processed avatar to Supabase Storage at profile-avatars/{userId}/avatar.webp
 * and updates public.profiles record.
 */
export async function uploadAvatarToStorage(
  userId: string,
  blob: Blob,
  format: "webp" | "jpeg"
): Promise<{ publicUrl: string; versionedUrl: string }> {
  const ext = format === "webp" ? "webp" : "jpg";
  const filePath = `${userId}/avatar.${ext}`;
  const contentType = format === "webp" ? "image/webp" : "image/jpeg";

  // 1. Upload to Supabase Storage with upsert
  const { data: uploadData, error: uploadErr } = await supabase.storage
    .from("profile-avatars")
    .upload(filePath, blob, {
      contentType,
      upsert: true,
      cacheControl: "3600",
    });

  if (uploadErr) {
    console.error("Storage upload error:", uploadErr);
    throw new Error(`Storage upload failed: ${uploadErr.message}`);
  }

  // 2. Obtain public URL
  const { data: urlData } = supabase.storage
    .from("profile-avatars")
    .getPublicUrl(filePath);

  const rawUrl = urlData.publicUrl;
  const versionedUrl = `${rawUrl}?v=${Date.now()}`;

  // 3. Update public.profiles row (with graceful fallback if avatar_type migration pending)
  let { error: dbErr } = await supabase
    .from("profiles")
    .update({
      profile_image: versionedUrl,
      avatar_type: "upload",
      avatar_id: null,
      updated_at: new Date().toISOString(),
    })
    .eq("id", userId);

  if (dbErr && dbErr.message && dbErr.message.includes("avatar_type")) {
    console.warn("Notice: avatar_type column pending migration. Falling back to profile_image.");
    const fallback = await supabase
      .from("profiles")
      .update({
        profile_image: versionedUrl,
        updated_at: new Date().toISOString(),
      })
      .eq("id", userId);
    dbErr = fallback.error;
  }

  if (dbErr) {
    console.error("Profile row update error:", dbErr);
    throw new Error(`Failed to update profile record: ${dbErr.message}`);
  }

  return {
    publicUrl: rawUrl,
    versionedUrl,
  };
}

/**
 * Removes an uploaded profile picture from Supabase Storage and resets profile to initials.
 */
export async function removeUploadedAvatar(userId: string): Promise<void> {
  try {
    // Attempt deletion of both webp and jpg
    await supabase.storage
      .from("profile-avatars")
      .remove([`${userId}/avatar.webp`, `${userId}/avatar.jpg`]);
  } catch (err) {
    console.warn("Storage deletion warning (ignorable if not found):", err);
  }

  let { error: dbErr } = await supabase
    .from("profiles")
    .update({
      profile_image: "",
      avatar_type: "initial",
      avatar_id: null,
      updated_at: new Date().toISOString(),
    })
    .eq("id", userId);

  if (dbErr && dbErr.message && dbErr.message.includes("avatar_type")) {
    const fallback = await supabase
      .from("profiles")
      .update({
        profile_image: "",
        updated_at: new Date().toISOString(),
      })
      .eq("id", userId);
    dbErr = fallback.error;
  }

  if (dbErr) {
    throw new Error(`Failed to reset profile avatar: ${dbErr.message}`);
  }
}

/**
 * Assigns a preset avatar (tk_avatar_XX) to the user's profile and cleans up uploaded file.
 */
export async function setPresetAvatar(userId: string, avatarId: string): Promise<string> {
  const presetValue = `preset:${avatarId}`;

  // Asynchronously clean up old uploaded photo to save Supabase storage space
  try {
    await supabase.storage
      .from("profile-avatars")
      .remove([`${userId}/avatar.webp`, `${userId}/avatar.jpg`]);
  } catch (e) {
    // Ignore if no file existed
  }

  let { error: dbErr } = await supabase
    .from("profiles")
    .update({
      profile_image: presetValue,
      avatar_type: "preset",
      avatar_id: avatarId,
      updated_at: new Date().toISOString(),
    })
    .eq("id", userId);

  if (dbErr && dbErr.message && dbErr.message.includes("avatar_type")) {
    const fallback = await supabase
      .from("profiles")
      .update({
        profile_image: presetValue,
        updated_at: new Date().toISOString(),
      })
      .eq("id", userId);
    dbErr = fallback.error;
  }

  if (dbErr) {
    throw new Error(`Failed to update preset avatar: ${dbErr.message}`);
  }

  return presetValue;
}

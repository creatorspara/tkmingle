"use client";

import React, { useState, useRef, useEffect } from "react";
import { X, ZoomIn, ZoomOut, Check, Loader2, Sparkles, AlertCircle } from "lucide-react";
import {
  processAndCompressImage,
  uploadAvatarToStorage,
  AVATAR_OUTPUT_DIMENSION,
} from "@/lib/avatarProcessor";

interface AvatarCropModalProps {
  imageFile: File;
  userId: string;
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (versionedUrl: string) => void;
}

export default function AvatarCropModal({
  imageFile,
  userId,
  isOpen,
  onClose,
  onSuccess,
}: AvatarCropModalProps) {
  const [imageElement, setImageElement] = useState<HTMLImageElement | null>(null);
  const [zoom, setZoom] = useState(1);
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const [processing, setProcessing] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [previewSize, setPreviewSize] = useState<number | null>(null);

  const containerRef = useRef<HTMLDivElement>(null);
  const canvasPreviewRef = useRef<HTMLCanvasElement>(null);

  // Load and decode image when opened
  useEffect(() => {
    if (!isOpen || !imageFile) return;

    let active = true;
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        if (!active) return;
        setImageElement(img);
        setZoom(1);
        setPan({ x: 0, y: 0 });
        setErrorMessage(null);
      };
      img.onerror = () => {
        if (active) setErrorMessage("Failed to decode the selected image file.");
      };
      img.src = e.target?.result as string;
    };
    reader.readAsDataURL(imageFile);

    return () => {
      active = false;
    };
  }, [isOpen, imageFile]);

  // Compute crop box and render preview
  useEffect(() => {
    if (!imageElement || !canvasPreviewRef.current) return;

    const canvas = canvasPreviewRef.current;
    canvas.width = AVATAR_OUTPUT_DIMENSION;
    canvas.height = AVATAR_OUTPUT_DIMENSION;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    const minSide = Math.min(imageElement.width, imageElement.height);
    const cropSize = minSide / zoom;

    // Center coordinates with pan offset
    const maxPanX = (imageElement.width - cropSize) / 2;
    const maxPanY = (imageElement.height - cropSize) / 2;

    const clampedPanX = Math.max(-maxPanX, Math.min(maxPanX, pan.x));
    const clampedPanY = Math.max(-maxPanY, Math.min(maxPanY, pan.y));

    const sourceX = (imageElement.width - cropSize) / 2 - clampedPanX;
    const sourceY = (imageElement.height - cropSize) / 2 - clampedPanY;

    ctx.drawImage(
      imageElement,
      Math.max(0, sourceX),
      Math.max(0, sourceY),
      Math.min(cropSize, imageElement.width),
      Math.min(cropSize, imageElement.height),
      0,
      0,
      AVATAR_OUTPUT_DIMENSION,
      AVATAR_OUTPUT_DIMENSION
    );
  }, [imageElement, zoom, pan]);

  if (!isOpen) return null;

  // Handle Drag/Pan on crop area
  const handleMouseDown = (e: React.MouseEvent) => {
    setIsDragging(true);
    setDragStart({ x: e.clientX - pan.x, y: e.clientY - pan.y });
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isDragging) return;
    setPan({
      x: e.clientX - dragStart.x,
      y: e.clientY - dragStart.y,
    });
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  const handleSave = async () => {
    if (!imageElement) return;

    setProcessing(true);
    setErrorMessage(null);

    try {
      const minSide = Math.min(imageElement.width, imageElement.height);
      const cropSize = minSide / zoom;

      const maxPanX = (imageElement.width - cropSize) / 2;
      const maxPanY = (imageElement.height - cropSize) / 2;

      const clampedPanX = Math.max(-maxPanX, Math.min(maxPanX, pan.x));
      const clampedPanY = Math.max(-maxPanY, Math.min(maxPanY, pan.y));

      const sourceX = Math.max(0, (imageElement.width - cropSize) / 2 - clampedPanX);
      const sourceY = Math.max(0, (imageElement.height - cropSize) / 2 - clampedPanY);

      // Compress and optimize to <=100 KB WebP
      const processed = await processAndCompressImage(imageElement, {
        x: sourceX,
        y: sourceY,
        width: Math.min(cropSize, imageElement.width - sourceX),
        height: Math.min(cropSize, imageElement.height - sourceY),
      });

      setPreviewSize(processed.sizeBytes);

      // Upload to Supabase Storage and update profile
      const { versionedUrl } = await uploadAvatarToStorage(
        userId,
        processed.blob,
        processed.format
      );

      onSuccess(versionedUrl);
      onClose();
    } catch (err: unknown) {
      setErrorMessage(err instanceof Error ? err.message : "Failed to process image.");
    } finally {
      setProcessing(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-fadeIn">
      <div className="relative w-full max-w-md rounded-2xl bg-brand-navy border border-brand-border/90 shadow-2xl overflow-hidden p-6 text-brand-text">
        {/* Header */}
        <div className="flex items-center justify-between pb-4 border-b border-brand-border">
          <div>
            <h3 className="text-base font-bold text-white flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-brand-teal" />
              Square Crop & Preview
            </h3>
            <p className="text-xs text-brand-muted">
              Adjust crop to 128×128 px • Optimized to &lt;100 KB
            </p>
          </div>
          <button
            onClick={onClose}
            disabled={processing}
            className="p-1 rounded-lg text-brand-muted hover:text-white hover:bg-brand-navyCard transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {errorMessage && (
          <div className="mt-3 p-3 rounded-lg bg-red-500/15 border border-red-500/30 text-xs text-red-300 flex items-center gap-2">
            <AlertCircle className="w-4 h-4 flex-shrink-0" />
            <span>{errorMessage}</span>
          </div>
        )}

        {/* Crop interactive area */}
        <div className="mt-4 flex flex-col items-center">
          <div
            ref={containerRef}
            onMouseDown={handleMouseDown}
            onMouseMove={handleMouseMove}
            onMouseUp={handleMouseUp}
            onMouseLeave={handleMouseUp}
            className="relative w-64 h-64 rounded-full border-2 border-brand-purple shadow-purple-glow overflow-hidden bg-brand-navyCard cursor-grab active:cursor-grabbing flex items-center justify-center"
          >
            <canvas
              ref={canvasPreviewRef}
              className="w-full h-full object-cover pointer-events-none"
            />
            {/* Overlay grid lines for aesthetic alignment */}
            <div className="absolute inset-0 border border-white/10 rounded-full pointer-events-none" />
          </div>

          <span className="text-[11px] text-brand-muted mt-2">
            Drag to pan • Use slider to zoom
          </span>

          {/* Zoom Controls */}
          <div className="w-full mt-4 flex items-center gap-3 px-2">
            <ZoomOut className="w-4 h-4 text-brand-muted" />
            <input
              type="range"
              min="1"
              max="3"
              step="0.05"
              value={zoom}
              onChange={(e) => setZoom(parseFloat(e.target.value))}
              disabled={processing}
              className="w-full accent-brand-purple bg-brand-navySecondary rounded-lg h-1.5 cursor-pointer"
            />
            <ZoomIn className="w-4 h-4 text-brand-muted" />
          </div>

          {previewSize && (
            <span className="text-[11px] text-brand-teal mt-1 font-mono">
              Compressed size: {(previewSize / 1024).toFixed(1)} KB (Target: &lt;100 KB)
            </span>
          )}
        </div>

        {/* Actions */}
        <div className="mt-6 flex items-center justify-end gap-3 pt-4 border-t border-brand-border">
          <button
            type="button"
            onClick={onClose}
            disabled={processing}
            className="px-4 py-2 rounded-tk-btn text-xs font-semibold text-brand-muted hover:text-white hover:bg-brand-navySecondary transition-colors"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={handleSave}
            disabled={processing || !imageElement}
            className="inline-flex items-center gap-2 px-5 py-2 rounded-tk-btn text-xs font-semibold text-white bg-gradient-to-r from-brand-purple to-brand-teal hover:opacity-90 transition-opacity disabled:opacity-50 shadow-md"
          >
            {processing ? (
              <>
                <Loader2 className="w-3.5 h-3.5 animate-spin" />
                <span>Compressing &amp; Uploading...</span>
              </>
            ) : (
              <>
                <Check className="w-3.5 h-3.5" />
                <span>Save Profile Picture</span>
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
}

"use client";

import React, { useState } from "react";
import Image from "next/image";
import { getTkAvatar, getInitials, getDeterministicGradient } from "@/lib/tkAvatars";

export interface UserAvatarProps {
  src?: string | null;
  name?: string | null;
  size?: "xs" | "sm" | "md" | "lg" | "xl" | number;
  className?: string;
  showVerifiedBadge?: boolean;
  isOnline?: boolean;
  alt?: string;
  onClick?: () => void;
}

const SIZE_MAP = {
  xs: 24,
  sm: 32,
  md: 40,
  lg: 56,
  xl: 96,
};

export default function UserAvatar({
  src,
  name,
  size = "md",
  className = "",
  showVerifiedBadge = false,
  isOnline = false,
  alt,
  onClick,
}: UserAvatarProps) {
  const [imgError, setImgError] = useState(false);
  const pxSize = typeof size === "number" ? size : SIZE_MAP[size] || 40;
  const initials = getInitials(name || "Student");
  const gradientClass = getDeterministicGradient(name || src || "seed");

  // Determine avatar source
  const cleanSrc = src?.trim() || "";
  const isPreset = cleanSrc.startsWith("preset:") || getTkAvatar(cleanSrc) !== undefined;
  const presetAvatar = isPreset ? getTkAvatar(cleanSrc) : undefined;
  const resolvedSrc = presetAvatar ? presetAvatar.svgPath : cleanSrc;

  const hasValidImage = resolvedSrc && !imgError && !cleanSrc.startsWith("initial");

  const avatarContent = (
    <div
      onClick={onClick}
      className={`relative inline-flex items-center justify-center rounded-full flex-shrink-0 select-none overflow-hidden transition-all ${
        onClick ? "cursor-pointer hover:ring-2 hover:ring-brand-purple/60" : ""
      } ${className}`}
      style={{ width: pxSize, height: pxSize }}
    >
      {hasValidImage ? (
        <img
          src={resolvedSrc}
          alt={alt || name || "User Avatar"}
          width={pxSize}
          height={pxSize}
          onError={() => setImgError(true)}
          className="w-full h-full object-cover rounded-full"
          loading="lazy"
        />
      ) : (
        <div
          className={`w-full h-full rounded-full bg-gradient-to-tr ${gradientClass} flex items-center justify-center font-bold text-white shadow-inner`}
          style={{ fontSize: Math.max(10, Math.floor(pxSize * 0.42)) }}
        >
          {initials}
        </div>
      )}
    </div>
  );

  if (!showVerifiedBadge && !isOnline) {
    return avatarContent;
  }

  const badgeSize = Math.max(12, Math.floor(pxSize * 0.3));

  return (
    <div className="relative inline-flex flex-shrink-0" style={{ width: pxSize, height: pxSize }}>
      {avatarContent}

      {showVerifiedBadge && (
        <span
          className="absolute bottom-0 right-0 rounded-full bg-brand-navy p-[1.5px] z-10"
          title="Verified Student"
        >
          <span
            className="flex items-center justify-center rounded-full bg-brand-teal text-brand-navy"
            style={{ width: badgeSize, height: badgeSize }}
          >
            <svg
              className="w-[70%] h-[70%]"
              viewBox="0 0 12 12"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <polyline points="2.5 6 5 8.5 9.5 3.5" />
            </svg>
          </span>
        </span>
      )}

      {isOnline && !showVerifiedBadge && (
        <span
          className="absolute bottom-0 right-0 rounded-full bg-brand-navy p-[2px] z-10"
          title="Online"
        >
          <span
            className="block rounded-full bg-emerald-400"
            style={{ width: badgeSize, height: badgeSize }}
          />
        </span>
      )}
    </div>
  );
}

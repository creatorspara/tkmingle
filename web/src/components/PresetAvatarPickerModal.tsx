"use client";

import React, { useState } from "react";
import { X, Check, Loader2, Sparkles, Filter } from "lucide-react";
import { TK_AVATARS, TkAvatar } from "@/lib/tkAvatars";
import { setPresetAvatar } from "@/lib/avatarProcessor";

interface PresetAvatarPickerModalProps {
  userId: string;
  currentAvatar?: string | null;
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (presetValue: string) => void;
}

const CATEGORIES = [
  "All",
  "Tech & Code",
  "Engineering",
  "Arts & Design",
  "Science & Maker",
  "Campus Life",
] as const;

export default function PresetAvatarPickerModal({
  userId,
  currentAvatar,
  isOpen,
  onClose,
  onSuccess,
}: PresetAvatarPickerModalProps) {
  const [selectedCategory, setSelectedCategory] = useState<string>("All");
  const [selectedId, setSelectedId] = useState<string>(
    currentAvatar?.replace("preset:", "") || "tk_avatar_01"
  );
  const [saving, setSaving] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  if (!isOpen) return null;

  const filteredAvatars =
    selectedCategory === "All"
      ? TK_AVATARS
      : TK_AVATARS.filter((a) => a.category === selectedCategory);

  const handleConfirm = async () => {
    if (!selectedId) return;
    setSaving(true);
    setErrorMsg(null);

    try {
      const presetVal = await setPresetAvatar(userId, selectedId);
      onSuccess(presetVal);
      onClose();
    } catch (err: unknown) {
      setErrorMsg(err instanceof Error ? err.message : "Failed to set preset avatar.");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-fadeIn">
      <div className="relative w-full max-w-2xl max-h-[90vh] flex flex-col rounded-2xl bg-brand-navy border border-brand-border/90 shadow-2xl overflow-hidden p-6 text-brand-text">
        {/* Header */}
        <div className="flex items-center justify-between pb-4 border-b border-brand-border flex-shrink-0">
          <div>
            <h3 className="text-base font-bold text-white flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-brand-teal" />
              Choose Built-in Campus Avatar
            </h3>
            <p className="text-xs text-brand-muted">
              24 official TKMingle branded vectors • Zero storage quota used
            </p>
          </div>
          <button
            onClick={onClose}
            disabled={saving}
            className="p-1 rounded-lg text-brand-muted hover:text-white hover:bg-brand-navyCard transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {errorMsg && (
          <div className="mt-3 p-3 rounded-lg bg-red-500/15 border border-red-500/30 text-xs text-red-300">
            {errorMsg}
          </div>
        )}

        {/* Category Pills */}
        <div className="flex items-center gap-2 py-3 overflow-x-auto no-scrollbar flex-shrink-0 border-b border-brand-border/60">
          {CATEGORIES.map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap transition-all ${
                selectedCategory === cat
                  ? "bg-brand-purple text-white shadow-purple-glow"
                  : "bg-brand-navySecondary text-brand-muted hover:text-white"
              }`}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* Avatar Grid */}
        <div className="flex-1 overflow-y-auto py-4 grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-3 pr-1">
          {filteredAvatars.map((av) => {
            const isSelected = selectedId === av.id;
            return (
              <button
                key={av.id}
                type="button"
                onClick={() => setSelectedId(av.id)}
                className={`group relative flex flex-col items-center p-2 rounded-xl transition-all border ${
                  isSelected
                    ? "bg-brand-purple/20 border-brand-teal shadow-teal-glow scale-105"
                    : "bg-brand-navySecondary/60 border-brand-border/50 hover:border-brand-purple/60 hover:bg-brand-navyCard"
                }`}
              >
                <div className="relative w-16 h-16 rounded-full overflow-hidden mb-1.5 flex-shrink-0">
                  <img
                    src={av.svgPath}
                    alt={av.name}
                    className="w-full h-full object-cover"
                    loading="lazy"
                  />
                  {isSelected && (
                    <div className="absolute inset-0 bg-brand-purple/30 flex items-center justify-center">
                      <span className="w-6 h-6 rounded-full bg-brand-teal text-brand-navy flex items-center justify-center shadow-md">
                        <Check className="w-3.5 h-3.5 stroke-[3]" />
                      </span>
                    </div>
                  )}
                </div>
                <span className="text-[11px] font-medium text-white text-center leading-tight line-clamp-1">
                  {av.name}
                </span>
                <span className="text-[9px] text-brand-muted text-center line-clamp-1">
                  {av.category}
                </span>
              </button>
            );
          })}
        </div>

        {/* Footer */}
        <div className="pt-4 border-t border-brand-border flex items-center justify-between flex-shrink-0">
          <div className="text-xs text-brand-muted">
            Selected: <strong className="text-white">{TK_AVATARS.find((a) => a.id === selectedId)?.name}</strong>
          </div>
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={onClose}
              disabled={saving}
              className="px-4 py-2 rounded-tk-btn text-xs font-semibold text-brand-muted hover:text-white hover:bg-brand-navySecondary transition-colors"
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={handleConfirm}
              disabled={saving || !selectedId}
              className="inline-flex items-center gap-2 px-5 py-2 rounded-tk-btn text-xs font-semibold text-white bg-gradient-to-r from-brand-purple to-brand-teal hover:opacity-90 transition-opacity disabled:opacity-50 shadow-md"
            >
              {saving ? (
                <>
                  <Loader2 className="w-3.5 h-3.5 animate-spin" />
                  <span>Saving...</span>
                </>
              ) : (
                <>
                  <Check className="w-3.5 h-3.5" />
                  <span>Set as Avatar</span>
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

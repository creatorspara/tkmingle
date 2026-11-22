"use client";

import React, { useState, useEffect } from "react";
import Image from "next/image";
import {
  CheckCircle2,
  GraduationCap,
  Sparkles,
  Edit3,
  Save,
  Plus,
  X,
  Loader2,
  AlertCircle,
  Camera,
  Trash2,
  Smile,
} from "lucide-react";
import { useCurrentUser } from "@/lib/useUser";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";
import UserAvatar from "@/components/UserAvatar";
import AvatarCropModal from "@/components/AvatarCropModal";
import PresetAvatarPickerModal from "@/components/PresetAvatarPickerModal";
import { removeUploadedAvatar } from "@/lib/avatarProcessor";

export default function ProfilePage() {
  const { user, profile, loading, refreshProfile } = useCurrentUser();
  const [isEditing, setIsEditing] = useState(false);
  const [bio, setBio] = useState("");
  const [availability, setAvailability] = useState("");
  const [interests, setInterests] = useState<string[]>([]);
  const [newInterest, setNewInterest] = useState("");
  const [isSaving, setIsSaving] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);

  const [cropFile, setCropFile] = useState<File | null>(null);
  const [showCropModal, setShowCropModal] = useState(false);
  const [showPresetModal, setShowPresetModal] = useState(false);
  const [isRemovingAvatar, setIsRemovingAvatar] = useState(false);
  const [avatarSuccessMsg, setAvatarSuccessMsg] = useState<string | null>(null);
  const fileInputRef = React.useRef<HTMLInputElement>(null);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (file.size > 5 * 1024 * 1024) {
        alert("Selected image exceeds 5 MB limit. Please select a smaller photo.");
        return;
      }
      setCropFile(file);
      setShowCropModal(true);
    }
    if (e.target) e.target.value = "";
  };

  const handleRemoveAvatar = async () => {
    if (!user) return;
    if (!confirm("Are you sure you want to remove your profile picture? It will reset to your initials.")) return;
    setIsRemovingAvatar(true);
    try {
      await removeUploadedAvatar(user.id);
      await refreshProfile();
      setAvatarSuccessMsg("Profile picture removed.");
      setTimeout(() => setAvatarSuccessMsg(null), 2500);
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : "Failed to remove avatar.");
    } finally {
      setIsRemovingAvatar(false);
    }
  };

  useEffect(() => {
    if (profile) {
      setBio(profile.bio || "");
      setAvailability(profile.availability || "Available to mingle");
      setInterests(profile.interests || []);
    }
  }, [profile]);

  const handleAddInterest = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newInterest.trim()) return;
    if (!interests.includes(newInterest.trim())) {
      setInterests([...interests, newInterest.trim()]);
    }
    setNewInterest("");
  };

  const handleRemoveInterest = (item: string) => {
    setInterests(interests.filter((i) => i !== item));
  };

  const handleSaveProfile = async () => {
    if (!user) return;
    setIsSaving(true);
    try {
      if (isLiveSupabaseConfigured()) {
        const { error } = await supabase
          .from("profiles")
          .update({
            bio: bio.trim(),
            availability: availability.trim(),
            interests: interests,
          })
          .eq("id", user.id);

        if (error) {
          console.error("Profile save error:", error.message);
        } else {
          await refreshProfile();
          setSaveSuccess(true);
          setTimeout(() => setSaveSuccess(false), 2500);
        }
      }
      setIsEditing(false);
    } catch (err) {
      console.error("Save error:", err);
    } finally {
      setIsSaving(false);
    }
  };

  if (loading || !user) {
    return (
      <div className="p-8 max-w-4xl mx-auto flex flex-col items-center justify-center min-h-[50vh]">
        <Loader2 className="w-8 h-8 animate-spin text-brand-purple mb-2" />
        <p className="text-xs text-brand-muted">Loading your profile...</p>
      </div>
    );
  }

  // Active student data from Supabase Auth & profiles table
  const displayName = profile?.full_name || user?.user_metadata?.full_name || user?.email?.split("@")[0] || "TKM Student";
  const displayDept = profile?.department || user?.user_metadata?.department || "Engineering";
  const displayYear = profile?.academic_year || user?.user_metadata?.academic_year || "1st Year";
  const isVerified = profile?.verification_status === "verified" || !!user?.email_confirmed_at;
  const hasAvatar = !!profile?.profile_image && !profile.profile_image.startsWith("initial");

  return (
    <div className="p-4 sm:p-6 lg:p-8 max-w-4xl mx-auto space-y-6">
      {/* Hidden file input for photo upload */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/png,image/jpeg,image/webp,image/jpg"
        onChange={handleFileSelect}
        className="hidden"
      />

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-extrabold text-white">Campus Profile</h1>
          <p className="text-xs text-brand-muted">
            Manage your personal bio, academic year, and public discoverability
          </p>
        </div>

        <button
          onClick={() => {
            if (isEditing) {
              handleSaveProfile();
            } else {
              setIsEditing(true);
            }
          }}
          disabled={isSaving}
          className="inline-flex items-center gap-1.5 px-4 py-2 rounded-tk-btn bg-brand-navyCard border border-brand-border text-xs font-semibold text-white hover:border-brand-purple transition-colors"
        >
          {isSaving ? (
            <>
              <Loader2 className="w-3.5 h-3.5 animate-spin text-brand-teal" /> Saving...
            </>
          ) : isEditing ? (
            <>
              <Save className="w-3.5 h-3.5 text-brand-teal" /> Save Changes
            </>
          ) : (
            <>
              <Edit3 className="w-3.5 h-3.5" /> Edit Profile
            </>
          )}
        </button>
      </div>

      {saveSuccess && (
        <div className="p-3 rounded-xl bg-brand-teal/15 border border-brand-teal/40 text-xs text-brand-teal flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4" />
          Profile updated successfully in campus directory.
        </div>
      )}

      {avatarSuccessMsg && (
        <div className="p-3 rounded-xl bg-brand-teal/15 border border-brand-teal/40 text-xs text-brand-teal flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4" />
          {avatarSuccessMsg}
        </div>
      )}

      {/* Main Profile Card */}
      <div className="glass-panel rounded-2xl p-6 sm:p-8 border border-brand-border/80 space-y-6">
        <div className="flex flex-col sm:flex-row items-center sm:items-start gap-6 text-center sm:text-left">
          {/* Avatar & Avatar Action Buttons */}
          <div className="flex flex-col items-center gap-3">
            <div className="relative group">
              <UserAvatar
                src={profile?.profile_image}
                name={displayName}
                size="xl"
                className="border-2 border-brand-purple shadow-purple-glow"
              />
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                title="Change Photo"
                className="absolute inset-0 bg-brand-navy/60 backdrop-blur-sm rounded-full opacity-0 group-hover:opacity-100 transition-opacity flex flex-col items-center justify-center text-white text-[10px] font-semibold gap-1"
              >
                <Camera className="w-5 h-5 text-brand-teal" />
                <span>Upload</span>
              </button>
            </div>

            {/* Quick avatar buttons */}
            <div className="flex items-center gap-1.5">
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg bg-brand-navySecondary border border-brand-border text-[11px] font-medium text-brand-lavender hover:text-white hover:border-brand-purple transition-colors"
              >
                <Camera className="w-3 h-3 text-brand-teal" />
                <span>Upload</span>
              </button>

              <button
                type="button"
                onClick={() => setShowPresetModal(true)}
                className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg bg-brand-navySecondary border border-brand-border text-[11px] font-medium text-brand-lavender hover:text-white hover:border-brand-purple transition-colors"
              >
                <Smile className="w-3 h-3 text-brand-purple" />
                <span>Avatars</span>
              </button>

              {hasAvatar && (
                <button
                  type="button"
                  onClick={handleRemoveAvatar}
                  disabled={isRemovingAvatar}
                  title="Remove custom photo and reset to initials"
                  className="p-1 rounded-lg bg-brand-navySecondary border border-brand-border text-[11px] font-medium text-brand-muted hover:text-brand-error hover:border-brand-error/40 transition-colors"
                >
                  {isRemovingAvatar ? (
                    <Loader2 className="w-3 h-3 animate-spin text-brand-error" />
                  ) : (
                    <Trash2 className="w-3 h-3" />
                  )}
                </button>
              )}
            </div>
          </div>

          <div className="space-y-2 flex-1 pt-1">
            <div className="flex flex-col sm:flex-row sm:items-center gap-2">
              <h2 className="text-xl font-bold text-white flex items-center justify-center sm:justify-start gap-2">
                {displayName}
                {isVerified && <CheckCircle2 className="w-5 h-5 text-brand-teal" />}
              </h2>
              <span className={`inline-block text-xs px-2.5 py-0.5 rounded-full font-semibold self-center sm:self-auto ${
                isVerified ? "bg-brand-teal/15 text-brand-teal" : "bg-brand-warning/15 text-brand-warning"
              }`}>
                {isVerified ? "Verified Student" : "Pending Verification"}
              </span>
            </div>

            <p className="text-xs text-brand-muted">
              {displayDept} • {displayYear}
            </p>

            <div className="text-xs text-brand-lavender flex items-center justify-center sm:justify-start gap-1.5 pt-1">
              <GraduationCap className="w-4 h-4 text-brand-teal" />
              <span>TKM College of Engineering, Kollam</span>
            </div>
          </div>
        </div>

        {/* Bio Section */}
        <div className="space-y-2 pt-4 border-t border-brand-border/60">
          <label className="text-xs font-bold text-brand-muted uppercase tracking-wider block">
            Bio
          </label>
          {isEditing ? (
            <textarea
              rows={3}
              value={bio}
              onChange={(e) => setBio(e.target.value)}
              placeholder="Tell other students what you are studying, building, or looking for..."
              className="w-full p-3 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
            />
          ) : (
            <p className="text-xs sm:text-sm text-brand-text leading-relaxed bg-brand-navyCard/60 p-4 rounded-xl border border-brand-border/40">
              {bio || "No bio added yet. Click Edit Profile to tell campus about yourself."}
            </p>
          )}
        </div>

        {/* Availability Section */}
        <div className="space-y-2">
          <label className="text-xs font-bold text-brand-muted uppercase tracking-wider block">
            Availability Status
          </label>
          {isEditing ? (
            <input
              type="text"
              value={availability}
              onChange={(e) => setAvailability(e.target.value)}
              placeholder="e.g. Free after 4 PM at Nescafe, looking for hackathon team"
              className="w-full p-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
            />
          ) : (
            <div className="text-xs text-brand-teal font-medium bg-brand-navyCard/60 p-3 rounded-xl border border-brand-border/40">
              {availability || "Available to mingle"}
            </div>
          )}
        </div>

        {/* Interests & Hobbies */}
        <div className="space-y-3">
          <label className="text-xs font-bold text-brand-muted uppercase tracking-wider block">
            Interests & Passions
          </label>

          <div className="flex flex-wrap gap-2">
            {interests.map((item) => (
              <span
                key={item}
                className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-brand-navyCard border border-brand-purple/40 text-xs text-brand-lavender font-medium"
              >
                {item}
                {isEditing && (
                  <button
                    onClick={() => handleRemoveInterest(item)}
                    className="hover:text-brand-error"
                  >
                    <X className="w-3 h-3" />
                  </button>
                )}
              </span>
            ))}
            {interests.length === 0 && !isEditing && (
              <span className="text-xs text-brand-muted italic">No interests added yet.</span>
            )}
          </div>

          {isEditing && (
            <form onSubmit={handleAddInterest} className="flex gap-2 max-w-sm pt-1">
              <input
                type="text"
                value={newInterest}
                onChange={(e) => setNewInterest(e.target.value)}
                placeholder="Add interest (e.g. Design, Web3)..."
                className="flex-1 px-3 py-1.5 rounded-lg bg-brand-navySecondary border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
              />
              <button
                type="submit"
                className="px-3 py-1.5 rounded-lg bg-brand-purple text-white text-xs font-semibold"
              >
                Add
              </button>
            </form>
          )}
        </div>
      </div>

      {/* Avatar Crop & Compression Modal */}
      {showCropModal && cropFile && user && (
        <AvatarCropModal
          isOpen={showCropModal}
          imageFile={cropFile}
          userId={user.id}
          onClose={() => {
            setShowCropModal(false);
            setCropFile(null);
          }}
          onSuccess={async () => {
            setShowCropModal(false);
            setCropFile(null);
            await refreshProfile();
            setAvatarSuccessMsg("Profile photo updated successfully!");
            setTimeout(() => setAvatarSuccessMsg(null), 3000);
          }}
        />
      )}

      {/* Built-in TKM Brand Avatar Picker Modal */}
      {showPresetModal && user && (
        <PresetAvatarPickerModal
          isOpen={showPresetModal}
          userId={user.id}
          currentAvatar={profile?.avatar_id || profile?.profile_image}
          onClose={() => setShowPresetModal(false)}
          onSuccess={async () => {
            setShowPresetModal(false);
            await refreshProfile();
            setAvatarSuccessMsg("Brand avatar updated successfully!");
            setTimeout(() => setAvatarSuccessMsg(null), 3000);
          }}
        />
      )}
    </div>
  );
}

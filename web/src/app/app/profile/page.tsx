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
} from "lucide-react";
import { useCurrentUser } from "@/lib/useUser";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";

export default function ProfilePage() {
  const { user, profile, loading, refreshProfile } = useCurrentUser();
  const [isEditing, setIsEditing] = useState(false);
  const [bio, setBio] = useState("");
  const [availability, setAvailability] = useState("");
  const [interests, setInterests] = useState<string[]>([]);
  const [newInterest, setNewInterest] = useState("");
  const [isSaving, setIsSaving] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);

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

  if (loading) {
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
  const displayImage = profile?.profile_image || "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80";
  const isVerified = profile?.verification_status === "verified" || !!user?.email_confirmed_at;

  return (
    <div className="p-4 sm:p-6 lg:p-8 max-w-4xl mx-auto space-y-6">
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

      {/* Main Profile Card */}
      <div className="glass-panel rounded-2xl p-6 sm:p-8 border border-brand-border/80 space-y-6">
        <div className="flex flex-col sm:flex-row items-center sm:items-start gap-6 text-center sm:text-left">
          <div className="relative w-24 h-24 rounded-3xl overflow-hidden border-2 border-brand-purple shadow-purple-glow">
            <Image
              src={displayImage}
              alt={displayName}
              fill
              className="object-cover"
            />
          </div>

          <div className="space-y-2 flex-1">
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
    </div>
  );
}

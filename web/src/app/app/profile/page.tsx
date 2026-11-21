"use client";

import React, { useState } from "react";
import Image from "next/image";
import {
  CheckCircle2,
  GraduationCap,
  Sparkles,
  Edit3,
  Save,
  Plus,
  X,
} from "lucide-react";
import { MOCK_STUDENTS } from "@/lib/mockData";

export default function ProfilePage() {
  const initialUser = MOCK_STUDENTS[0];
  const [isEditing, setIsEditing] = useState(false);
  const [bio, setBio] = useState(initialUser.bio);
  const [availability, setAvailability] = useState(initialUser.availability);
  const [interests, setInterests] = useState<string[]>(initialUser.interests);
  const [newInterest, setNewInterest] = useState("");

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
          onClick={() => setIsEditing(!isEditing)}
          className="inline-flex items-center gap-1.5 px-4 py-2 rounded-tk-btn bg-brand-navyCard border border-brand-border text-xs font-semibold text-white hover:border-brand-purple transition-colors"
        >
          {isEditing ? <Save className="w-3.5 h-3.5 text-brand-teal" /> : <Edit3 className="w-3.5 h-3.5" />}
          {isEditing ? "Done Editing" : "Edit Profile"}
        </button>
      </div>

      {/* Main Profile Card */}
      <div className="glass-panel rounded-2xl p-6 sm:p-8 border border-brand-border/80 space-y-6">
        <div className="flex flex-col sm:flex-row items-center sm:items-start gap-6 text-center sm:text-left">
          <div className="relative w-24 h-24 rounded-3xl overflow-hidden border-2 border-brand-purple shadow-purple-glow">
            <Image
              src={initialUser.profile_image}
              alt={initialUser.full_name}
              fill
              className="object-cover"
            />
          </div>

          <div className="space-y-2 flex-1">
            <div className="flex flex-col sm:flex-row sm:items-center gap-2">
              <h2 className="text-xl font-bold text-white flex items-center justify-center sm:justify-start gap-2">
                {initialUser.full_name}
                <CheckCircle2 className="w-5 h-5 text-brand-teal" />
              </h2>
              <span className="inline-block text-xs px-2.5 py-0.5 rounded-full bg-brand-teal/15 text-brand-teal font-semibold self-center sm:self-auto">
                Verified Student
              </span>
            </div>

            <p className="text-xs text-brand-muted">
              {initialUser.department} • {initialUser.academic_year}
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
              className="w-full p-3 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
            />
          ) : (
            <p className="text-xs sm:text-sm text-brand-text leading-relaxed bg-brand-navyCard/60 p-4 rounded-xl border border-brand-border/40">
              {bio}
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
              className="w-full p-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
            />
          ) : (
            <div className="text-xs text-brand-teal font-medium bg-brand-navyCard/60 p-3 rounded-xl border border-brand-border/40">
              {availability}
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

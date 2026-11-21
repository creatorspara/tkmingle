"use client";

import { useEffect, useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import { User } from "@supabase/supabase-js";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";
import { StudentProfile, MOCK_STUDENTS } from "@/lib/mockData";

export interface CurrentUserData {
  user: User | null;
  profile: StudentProfile | null;
  loading: boolean;
  logout: () => Promise<void>;
  refreshProfile: () => Promise<void>;
}

export function useCurrentUser(): CurrentUserData {
  const router = useRouter();
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<StudentProfile | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchProfile = useCallback(async (authUser: User) => {
    try {
      if (isLiveSupabaseConfigured()) {
        const { data, error } = await supabase
          .from("profiles")
          .select("*")
          .eq("id", authUser.id)
          .maybeSingle();

        if (error) {
          console.warn("Could not query profiles table:", error.message);
        }

        if (data) {
          setProfile({
            id: data.id,
            full_name: data.full_name || authUser.user_metadata?.full_name || "TKM Student",
            username: data.username || authUser.email?.split("@")[0] || "student",
            department: data.department || authUser.user_metadata?.department || "General",
            academic_year: data.academic_year || authUser.user_metadata?.academic_year || "1st Year",
            bio: data.bio || "",
            profile_image: data.profile_image || "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80",
            interests: data.interests || [],
            skills: data.skills || [],
            languages: data.languages || ["English", "Malayalam"],
            availability: data.availability || "Available to mingle",
            discoverable: data.discoverable ?? true,
            verification_status: data.verification_status || (authUser.email_confirmed_at ? "verified" : "pending"),
          });
          return;
        }
      }

      // If profile row does not exist yet, build from user auth metadata (NEVER fall back to Arjun Krishna)
      setProfile({
        id: authUser.id,
        full_name: authUser.user_metadata?.full_name || authUser.email?.split("@")[0] || "TKM Student",
        username: authUser.email?.split("@")[0] || "student",
        department: authUser.user_metadata?.department || "Engineering",
        academic_year: authUser.user_metadata?.academic_year || "1st Year",
        bio: "",
        profile_image: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80",
        interests: [],
        skills: [],
        languages: ["English", "Malayalam"],
        availability: "Available to mingle",
        discoverable: true,
        verification_status: authUser.email_confirmed_at ? "verified" : "pending",
      });
    } catch (err) {
      console.error("Error loading user profile:", err);
    }
  }, []);

  const refreshProfile = useCallback(async () => {
    if (!isLiveSupabaseConfigured()) return;
    const { data: { user: currentUser } } = await supabase.auth.getUser();
    if (currentUser) {
      setUser(currentUser);
      await fetchProfile(currentUser);
    }
  }, [fetchProfile]);

  useEffect(() => {
    let mounted = true;

    async function initSession() {
      try {
        if (!isLiveSupabaseConfigured()) {
          // If Supabase credentials are not configured, use null (do not mock Arjun)
          if (mounted) {
            setUser(null);
            setProfile(null);
            setLoading(false);
          }
          return;
        }

        const { data: { user: authUser }, error } = await supabase.auth.getUser();

        if (error || !authUser) {
          if (mounted) {
            setUser(null);
            setProfile(null);
            setLoading(false);
          }
          return;
        }

        if (mounted) {
          setUser(authUser);
          await fetchProfile(authUser);
          setLoading(false);
        }
      } catch (err) {
        if (mounted) {
          setUser(null);
          setProfile(null);
          setLoading(false);
        }
      }
    }

    initSession();

    // Listen to real-time auth changes (Sign in, Sign out, Token refresh)
    const { data: authListener } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!mounted) return;
        if (event === "SIGNED_OUT" || !session) {
          setUser(null);
          setProfile(null);
          setLoading(false);
        } else if (session.user) {
          setUser(session.user);
          await fetchProfile(session.user);
          setLoading(false);
        }
      }
    );

    return () => {
      mounted = false;
      authListener?.subscription.unsubscribe();
    };
  }, [fetchProfile]);

  const logout = async () => {
    try {
      if (isLiveSupabaseConfigured()) {
        await supabase.auth.signOut();
      }
    } finally {
      setUser(null);
      setProfile(null);
      router.push("/login");
    }
  };

  return {
    user,
    profile,
    loading,
    logout,
    refreshProfile,
  };
}

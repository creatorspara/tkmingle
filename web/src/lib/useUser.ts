"use client";

import { useEffect, useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import { User } from "@supabase/supabase-js";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";
import { StudentProfile } from "@/lib/mockData";

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
          console.warn("Notice querying profiles table:", error.message);
        }

        if (data) {
          setProfile({
            id: data.id,
            full_name: data.full_name || authUser.user_metadata?.full_name || "TKM Student",
            username: data.username || authUser.email?.split("@")[0] || "student",
            department: data.department || authUser.user_metadata?.department || "General",
            academic_year: data.academic_year || authUser.user_metadata?.academic_year || "1st Year",
            bio: data.bio || "",
            profile_image: data.profile_image || "",
            avatar_type: data.avatar_type || (data.profile_image?.startsWith("preset:") ? "preset" : (data.profile_image ? "upload" : "initial")),
            avatar_id: data.avatar_id || (data.profile_image?.startsWith("preset:") ? data.profile_image.replace("preset:", "") : undefined),
            interests: data.interests || [],
            skills: data.skills || [],
            languages: data.languages || ["English", "Malayalam"],
            availability: data.availability || "Available to mingle",
            discoverable: data.discoverable ?? true,
            verification_status: data.verification_status || (authUser.email_confirmed_at ? "verified" : "pending"),
          });
          return;
        }

        // If profile row doesn't exist yet, self-heal in public.profiles table
        const initialName = authUser.user_metadata?.full_name || authUser.email?.split("@")[0] || "TKM Student";
        const initialDept = authUser.user_metadata?.department || "General";
        const initialYear = authUser.user_metadata?.academic_year || "1st Year";
        const rawPrefix = authUser.email?.split("@")[0] || "student";
        const initialUsername = `${rawPrefix.replace(/[^a-zA-Z0-9_]/g, "_")}_${authUser.id.slice(0, 4)}`;

        try {
          await supabase.from("profiles").upsert({
            id: authUser.id,
            full_name: initialName,
            username: initialUsername,
            email: authUser.email || "",
            department: initialDept,
            academic_year: initialYear,
            verification_status: authUser.email_confirmed_at ? "verified" : "pending",
            role: "student",
          });
        } catch (healErr) {
          console.warn("Notice on self-heal profile record:", healErr);
        }
      }

      // Build profile representation strictly from authenticated user metadata
      setProfile({
        id: authUser.id,
        full_name: authUser.user_metadata?.full_name || authUser.email?.split("@")[0] || "TKM Student",
        username: authUser.email?.split("@")[0] || "student",
        department: authUser.user_metadata?.department || "Engineering",
        academic_year: authUser.user_metadata?.academic_year || "1st Year",
        bio: "",
        profile_image: "",
        avatar_type: "initial",
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
          if (mounted) {
            setUser(null);
            setProfile(null);
            setLoading(false);
          }
          return;
        }

        // 1. Instantly check cached session so back navigation and page reloads retain login without flicker
        const { data: sessionData } = await supabase.auth.getSession();
        if (sessionData?.session?.user) {
          if (mounted) {
            setUser(sessionData.session.user);
            setLoading(false);
          }
          await fetchProfile(sessionData.session.user);
          return;
        }

        // 2. Verify with server user endpoint
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

    // Listen to real-time auth changes (Sign in, Sign out, Token refresh, User update)
    const { data: authListener } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!mounted) return;
        if (event === "SIGNED_OUT") {
          setUser(null);
          setProfile(null);
          setLoading(false);
        } else if (session?.user) {
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
      router.replace("/login");
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

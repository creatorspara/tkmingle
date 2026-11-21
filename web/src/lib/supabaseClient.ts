import { createClient } from "@supabase/supabase-js";

// Official TKMingle Supabase configuration
const supabaseUrl =
  process.env.NEXT_PUBLIC_SUPABASE_URL || "https://mwwjuibehscukzueykjc.supabase.co";
const supabaseAnonKey =
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "";

export const isLiveSupabaseConfigured = () => {
  return (
    Boolean(supabaseUrl) &&
    Boolean(supabaseAnonKey) &&
    !supabaseAnonKey.includes("your-supabase") &&
    supabaseAnonKey !== "demo-anon-key" &&
    supabaseAnonKey !== ""
  );
};

// Client instance: safe for browser and SSR usage
export const supabase = createClient(
  supabaseUrl,
  supabaseAnonKey || "placeholder-publishable-key",
  {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true,
    },
    realtime: {
      params: {
        eventsPerSecond: 10,
      },
    },
  }
);

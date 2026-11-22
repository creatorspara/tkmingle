import { supabase, isLiveSupabaseConfigured } from "./supabaseClient";

export type ConnectionStatus = "none" | "pending_sent" | "pending_received" | "connected";

export interface StudentProfileMinimal {
  id: string;
  full_name: string;
  username: string;
  department: string;
  academic_year: string;
  profile_image: string;
  avatar_id?: string;
  bio?: string;
}

export interface ConnectionRequestItem {
  id: string;
  sender_id: string;
  receiver_id: string;
  status: "pending" | "accepted" | "declined" | "cancelled";
  created_at: string;
  sender?: StudentProfileMinimal;
  receiver?: StudentProfileMinimal;
}

/**
 * Loads all active connections and pending requests for the current user in batch.
 * Enables O(1) status lookup for student cards in Discover and Profile views.
 */
export async function fetchUserConnectionsOverview(userId: string): Promise<{
  connectedUserIds: Set<string>;
  pendingSentMap: Map<string, string>; // targetUserId -> requestId
  pendingReceivedMap: Map<string, string>; // targetUserId -> requestId
}> {
  const connectedUserIds = new Set<string>();
  const pendingSentMap = new Map<string, string>();
  const pendingReceivedMap = new Map<string, string>();

  if (!isLiveSupabaseConfigured() || !userId) {
    return { connectedUserIds, pendingSentMap, pendingReceivedMap };
  }

  try {
    // 1. Fetch bilateral connections
    const { data: conns, error: connErr } = await supabase
      .from("connections")
      .select("user_one, user_two")
      .or(`user_one.eq.${userId},user_two.eq.${userId}`);

    if (!connErr && conns) {
      for (const c of conns) {
        const other = c.user_one === userId ? c.user_two : c.user_one;
        connectedUserIds.add(other);
      }
    }

    // 2. Fetch pending requests
    const { data: reqs, error: reqErr } = await supabase
      .from("connection_requests")
      .select("id, sender_id, receiver_id, status")
      .or(`sender_id.eq.${userId},receiver_id.eq.${userId}`)
      .eq("status", "pending");

    if (!reqErr && reqs) {
      for (const r of reqs) {
        if (r.sender_id === userId) {
          pendingSentMap.set(r.receiver_id, r.id);
        } else if (r.receiver_id === userId) {
          pendingReceivedMap.set(r.sender_id, r.id);
        }
      }
    }
  } catch (err) {
    console.warn("Failed to fetch connection overview:", err);
  }

  return { connectedUserIds, pendingSentMap, pendingReceivedMap };
}

/**
 * Fetches pending incoming connection requests for a user, populated with sender profiles.
 */
export async function fetchReceivedRequests(userId: string): Promise<ConnectionRequestItem[]> {
  if (!isLiveSupabaseConfigured() || !userId) return [];

  try {
    const { data, error } = await supabase
      .from("connection_requests")
      .select("id, sender_id, receiver_id, status, created_at")
      .eq("receiver_id", userId)
      .eq("status", "pending")
      .order("created_at", { ascending: false });

    if (error || !data || data.length === 0) return [];

    const senderIds = data.map((r) => r.sender_id);
    const { data: profiles, error: pErr } = await supabase
      .from("profiles")
      .select("id, full_name, username, department, academic_year, profile_image, avatar_id, bio")
      .in("id", senderIds);

    const profileMap = new Map<string, StudentProfileMinimal>();
    if (!pErr && profiles) {
      for (const p of profiles) {
        profileMap.set(p.id, {
          id: p.id,
          full_name: p.full_name || "TKM Student",
          username: p.username || "student",
          department: p.department || "General",
          academic_year: p.academic_year || "1st Year",
          profile_image: p.profile_image || (p.avatar_id ? `preset:${p.avatar_id}` : ""),
          avatar_id: p.avatar_id,
          bio: p.bio || "",
        });
      }
    }

    return data.map((r) => ({
      id: r.id,
      sender_id: r.sender_id,
      receiver_id: r.receiver_id,
      status: r.status,
      created_at: r.created_at,
      sender: profileMap.get(r.sender_id),
    }));
  } catch (err) {
    console.error("Error fetching incoming requests:", err);
    return [];
  }
}

/**
 * Sends a connection request from senderId to receiverId.
 * Reuses existing records if a previous request was cancelled/declined.
 */
export async function sendConnectionRequest(senderId: string, receiverId: string): Promise<void> {
  if (!isLiveSupabaseConfigured()) return;
  if (senderId === receiverId) throw new Error("Cannot connect with yourself");

  // Check if an existing request exists
  const { data: existing } = await supabase
    .from("connection_requests")
    .select("id, status, sender_id, receiver_id")
    .or(
      `and(sender_id.eq.${senderId},receiver_id.eq.${receiverId}),and(sender_id.eq.${receiverId},receiver_id.eq.${senderId})`
    )
    .limit(1)
    .maybeSingle();

  if (existing) {
    if (existing.status === "pending") {
      if (existing.sender_id === receiverId) {
        // Target user already sent a pending request; accept it to form a connection
        await acceptConnectionRequest(existing.id);
        return;
      }
      return; // Already pending
    }

    // Reactivate previous declined or cancelled request
    const { error: updateErr } = await supabase
      .from("connection_requests")
      .update({
        sender_id: senderId,
        receiver_id: receiverId,
        status: "pending",
        updated_at: new Date().toISOString(),
      })
      .eq("id", existing.id);

    if (updateErr) throw updateErr;
    return;
  }

  // Insert fresh request
  const { error: insertErr } = await supabase.from("connection_requests").insert({
    sender_id: senderId,
    receiver_id: receiverId,
    status: "pending",
  });

  if (insertErr) throw insertErr;
}

/**
 * Accepts an incoming connection request.
 * Database trigger trg_handle_connection_accepted automatically inserts into public.connections.
 */
export async function acceptConnectionRequest(requestId: string): Promise<void> {
  if (!isLiveSupabaseConfigured()) return;

  const { error } = await supabase
    .from("connection_requests")
    .update({
      status: "accepted",
      updated_at: new Date().toISOString(),
    })
    .eq("id", requestId);

  if (error) throw error;
}

/**
 * Declines an incoming connection request.
 */
export async function declineConnectionRequest(requestId: string): Promise<void> {
  if (!isLiveSupabaseConfigured()) return;

  const { error } = await supabase
    .from("connection_requests")
    .update({
      status: "declined",
      updated_at: new Date().toISOString(),
    })
    .eq("id", requestId);

  if (error) throw error;
}

/**
 * Cancels an outgoing pending connection request.
 */
export async function cancelConnectionRequest(requestId: string): Promise<void> {
  if (!isLiveSupabaseConfigured()) return;

  const { error } = await supabase
    .from("connection_requests")
    .update({
      status: "cancelled",
      updated_at: new Date().toISOString(),
    })
    .eq("id", requestId);

  if (error) throw error;
}

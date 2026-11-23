"use client";

import React, { useState, useRef, useEffect, useCallback } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import {
  Send,
  CheckCircle2,
  Lock,
  Loader2,
  MessageSquare,
  ShieldCheck,
  Compass,
} from "lucide-react";
import { StudentProfile } from "@/lib/mockData";
import { useCurrentUser } from "@/lib/useUser";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";
import UserAvatar from "@/components/UserAvatar";

interface LiveConversation {
  id: string;
  is_group: boolean;
  title: string | null;
  last_message_preview: string | null;
  last_message_at: string;
  otherUser: StudentProfile | null;
  unreadCount: number;
}

interface LiveChatMessage {
  id: string;
  sender_id: string;
  sender_name: string;
  content: string;
  created_at: string;
  is_mine: boolean;
}

export default function MessagesPage() {
  const { user, profile } = useCurrentUser();
  const searchParams = useSearchParams();
  const toUserId = searchParams.get("to");

  const [conversations, setConversations] = useState<LiveConversation[]>([]);
  const [activeConvId, setActiveConvId] = useState<string | null>(null);
  const [messages, setMessages] = useState<LiveChatMessage[]>([]);
  const [inputText, setInputText] = useState("");
  const [loadingConvs, setLoadingConvs] = useState(true);
  const [loadingMessages, setLoadingMessages] = useState(false);
  const [sending, setSending] = useState(false);

  const messagesEndRef = useRef<HTMLDivElement>(null);
  const activeConvIdRef = useRef<string | null>(null);
  activeConvIdRef.current = activeConvId;

  const conversationsRef = useRef<LiveConversation[]>([]);
  conversationsRef.current = conversations;

  const scrollToBottom = useCallback((smooth = true) => {
    messagesEndRef.current?.scrollIntoView({ behavior: smooth ? "smooth" : "auto" });
  }, []);

  useEffect(() => {
    scrollToBottom(false);
  }, [activeConvId, scrollToBottom]);

  useEffect(() => {
    scrollToBottom(true);
  }, [messages, scrollToBottom]);

  // Load conversations once on mount or when user authenticates
  const loadConversations = useCallback(async () => {
    if (!user || !isLiveSupabaseConfigured()) {
      setLoadingConvs(false);
      return;
    }

    try {
      // 1. Fetch conversation memberships for this student
      const { data: memberRows, error: memberErr } = await supabase
        .from("conversation_members")
        .select("conversation_id, last_read_at")
        .eq("user_id", user.id);

      if (memberErr || !memberRows || memberRows.length === 0) {
        setConversations([]);
        setLoadingConvs(false);
        return;
      }

      const convIds = memberRows.map((m) => m.conversation_id);

      // 2. Fetch conversations details
      const { data: convRows, error: convErr } = await supabase
        .from("conversations")
        .select("*")
        .in("id", convIds)
        .order("last_message_at", { ascending: false });

      if (convErr || !convRows) {
        setConversations([]);
        setLoadingConvs(false);
        return;
      }

      // 3. For each conversation, fetch the other participant profile
      const populated: LiveConversation[] = [];

      for (const conv of convRows) {
        const myMembership = memberRows.find((m) => m.conversation_id === conv.id);
        const lastReadAt = myMembership?.last_read_at ? new Date(myMembership.last_read_at) : new Date(0);

        // Fetch other members
        const { data: otherMembers } = await supabase
          .from("conversation_members")
          .select("user_id")
          .eq("conversation_id", conv.id)
          .neq("user_id", user.id)
          .limit(1);

        let otherProfile: StudentProfile | null = null;
        if (otherMembers && otherMembers.length > 0) {
          const { data: profileRow } = await supabase
            .from("profiles")
            .select("*")
            .eq("id", otherMembers[0].user_id)
            .maybeSingle();

          if (profileRow) {
            otherProfile = {
              id: profileRow.id,
              full_name: profileRow.full_name || "TKM Student",
              username: profileRow.username || "student",
              department: profileRow.department || "General",
              academic_year: profileRow.academic_year || "1st Year",
              bio: profileRow.bio || "",
              profile_image: profileRow.profile_image || (profileRow.avatar_id ? `preset:${profileRow.avatar_id}` : ""),
              interests: profileRow.interests || [],
              skills: profileRow.skills || [],
              languages: profileRow.languages || ["English", "Malayalam"],
              availability: profileRow.availability || "Available",
              discoverable: profileRow.discoverable ?? true,
              verification_status: profileRow.verification_status || "verified",
            };
          }
        }

        // Count unread
        let unread = 0;
        try {
          const { data: unreadRows } = await supabase
            .from("messages")
            .select("id")
            .eq("conversation_id", conv.id)
            .neq("sender_id", user.id)
            .gt("created_at", lastReadAt.toISOString());
          unread = unreadRows ? unreadRows.length : 0;
        } catch (_) {}

        populated.push({
          id: conv.id,
          is_group: conv.is_group,
          title: conv.title,
          last_message_preview: conv.last_message_preview,
          last_message_at: conv.last_message_at,
          otherUser: otherProfile,
          unreadCount: unread,
        });
      }

      setConversations(populated);

      // Select first conversation if none selected yet
      if (populated.length > 0 && !activeConvIdRef.current) {
        setActiveConvId(populated[0].id);
      }
    } catch (err) {
      console.error("Error loading live conversations:", err);
    } finally {
      setLoadingConvs(false);
    }
  }, [user]);

  // Initial load
  useEffect(() => {
    loadConversations();
  }, [loadConversations]);

  // Global Realtime listener for incoming messages and conversation creation
  useEffect(() => {
    if (!user || !isLiveSupabaseConfigured()) return;
    const globalChannel = supabase
      .channel(`global_user_messages_${user.id}_${Date.now()}`)
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "conversation_members",
          filter: `user_id=eq.${user.id}`,
        },
        () => {
          loadConversations();
        }
      )
      .on(
        "postgres_changes",
        {
          event: "INSERT",
          schema: "public",
          table: "messages",
        },
        () => {
          loadConversations();
        }
      )
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "notifications",
          filter: `user_id=eq.${user.id}`,
        },
        (payload) => {
          if (payload.new && (payload.new as any).type === "new_message") {
            loadConversations();
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(globalChannel);
    };
  }, [user?.id, loadConversations]);

  // Handle ?to=<userId> parameter from Discovery
  useEffect(() => {
    let isCancelled = false;
    async function handleTargetUser() {
      if (!toUserId || !user || !isLiveSupabaseConfigured()) return;
      try {
        const { data: convId, error } = await supabase.rpc("get_or_create_conversation", {
          p_other_user_id: toUserId,
        });
        if (!error && convId && !isCancelled) {
          setActiveConvId(convId);
          loadConversations();
        }
      } catch (e) {
        console.error("Failed to start conversation with student:", e);
      }
    }
    handleTargetUser();
    return () => {
      isCancelled = true;
    };
  }, [toUserId, user, loadConversations]);

  // Load messages and establish Realtime subscription when activeConvId changes
  useEffect(() => {
    if (!activeConvId || !user || !isLiveSupabaseConfigured()) {
      setMessages([]);
      return;
    }

    let isCurrent = true;
    setLoadingMessages(true);

    const fetchMessages = async () => {
      try {
        const { data, error } = await supabase
          .from("messages")
          .select("*")
          .eq("conversation_id", activeConvId)
          .order("created_at", { ascending: true });

        if (!isCurrent || activeConvIdRef.current !== activeConvId) return;

        if (error) {
          console.error("Error loading conversation messages:", error.message);
          setMessages([]);
        } else {
          const activeConv = conversationsRef.current.find((c) => c.id === activeConvId);
          const otherName = activeConv?.otherUser?.full_name || "Student";

          const formatted: LiveChatMessage[] = (data || []).map((m) => ({
            id: m.id,
            sender_id: m.sender_id,
            sender_name: m.sender_id === user.id ? (profile?.full_name || "Me") : otherName,
            content: m.content,
            created_at: new Date(m.created_at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
            is_mine: m.sender_id === user.id,
          }));

          setMessages(formatted);

          // Mark conversation as read asynchronously
          supabase
            .from("conversation_members")
            .update({ last_read_at: new Date().toISOString() })
            .match({ conversation_id: activeConvId, user_id: user.id })
            .then();
        }
      } catch (err) {
        if (isCurrent) console.error("Error fetching messages:", err);
      } finally {
        if (isCurrent && activeConvIdRef.current === activeConvId) {
          setLoadingMessages(false);
        }
      }
    };

    fetchMessages();

    // Setup Realtime channel
    const channelName = `realtime_chat_${activeConvId}_${Date.now()}`;
    const channel = supabase
      .channel(channelName)
      .on(
        "postgres_changes",
        {
          event: "INSERT",
          schema: "public",
          table: "messages",
          filter: `conversation_id=eq.${activeConvId}`,
        },
        (payload) => {
          if (!isCurrent || activeConvIdRef.current !== activeConvId) return;

          const newRow = payload.new as {
            id: string;
            conversation_id: string;
            sender_id: string;
            content: string;
            created_at: string;
          };

          const activeConv = conversationsRef.current.find((c) => c.id === activeConvId);
          const otherName = activeConv?.otherUser?.full_name || "Student";

          setMessages((prev) => {
            if (prev.some((m) => m.id === newRow.id)) return prev;
            return [
              ...prev,
              {
                id: newRow.id,
                sender_id: newRow.sender_id,
                sender_name: newRow.sender_id === user.id ? (profile?.full_name || "Me") : otherName,
                content: newRow.content,
                created_at: new Date(newRow.created_at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
                is_mine: newRow.sender_id === user.id,
              },
            ];
          });

          // Update preview in conversation list
          setConversations((prev) =>
            prev.map((c) =>
              c.id === activeConvId
                ? { ...c, last_message_preview: newRow.content, last_message_at: newRow.created_at }
                : c
            )
          );
        }
      )
      .subscribe();

    return () => {
      isCurrent = false;
      supabase.removeChannel(channel);
    };
  }, [activeConvId, user?.id, profile?.full_name]);

  const handleSelectConv = (convId: string) => {
    if (convId === activeConvId) return;
    setActiveConvId(convId);
    setConversations((prev) =>
      prev.map((c) => (c.id === convId ? { ...c, unreadCount: 0 } : c))
    );
  };

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputText.trim() || !activeConvId || !user) return;

    const content = inputText.trim();
    setInputText("");
    setSending(true);

    try {
      if (isLiveSupabaseConfigured()) {
        const { error } = await supabase.from("messages").insert({
          conversation_id: activeConvId,
          sender_id: user.id,
          content: content,
          message_type: "text",
        });

        if (error) {
          console.error("Message send error:", error.message);
        }
      }
    } catch (err) {
      console.error("Failed to send message:", err);
    } finally {
      setSending(false);
    }
  };

  const activeConversation = conversations.find((c) => c.id === activeConvId);
  const activePartner = activeConversation?.otherUser;

  return (
    <div className="h-[calc(100vh-5rem)] md:h-screen flex flex-col md:flex-row overflow-hidden bg-brand-navy">
      {/* Conversation List Sidebar */}
      <div className="w-full md:w-80 border-r border-brand-border/70 bg-brand-navySecondary flex-shrink-0 flex flex-col">
        <div className="p-4 border-b border-brand-border/60 flex items-center justify-between">
          <h2 className="font-bold text-base text-white">Campus Chats</h2>
          <span className="text-[10px] px-2 py-0.5 rounded-full bg-brand-purple/20 text-brand-lavender font-semibold">
            {conversations.length} Active
          </span>
        </div>

        {/* Conversation List */}
        <div className="flex-1 overflow-y-auto p-3 space-y-2">
          {loadingConvs ? (
            <div className="flex flex-col items-center justify-center py-12 text-brand-muted">
              <Loader2 className="w-5 h-5 animate-spin mb-2 text-brand-purple" />
              <p className="text-xs">Loading conversations...</p>
            </div>
          ) : conversations.length === 0 ? (
            <div className="text-center py-12 px-4 space-y-3">
              <div className="w-10 h-10 rounded-xl bg-brand-navyCard border border-brand-border flex items-center justify-center mx-auto text-brand-muted">
                <MessageSquare className="w-5 h-5" />
              </div>
              <p className="text-xs text-brand-muted">No campus messages yet</p>
              <Link
                href="/app/discover"
                className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-tk-btn bg-brand-purple text-white text-[11px] font-semibold shadow-purple-glow"
              >
                <Compass className="w-3.5 h-3.5" />
                Find Students
              </Link>
            </div>
          ) : (
            conversations.map((conv) => {
              const partner = conv.otherUser;
              const isSelected = conv.id === activeConvId;
              const partnerName = partner?.full_name || conv.title || "Campus Student";
              const partnerImage = partner?.profile_image || (partner?.avatar_id ? `preset:${partner.avatar_id}` : "");

              return (
                <div
                  key={conv.id}
                  onClick={() => handleSelectConv(conv.id)}
                  className={`flex items-center gap-3 p-3 rounded-tk-card border transition-all cursor-pointer ${
                    isSelected
                      ? "bg-brand-navyCard border-brand-purple/60 shadow-sm"
                      : "bg-brand-navySecondary/60 border-brand-border/60 hover:bg-brand-navyCard hover:border-brand-border"
                  }`}
                >
                  <UserAvatar
                    src={partnerImage}
                    name={partnerName}
                    size={44}
                    isOnline={true}
                  />

                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <span className="font-semibold text-xs text-white truncate">
                        {partnerName}
                      </span>
                      {conv.unreadCount > 0 && (
                        <span className="text-[10px] w-4 h-4 rounded-full bg-brand-teal text-brand-navy font-bold flex items-center justify-center">
                          {conv.unreadCount}
                        </span>
                      )}
                    </div>
                    <p className="text-[11px] text-brand-muted truncate mt-0.5">
                      {conv.last_message_preview || "Start a conversation..."}
                    </p>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>

      {/* Chat Conversation Pane */}
      <div className="flex-1 flex flex-col min-w-0 bg-brand-navy relative">
        {activeConversation && activePartner ? (
          <>
            {/* Chat Header */}
            <div className="px-6 py-3.5 bg-brand-navySecondary/90 backdrop-blur-md border-b border-brand-border/70 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <UserAvatar
                  src={activePartner.profile_image}
                  name={activePartner.full_name}
                  size={40}
                  isOnline={true}
                />
                <div>
                  <div className="font-bold text-sm text-white flex items-center gap-1.5">
                    {activePartner.full_name}
                    <CheckCircle2 className="w-3.5 h-3.5 text-brand-teal" />
                  </div>
                  <div className="text-[10px] text-brand-teal flex items-center gap-1">
                    <span>{activePartner.department}</span>
                    <span>•</span>
                    <span>{activePartner.academic_year}</span>
                    <span>•</span>
                    <span className="flex items-center gap-0.5 text-brand-muted">
                      <Lock className="w-3 h-3 text-brand-teal" /> Mutual Student Connection
                    </span>
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <span className="hidden sm:inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-brand-navyCard border border-brand-border text-[10px] text-brand-muted">
                  <ShieldCheck className="w-3 h-3 text-brand-teal" /> RLS Protected • Supabase Realtime
                </span>
              </div>
            </div>

            {/* Message Thread */}
            <div className="flex-1 p-4 sm:p-6 overflow-y-auto space-y-4">
              <div className="text-center my-2">
                <span className="text-[10px] px-3 py-1 rounded-full bg-brand-navyCard border border-brand-border/60 text-brand-muted">
                  Connected on TKMingle • Messages synced in real time
                </span>
              </div>

              {loadingMessages ? (
                <div className="flex flex-col items-center justify-center py-12 text-brand-muted">
                  <Loader2 className="w-5 h-5 animate-spin mb-2 text-brand-purple" />
                  <p className="text-xs">Loading message history...</p>
                </div>
              ) : messages.length === 0 ? (
                <div className="text-center py-12 text-brand-muted text-xs">
                  Say hi to {activePartner.full_name}! Send your first message below.
                </div>
              ) : (
                messages.map((msg) => (
                  <div
                    key={msg.id}
                    className={`flex flex-col ${msg.is_mine ? "items-end" : "items-start"}`}
                  >
                    <div
                      className={`max-w-[85%] sm:max-w-md px-4 py-2.5 rounded-2xl text-xs leading-relaxed ${
                        msg.is_mine
                          ? "bg-brand-purple text-white rounded-tr-sm shadow-purple-glow"
                          : "glass-panel text-brand-text rounded-tl-sm border border-brand-border/80"
                      }`}
                    >
                      {msg.content}
                    </div>
                    <span className="text-[9px] text-brand-muted px-1 mt-1">
                      {msg.created_at} {msg.is_mine && "• Sent"}
                    </span>
                  </div>
                ))
              )}
              <div ref={messagesEndRef} />
            </div>

            {/* Input Composer */}
            <div className="p-3 sm:p-4 bg-brand-navySecondary border-t border-brand-border/70">
              <form onSubmit={handleSendMessage} className="flex items-center gap-2">
                <input
                  type="text"
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  placeholder={`Message ${activePartner.full_name}...`}
                  className="flex-1 px-4 py-2.5 rounded-tk-btn bg-brand-navyCard border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                />
                <button
                  type="submit"
                  disabled={!inputText.trim() || sending}
                  className="p-2.5 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 disabled:opacity-40 text-white shadow-purple-glow transition-all flex items-center justify-center"
                >
                  {sending ? (
                    <Loader2 className="w-4 h-4 animate-spin" />
                  ) : (
                    <Send className="w-4 h-4" />
                  )}
                </button>
              </form>
            </div>
          </>
        ) : (
          <div className="flex-1 flex flex-col items-center justify-center p-8 text-center text-brand-muted space-y-3">
            <div className="w-12 h-12 rounded-2xl bg-brand-navySecondary border border-brand-border flex items-center justify-center">
              <MessageSquare className="w-6 h-6 text-brand-purple" />
            </div>
            <div>
              <h3 className="font-semibold text-white text-sm">Select a Conversation</h3>
              <p className="text-xs text-brand-muted mt-1 max-w-sm">
                Choose an active campus chat from the sidebar or discover fellow TKMCE students to start a new discussion.
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

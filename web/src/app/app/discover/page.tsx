"use client";

import React, { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import {
  Search,
  Filter,
  CheckCircle2,
  Users2,
  GraduationCap,
  Sparkles,
  X,
  MessageSquare,
  Loader2,
  Clock,
  UserCheck,
  UserPlus,
  Inbox,
  AlertCircle,
} from "lucide-react";
import { TKMCE_DEPARTMENTS, StudentProfile } from "@/lib/mockData";
import { useCurrentUser } from "@/lib/useUser";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";
import UserAvatar from "@/components/UserAvatar";
import {
  fetchUserConnectionsOverview,
  fetchReceivedRequests,
  sendConnectionRequest,
  acceptConnectionRequest,
  declineConnectionRequest,
  cancelConnectionRequest,
  ConnectionRequestItem,
} from "@/lib/connections";

export default function DiscoverPage() {
  const { user } = useCurrentUser();
  const [students, setStudents] = useState<StudentProfile[]>([]);
  const [loadingStudents, setLoadingStudents] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedDept, setSelectedDept] = useState("All Departments");
  const [selectedYear, setSelectedYear] = useState("All Years");
  const [selectedStudent, setSelectedStudent] = useState<StudentProfile | null>(null);

  // Connection states
  const [connectedIds, setConnectedIds] = useState<Set<string>>(new Set());
  const [pendingSentMap, setPendingSentMap] = useState<Map<string, string>>(new Map()); // targetUserId -> requestId
  const [pendingReceivedMap, setPendingReceivedMap] = useState<Map<string, string>>(new Map()); // targetUserId -> requestId
  const [incomingRequests, setIncomingRequests] = useState<ConnectionRequestItem[]>([]);
  const [showIncomingDrawer, setShowIncomingDrawer] = useState(false);
  const [actionLoadingId, setActionLoadingId] = useState<string | null>(null);
  const [feedbackMsg, setFeedbackMsg] = useState<{ text: string; type: "success" | "error" } | null>(null);

  const years = ["All Years", "1st Year", "2nd Year", "3rd Year", "4th Year"];

  const loadConnections = useCallback(async (userId: string) => {
    try {
      const [overview, received] = await Promise.all([
        fetchUserConnectionsOverview(userId),
        fetchReceivedRequests(userId),
      ]);
      setConnectedIds(overview.connectedUserIds);
      setPendingSentMap(overview.pendingSentMap);
      setPendingReceivedMap(overview.pendingReceivedMap);
      setIncomingRequests(received);
    } catch (err) {
      console.warn("Failed to load connection data:", err);
    }
  }, []);

  // Fetch profiles on mount
  useEffect(() => {
    async function fetchProfiles() {
      if (!isLiveSupabaseConfigured()) {
        setStudents([]);
        setLoadingStudents(false);
        return;
      }

      try {
        const { data, error } = await supabase
          .from("profiles")
          .select("*")
          .eq("discoverable", true);

        if (!error && data && data.length > 0) {
          const liveList: StudentProfile[] = data.map((p) => ({
            id: p.id,
            full_name: p.full_name || "TKM Student",
            username: p.username || "student",
            department: p.department || "General",
            academic_year: p.academic_year || "1st Year",
            bio: p.bio || "",
            profile_image: p.profile_image || (p.avatar_id ? `preset:${p.avatar_id}` : ""),
            interests: p.interests || [],
            skills: p.skills || [],
            languages: p.languages || ["English", "Malayalam"],
            availability: p.availability || "Available to mingle",
            discoverable: p.discoverable ?? true,
            verification_status: p.verification_status || "verified",
          }));
          setStudents(liveList);
        } else {
          setStudents([]);
        }
      } catch (err) {
        console.warn("Could not query profiles table:", err);
        setStudents([]);
      } finally {
        setLoadingStudents(false);
      }
    }

    fetchProfiles();
  }, []);

  // Fetch connection states and subscribe to realtime updates
  useEffect(() => {
    if (!user?.id) return;
    loadConnections(user.id);

    // Subscribe to realtime updates on connection_requests and connections
    const channel = supabase
      .channel("discover_connection_realtime")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "connection_requests" },
        () => {
          loadConnections(user.id);
        }
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "connections" },
        () => {
          loadConnections(user.id);
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [user?.id, loadConnections]);

  // Handle Connect action
  const handleConnect = async (targetId: string, targetName: string) => {
    if (!user?.id) return;
    setActionLoadingId(targetId);
    setFeedbackMsg(null);

    try {
      await sendConnectionRequest(user.id, targetId);
      await loadConnections(user.id);
      setFeedbackMsg({ text: `Connection request sent to ${targetName}!`, type: "success" });
    } catch (err: unknown) {
      setFeedbackMsg({
        text: err instanceof Error ? err.message : "Failed to send request",
        type: "error",
      });
    } finally {
      setActionLoadingId(null);
    }
  };

  // Handle Accept action
  const handleAccept = async (requestId: string, senderName: string) => {
    if (!user?.id) return;
    setActionLoadingId(requestId);
    setFeedbackMsg(null);

    try {
      await acceptConnectionRequest(requestId);
      await loadConnections(user.id);
      setFeedbackMsg({ text: `Connected with ${senderName}!`, type: "success" });
    } catch (err: unknown) {
      setFeedbackMsg({
        text: err instanceof Error ? err.message : "Failed to accept request",
        type: "error",
      });
    } finally {
      setActionLoadingId(null);
    }
  };

  // Handle Decline action
  const handleDecline = async (requestId: string) => {
    if (!user?.id) return;
    setActionLoadingId(requestId);
    setFeedbackMsg(null);

    try {
      await declineConnectionRequest(requestId);
      await loadConnections(user.id);
      setFeedbackMsg({ text: "Connection request declined.", type: "success" });
    } catch (err: unknown) {
      setFeedbackMsg({
        text: err instanceof Error ? err.message : "Failed to decline request",
        type: "error",
      });
    } finally {
      setActionLoadingId(null);
    }
  };

  // Handle Cancel action
  const handleCancel = async (requestId: string) => {
    if (!user?.id) return;
    setActionLoadingId(requestId);
    setFeedbackMsg(null);

    try {
      await cancelConnectionRequest(requestId);
      await loadConnections(user.id);
      setFeedbackMsg({ text: "Connection request cancelled.", type: "success" });
    } catch (err: unknown) {
      setFeedbackMsg({
        text: err instanceof Error ? err.message : "Failed to cancel request",
        type: "error",
      });
    } finally {
      setActionLoadingId(null);
    }
  };

  // Filter out self and apply search/filters
  const filteredStudents = students.filter((student) => {
    if (user && student.id === user.id) return false;
    const matchesSearch =
      student.full_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      student.interests.some((i) => i.toLowerCase().includes(searchQuery.toLowerCase())) ||
      student.skills.some((s) => s.toLowerCase().includes(searchQuery.toLowerCase()));

    const matchesDept =
      selectedDept === "All Departments" || student.department === selectedDept;

    const matchesYear =
      selectedYear === "All Years" || student.academic_year === selectedYear;

    return matchesSearch && matchesDept && matchesYear;
  });

  return (
    <div className="p-4 sm:p-6 lg:p-8 max-w-7xl mx-auto space-y-6">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-white">Campus Discovery</h1>
          <p className="text-xs text-brand-muted">
            Find and connect with fellow TKMCE students across all departments
          </p>
        </div>
        <div className="flex items-center gap-3">
          {incomingRequests.length > 0 && (
            <button
              onClick={() => setShowIncomingDrawer(!showIncomingDrawer)}
              className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-brand-purple/20 border border-brand-purple text-xs text-brand-lavender font-semibold hover:bg-brand-purple/30 transition-colors animate-pulse"
            >
              <Inbox className="w-3.5 h-3.5 text-brand-lavender" />
              <span>
                Incoming Requests ({incomingRequests.length})
              </span>
            </button>
          )}

          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-brand-navyCard border border-brand-border text-xs text-brand-teal font-medium">
            <Sparkles className="w-3.5 h-3.5 text-brand-teal" />
            <span>Showing {filteredStudents.length} verified students</span>
          </div>
        </div>
      </div>

      {/* Feedback Toast */}
      {feedbackMsg && (
        <div
          className={`p-3 rounded-xl border text-xs flex items-center justify-between gap-2 transition-all ${
            feedbackMsg.type === "success"
              ? "bg-brand-teal/15 border-brand-teal/40 text-brand-teal"
              : "bg-brand-error/15 border-brand-error/40 text-brand-error"
          }`}
        >
          <div className="flex items-center gap-2">
            {feedbackMsg.type === "success" ? (
              <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
            ) : (
              <AlertCircle className="w-4 h-4 flex-shrink-0" />
            )}
            <span>{feedbackMsg.text}</span>
          </div>
          <button
            onClick={() => setFeedbackMsg(null)}
            className="p-1 hover:text-white rounded"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>
      )}

      {/* Incoming Connection Requests Drawer/Panel */}
      {showIncomingDrawer && incomingRequests.length > 0 && (
        <div className="glass-panel rounded-tk-card p-5 border border-brand-purple/40 space-y-4 animate-in fade-in slide-in-from-top-2 duration-150">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Inbox className="w-4 h-4 text-brand-purple" />
              <h2 className="text-sm font-bold text-white">
                Incoming Connection Requests ({incomingRequests.length})
              </h2>
            </div>
            <button
              onClick={() => setShowIncomingDrawer(false)}
              className="p-1 text-brand-muted hover:text-white rounded"
            >
              <X className="w-4 h-4" />
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 pt-1">
            {incomingRequests.map((req) => {
              const sender = req.sender;
              if (!sender) return null;
              const isProcessing = actionLoadingId === req.id;

              return (
                <div
                  key={req.id}
                  className="bg-brand-navySecondary border border-brand-border rounded-xl p-4 flex flex-col justify-between space-y-3"
                >
                  <div className="flex items-center gap-3">
                    <UserAvatar
                      src={sender.profile_image}
                      name={sender.full_name}
                      size={48}
                      className="rounded-xl border border-brand-border"
                    />
                    <div className="min-w-0 flex-1">
                      <div className="font-bold text-sm text-white truncate flex items-center gap-1.5">
                        {sender.full_name}
                        <CheckCircle2 className="w-3.5 h-3.5 text-brand-teal flex-shrink-0" />
                      </div>
                      <div className="text-xs text-brand-muted truncate">
                        {sender.department} • {sender.academic_year}
                      </div>
                      <div className="text-[10px] text-brand-lavender font-mono">
                        @{sender.username}
                      </div>
                    </div>
                  </div>

                  {sender.bio && (
                    <p className="text-xs text-brand-text/80 line-clamp-2 leading-relaxed">
                      {sender.bio}
                    </p>
                  )}

                  <div className="flex items-center gap-2 pt-1">
                    <button
                      onClick={() => handleDecline(req.id)}
                      disabled={isProcessing}
                      className="flex-1 py-1.5 rounded-lg border border-brand-border hover:bg-brand-navyCard text-brand-muted hover:text-white text-xs font-semibold transition-colors"
                    >
                      Decline
                    </button>
                    <button
                      onClick={() => handleAccept(req.id, sender.full_name)}
                      disabled={isProcessing}
                      className="flex-1 py-1.5 rounded-lg bg-brand-teal hover:bg-brand-teal/90 text-brand-navy font-bold text-xs transition-colors flex items-center justify-center gap-1"
                    >
                      {isProcessing ? (
                        <Loader2 className="w-3.5 h-3.5 animate-spin" />
                      ) : (
                        <>
                          <UserCheck className="w-3.5 h-3.5" /> Accept
                        </>
                      )}
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Search and Filters Bar */}
      <div className="glass-panel rounded-tk-card p-4 space-y-3">
        <div className="relative">
          <Search className="w-4 h-4 text-brand-muted absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by student name, interest (e.g. Robotics, AI, Flutter)..."
            className="w-full pl-10 pr-4 py-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
          />
        </div>

        <div className="flex flex-wrap items-center gap-2 pt-1">
          <Filter className="w-3.5 h-3.5 text-brand-muted mr-1" />
          <select
            value={selectedDept}
            onChange={(e) => setSelectedDept(e.target.value)}
            className="px-3 py-1.5 rounded-lg bg-brand-navySecondary border border-brand-border text-xs text-brand-text focus:outline-none focus:border-brand-purple"
          >
            {TKMCE_DEPARTMENTS.map((dept) => (
              <option key={dept} value={dept} className="bg-brand-navy">
                {dept}
              </option>
            ))}
          </select>

          <select
            value={selectedYear}
            onChange={(e) => setSelectedYear(e.target.value)}
            className="px-3 py-1.5 rounded-lg bg-brand-navySecondary border border-brand-border text-xs text-brand-text focus:outline-none focus:border-brand-purple"
          >
            {years.map((yr) => (
              <option key={yr} value={yr} className="bg-brand-navy">
                {yr}
              </option>
            ))}
          </select>

          {(searchQuery || selectedDept !== "All Departments" || selectedYear !== "All Years") && (
            <button
              onClick={() => {
                setSearchQuery("");
                setSelectedDept("All Departments");
                setSelectedYear("All Years");
              }}
              className="text-xs text-brand-lavender hover:underline ml-auto"
            >
              Reset Filters
            </button>
          )}
        </div>
      </div>

      {/* Student Cards Grid */}
      {loadingStudents ? (
        <div className="py-12 flex flex-col items-center justify-center text-white">
          <Loader2 className="w-8 h-8 animate-spin text-brand-purple mb-2" />
          <p className="text-xs text-brand-muted">Loading verified students from campus directory...</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredStudents.map((student) => {
            const isConnected = connectedIds.has(student.id);
            const pendingSentReqId = pendingSentMap.get(student.id);
            const pendingReceivedReqId = pendingReceivedMap.get(student.id);
            const isProcessing =
              actionLoadingId === student.id ||
              actionLoadingId === pendingSentReqId ||
              actionLoadingId === pendingReceivedReqId;

            return (
              <div
                key={student.id}
                className="glass-panel glass-panel-hover rounded-tk-card p-5 flex flex-col justify-between space-y-4"
              >
                <div className="space-y-3">
                  <div className="flex items-center gap-3">
                    <div
                      onClick={() => setSelectedStudent(student)}
                      className="cursor-pointer"
                    >
                      <UserAvatar
                        src={student.profile_image}
                        name={student.full_name}
                        size={56}
                        className="rounded-2xl border border-brand-border hover:border-brand-purple transition-colors"
                      />
                    </div>
                    <div className="min-w-0 flex-1">
                      <h3
                        onClick={() => setSelectedStudent(student)}
                        className="font-bold text-base text-white hover:text-brand-lavender cursor-pointer truncate flex items-center gap-1.5"
                      >
                        {student.full_name}
                        <CheckCircle2 className="w-3.5 h-3.5 text-brand-teal flex-shrink-0" />
                      </h3>
                      <p className="text-xs text-brand-muted truncate">
                        {student.department}
                      </p>
                      <span className="text-[10px] text-brand-lavender font-medium">
                        {student.academic_year}
                      </span>
                    </div>
                  </div>

                  <p className="text-xs text-brand-text/90 line-clamp-2 leading-relaxed">
                    {student.bio}
                  </p>

                  {/* Interest badges */}
                  <div className="flex flex-wrap gap-1.5 pt-1">
                    {student.interests.map((interest) => (
                      <span
                        key={interest}
                        className="text-[10px] px-2 py-0.5 rounded-md bg-brand-navySecondary border border-brand-border text-brand-lavender font-medium"
                      >
                        {interest}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Card Footer with Accurate Connection State */}
                <div className="pt-3 border-t border-brand-border/50 space-y-2">
                  <div className="text-[11px] text-brand-muted flex items-center gap-1.5">
                    <GraduationCap className="w-3.5 h-3.5 text-brand-teal" />
                    <span className="truncate">{student.availability}</span>
                  </div>

                  {isConnected ? (
                    <Link
                      href={`/app/messages?to=${student.id}`}
                      className="w-full py-2 rounded-tk-btn bg-brand-teal/15 border border-brand-teal/40 hover:border-brand-teal text-brand-teal text-xs font-semibold transition-all flex items-center justify-center gap-1.5"
                    >
                      <UserCheck className="w-3.5 h-3.5" />
                      <span>Connected • Message</span>
                    </Link>
                  ) : pendingReceivedReqId ? (
                    <button
                      onClick={() => handleAccept(pendingReceivedReqId, student.full_name)}
                      disabled={isProcessing}
                      className="w-full py-2 rounded-tk-btn bg-brand-teal hover:bg-brand-teal/90 text-brand-navy font-bold text-xs transition-all flex items-center justify-center gap-1.5 shadow-teal-glow"
                    >
                      {isProcessing ? (
                        <Loader2 className="w-3.5 h-3.5 animate-spin" />
                      ) : (
                        <>
                          <UserCheck className="w-3.5 h-3.5" />
                          <span>Accept Request</span>
                        </>
                      )}
                    </button>
                  ) : pendingSentReqId ? (
                    <div className="flex items-center gap-2">
                      <div className="flex-1 py-2 px-3 rounded-tk-btn bg-brand-navySecondary border border-brand-lavender/40 text-brand-lavender text-xs font-semibold flex items-center justify-center gap-1.5">
                        <Clock className="w-3.5 h-3.5 animate-pulse" />
                        <span>Request Sent</span>
                      </div>
                      <button
                        onClick={() => handleCancel(pendingSentReqId)}
                        disabled={isProcessing}
                        className="py-2 px-3 rounded-tk-btn bg-brand-navySecondary border border-brand-border hover:border-brand-error text-brand-muted hover:text-brand-error text-xs font-medium transition-colors"
                        title="Cancel Request"
                      >
                        {isProcessing ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : "Cancel"}
                      </button>
                    </div>
                  ) : (
                    <button
                      onClick={() => handleConnect(student.id, student.full_name)}
                      disabled={isProcessing}
                      className="w-full py-2 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold shadow-purple-glow transition-all flex items-center justify-center gap-1.5"
                    >
                      {isProcessing ? (
                        <Loader2 className="w-3.5 h-3.5 animate-spin" />
                      ) : (
                        <>
                          <UserPlus className="w-3.5 h-3.5" />
                          <span>Connect</span>
                        </>
                      )}
                    </button>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Student Profile Modal */}
      {selectedStudent && (
        <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-brand-navySecondary border border-brand-border rounded-2xl max-w-lg w-full p-6 space-y-5 relative shadow-2xl animate-in fade-in zoom-in-95 duration-150">
            <button
              onClick={() => setSelectedStudent(null)}
              className="absolute top-4 right-4 p-1.5 text-brand-muted hover:text-white rounded-lg hover:bg-brand-navyCard"
            >
              <X className="w-5 h-5" />
            </button>

            <div className="flex items-center gap-4">
              <UserAvatar
                src={selectedStudent.profile_image}
                name={selectedStudent.full_name}
                size={64}
                className="rounded-2xl border border-brand-purple/60"
              />
              <div>
                <h3 className="text-lg font-bold text-white flex items-center gap-1.5">
                  {selectedStudent.full_name}
                  <CheckCircle2 className="w-4 h-4 text-brand-teal" />
                </h3>
                <p className="text-xs text-brand-muted">{selectedStudent.department}</p>
                <div className="text-xs text-brand-teal font-medium">
                  {selectedStudent.academic_year} • Verified Student
                </div>
              </div>
            </div>

            <div className="space-y-2">
              <div className="text-xs font-semibold text-brand-lavender uppercase tracking-wider">
                About
              </div>
              <p className="text-xs text-brand-text leading-relaxed bg-brand-navyCard p-3 rounded-xl border border-brand-border/60">
                {selectedStudent.bio}
              </p>
            </div>

            <div className="space-y-2">
              <div className="text-xs font-semibold text-brand-lavender uppercase tracking-wider">
                Interests & Hobbies
              </div>
              <div className="flex flex-wrap gap-1.5">
                {selectedStudent.interests.map((interest) => (
                  <span
                    key={interest}
                    className="text-xs px-2.5 py-1 rounded-lg bg-brand-navyCard border border-brand-border text-white font-medium"
                  >
                    {interest}
                  </span>
                ))}
              </div>
            </div>

            <div className="space-y-2">
              <div className="text-xs font-semibold text-brand-lavender uppercase tracking-wider">
                Skills & Tech
              </div>
              <div className="flex flex-wrap gap-1.5">
                {selectedStudent.skills.map((skill) => (
                  <span
                    key={skill}
                    className="text-xs px-2.5 py-1 rounded-lg bg-brand-teal/15 text-brand-teal font-medium"
                  >
                    {skill}
                  </span>
                ))}
              </div>
            </div>

            <div className="pt-2 flex items-center gap-3">
              {connectedIds.has(selectedStudent.id) ? (
                <Link
                  href={`/app/messages?to=${selectedStudent.id}`}
                  className="flex-1 py-2.5 rounded-tk-btn bg-brand-teal hover:bg-brand-teal/90 text-brand-navy text-xs font-bold flex items-center justify-center gap-1.5"
                >
                  <MessageSquare className="w-3.5 h-3.5" />
                  Message
                </Link>
              ) : pendingReceivedMap.has(selectedStudent.id) ? (
                <button
                  onClick={() => {
                    handleAccept(pendingReceivedMap.get(selectedStudent.id)!, selectedStudent.full_name);
                    setSelectedStudent(null);
                  }}
                  className="flex-1 py-2.5 rounded-tk-btn bg-brand-teal hover:bg-brand-teal/90 text-brand-navy text-xs font-bold flex items-center justify-center gap-1.5"
                >
                  <UserCheck className="w-3.5 h-3.5" />
                  Accept Connection Request
                </button>
              ) : pendingSentMap.has(selectedStudent.id) ? (
                <button
                  onClick={() => {
                    handleCancel(pendingSentMap.get(selectedStudent.id)!);
                    setSelectedStudent(null);
                  }}
                  className="flex-1 py-2.5 rounded-tk-btn bg-brand-navyCard border border-brand-lavender text-brand-lavender text-xs font-semibold flex items-center justify-center gap-1.5"
                >
                  <Clock className="w-3.5 h-3.5" />
                  Request Pending (Click to Cancel)
                </button>
              ) : (
                <button
                  onClick={() => {
                    handleConnect(selectedStudent.id, selectedStudent.full_name);
                    setSelectedStudent(null);
                  }}
                  className="flex-1 py-2.5 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold shadow-purple-glow flex items-center justify-center gap-1.5"
                >
                  <UserPlus className="w-3.5 h-3.5" />
                  Send Connection Request
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

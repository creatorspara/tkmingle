"use client";

import React, { useState, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";
import {
  Coffee,
  Sparkles,
  Flame,
  MessageSquare,
  Send,
  Plus,
  Share2,
  Check,
  Copy,
  ExternalLink,
  Shield,
  User,
  Quote,
  EyeOff,
  Filter,
  Image as ImageIcon,
  Heart,
  TrendingUp,
  AlertCircle,
  X,
  Shuffle,
  ChevronDown,
  Info,
  Lock,
  MessageSquareOff,
  Flag,
} from "lucide-react";
import { useCurrentUser } from "@/lib/useUser";
import UserAvatar from "@/components/UserAvatar";
import {
  TeaItem,
  TeaType,
  AuthorType,
  AnonymousAlias,
  getStoredTeaPosts,
  saveTeaPosts,
  ANONYMOUS_ALIASES,
  getAliasByName,
  TEST_IMAGE_URL,
  fetchLiveTeaPosts,
  insertTeaPost,
  insertTeaComment,
  toggleTeaCommentsInDb,
  updateTeaReactionsInDb,
  reportTeaPost,
} from "@/lib/teaData";
import { supabase } from "@/lib/supabaseClient";

export default function SpillTheTeaPage() {
  const { user, profile } = useCurrentUser();
  const [posts, setPosts] = useState<TeaItem[]>([]);
  const [filterType, setFilterType] = useState<"all" | "tea" | "quote" | "anonymous" | "profiled">("all");
  const [sortBy, setSortBy] = useState<"latest" | "spicy">("latest");
  const [expandedComments, setExpandedComments] = useState<Record<string, boolean>>({});
  const [commentInputs, setCommentInputs] = useState<Record<string, string>>({});
  const [commentAnonMap, setCommentAnonMap] = useState<Record<string, boolean>>({});
  const [copiedId, setCopiedId] = useState<string | null>(null);

  // New Tea Modal State
  const [modalOpen, setModalOpen] = useState(false);
  const [postType, setPostType] = useState<TeaType>("tea");
  const [authorType, setAuthorType] = useState<AuthorType>("anonymous");
  const [selectedAlias, setSelectedAlias] = useState<AnonymousAlias>(ANONYMOUS_ALIASES[0]);
  const [postTitle, setPostTitle] = useState("");
  const [postContent, setPostContent] = useState("");
  const [quoteAuthor, setQuoteAuthor] = useState("");
  const [postDept, setPostDept] = useState("Campus-wide");
  const [imageUrl, setImageUrl] = useState("");
  const [imageValid, setImageValid] = useState<boolean | null>(null);
  const [imageChecking, setImageChecking] = useState(false);
  const [allowComments, setAllowComments] = useState(true);

  // Image Lightbox Modal
  const [lightboxImage, setLightboxImage] = useState<string | null>(null);

  // Report Tea Modal State
  const [reportingPost, setReportingPost] = useState<TeaItem | null>(null);
  const [reportReason, setReportReason] = useState<string>("Defamation or Personal Target");
  const [reportDetails, setReportDetails] = useState<string>("");
  const [isSubmittingReport, setIsSubmittingReport] = useState<boolean>(false);
  const [reportSuccessMsg, setReportSuccessMsg] = useState<string | null>(null);

  useEffect(() => {
    // 1. Initial fast load from cache
    setPosts(getStoredTeaPosts());

    // 2. Fetch live data from Supabase (visible to all accounts/devices)
    fetchLiveTeaPosts().then((livePosts) => {
      if (livePosts && livePosts.length > 0) {
        setPosts(livePosts);
      }
    });

    // 3. Subscribe to Realtime changes on tea_posts & tea_comments
    const channel = supabase
      .channel("tea_live_channel")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "tea_posts" },
        () => {
          fetchLiveTeaPosts().then((updated) => {
            if (updated && updated.length > 0) setPosts(updated);
          });
        }
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "tea_comments" },
        () => {
          fetchLiveTeaPosts().then((updated) => {
            if (updated && updated.length > 0) setPosts(updated);
          });
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  const randomizeAlias = () => {
    const random = ANONYMOUS_ALIASES[Math.floor(Math.random() * ANONYMOUS_ALIASES.length)];
    setSelectedAlias(random);
  };

  // Image URL validation check
  useEffect(() => {
    if (!imageUrl.trim()) {
      setImageValid(null);
      return;
    }
    const cleanUrl = imageUrl.trim();
    if (!cleanUrl.startsWith("http://") && !cleanUrl.startsWith("https://")) {
      setImageValid(false);
      return;
    }

    setImageChecking(true);
    const img = new window.Image();
    img.onload = () => {
      setImageValid(true);
      setImageChecking(false);
    };
    img.onerror = () => {
      setImageValid(false);
      setImageChecking(false);
    };
    img.src = cleanUrl;
  }, [imageUrl]);

  const handleLike = (id: string, kind: "like" | "fire") => {
    const updated = posts.map((p) => {
      if (p.id !== id) return p;
      if (kind === "like") {
        const isLiked = p.is_liked_by_me;
        const newLikes = isLiked ? p.likes_count - 1 : p.likes_count + 1;
        updateTeaReactionsInDb(p.id, newLikes, p.fires_count);
        return {
          ...p,
          likes_count: newLikes,
          is_liked_by_me: !isLiked,
        };
      } else {
        const isFired = p.is_fired_by_me;
        const newFires = isFired ? p.fires_count - 1 : p.fires_count + 1;
        updateTeaReactionsInDb(p.id, p.likes_count, newFires);
        return {
          ...p,
          fires_count: newFires,
          is_fired_by_me: !isFired,
        };
      }
    });
    setPosts(updated);
    saveTeaPosts(updated);
  };

  const handleToggleComments = (postId: string) => {
    const targetPost = posts.find((p) => p.id === postId);
    if (!targetPost) return;

    // Security author check
    if (targetPost.user_id && user?.id && targetPost.user_id !== user.id) {
      alert("Only the author of this post can change its comment settings.");
      return;
    }

    const updated = posts.map((p) => {
      if (p.id !== postId) return p;
      const nextState = p.allow_comments !== undefined ? !p.allow_comments : false;
      toggleTeaCommentsInDb(postId, nextState, user?.id);
      return {
        ...p,
        allow_comments: nextState,
      };
    });
    setPosts(updated);
    saveTeaPosts(updated);
  };

  const handleReportSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!reportingPost) return;
    setIsSubmittingReport(true);
    try {
      await reportTeaPost({
        postId: reportingPost.id,
        reason: reportReason,
        details: reportDetails.trim() || undefined,
        reporterId: user?.id,
        reporterName: profile?.full_name || (user?.user_metadata?.full_name as string) || "TKM Student",
        postSnippet: reportingPost.title
          ? `${reportingPost.title}: ${reportingPost.content}`
          : reportingPost.content,
        authorAlias: reportingPost.anonymous_alias || reportingPost.author_name,
      });
      setReportSuccessMsg("Report submitted to campus admin for review. Thank you!");
      setTimeout(() => {
        setReportingPost(null);
        setReportReason("Defamation or Personal Target");
        setReportDetails("");
        setReportSuccessMsg(null);
      }, 1500);
    } catch (err) {
      alert("Failed to submit report. Please try again.");
    } finally {
      setIsSubmittingReport(false);
    }
  };

  const handleAddComment = (postId: string) => {
    const targetPost = posts.find((p) => p.id === postId);
    if (!targetPost || targetPost.allow_comments === false) return;

    const text = commentInputs[postId]?.trim();
    if (!text) return;

    const isAnon = commentAnonMap[postId] ?? true;
    const anonCommentAlias = ANONYMOUS_ALIASES[Math.floor(Math.random() * ANONYMOUS_ALIASES.length)];
    const authorName = isAnon
      ? anonCommentAlias.name
      : profile?.full_name || user?.user_metadata?.full_name || "TKM Student";

    const newComment = {
      id: "comm-" + Date.now(),
      author_name: authorName,
      author_type: isAnon ? ("anonymous" as AuthorType) : ("profiled" as AuthorType),
      author_avatar: isAnon ? undefined : profile?.profile_image,
      author_alias: isAnon ? anonCommentAlias.name : undefined,
      author_icon: isAnon ? (anonCommentAlias.local_icon || anonCommentAlias.icon) : undefined,
      content: text,
      created_at: "Just now",
    };

    insertTeaComment(newComment, postId, user?.id);

    const updated = posts.map((p) => {
      if (p.id !== postId) return p;
      return {
        ...p,
        comments: [...p.comments, newComment],
      };
    });

    setPosts(updated);
    saveTeaPosts(updated);
    setCommentInputs({ ...commentInputs, [postId]: "" });
  };

  const handleCreatePost = (e: React.FormEvent) => {
    e.preventDefault();
    if (!postContent.trim()) return;

    const isAnon = authorType === "anonymous";
    const userDisplayName = profile?.full_name || user?.user_metadata?.full_name || "TKMCE Student";
    const userDept = profile?.department || user?.user_metadata?.department || "Engineering";

    const newPost: TeaItem = {
      id: "tea-" + Date.now(),
      type: postType,
      author_type: authorType,
      author_name: isAnon ? "Anonymous Student" : userDisplayName,
      author_username: isAnon ? undefined : profile?.username || "student",
      author_dept: isAnon ? undefined : userDept,
      author_avatar: isAnon ? undefined : profile?.profile_image,
      anonymous_alias: isAnon ? selectedAlias.name : undefined,
      anonymous_tag: isAnon ? `Anonymous • ${selectedAlias.name}` : undefined,
      anonymous_icon: isAnon ? (selectedAlias.local_icon || selectedAlias.icon) : undefined,
      title: postTitle.trim() || undefined,
      content: postContent.trim(),
      quote_author: postType === "quote" ? quoteAuthor.trim() || "Heard on Campus" : undefined,
      image_url: imageUrl.trim() || undefined,
      department: postDept,
      likes_count: 1,
      fires_count: 0,
      comments: [],
      allow_comments: allowComments,
      created_at: "Just now",
      is_liked_by_me: true,
    };

    // Broadcast and save to Supabase so it reflects across ALL accounts and devices
    insertTeaPost(newPost, user?.id);

    const updated = [newPost, ...posts];
    setPosts(updated);
    saveTeaPosts(updated);

    // Reset & Close
    setPostTitle("");
    setPostContent("");
    setQuoteAuthor("");
    setImageUrl("");
    setAllowComments(true);
    setModalOpen(false);
  };

  const copyPostShare = (item: TeaItem) => {
    const text = item.type === "quote"
      ? `"${item.content}"\n— ${item.quote_author || "TKMCE"}\n(Shared from TKMingle Spill the Tea)`
      : `${item.title ? item.title + "\n\n" : ""}${item.content}\n(Shared from TKMingle Spill the Tea)`;
    navigator.clipboard.writeText(text);
    setCopiedId(item.id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  // Filter & Sort
  const filteredPosts = posts.filter((p) => {
    if (filterType === "tea") return p.type === "tea" || p.type === "confession";
    if (filterType === "quote") return p.type === "quote";
    if (filterType === "anonymous") return p.author_type === "anonymous";
    if (filterType === "profiled") return p.author_type === "profiled";
    return true;
  }).sort((a, b) => {
    if (sortBy === "spicy") {
      return (b.likes_count + b.fires_count) - (a.likes_count + a.fires_count);
    }
    return 0; // Default order
  });

  return (
    <div className="p-4 sm:p-6 lg:p-8 max-w-5xl mx-auto space-y-6">
      {/* 1. TOP HEADER & BANNER */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-2 border-b border-brand-border/60">
        <div>
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-brand-purple/15 border border-brand-purple/30 text-xs font-semibold text-brand-lavender mb-2">
            <Coffee className="w-3.5 h-3.5 text-brand-purple" />
            <span>Campus Feed &bull; Confidential &amp; Public Whispers</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight flex items-center gap-2">
            Spill the Tea ☕
          </h1>
          <p className="text-xs sm:text-sm text-brand-muted mt-0.5">
            Campus confessions, legendary lecture quotes, wholesome shouts, and secret scoops at TKMCE.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Link
            href="/app/tea/admin"
            className="inline-flex items-center justify-center gap-1.5 px-3.5 py-3 rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-brand-lavender text-xs font-semibold hover:border-brand-purple/50 transition-all shadow-sm"
            title="Open Admin Tea Reports Dashboard"
          >
            <Shield className="w-4 h-4 text-brand-purple" />
            <span>Admin Reports</span>
          </Link>
          <button
            onClick={() => {
              randomizeAlias();
              setModalOpen(true);
            }}
            className="inline-flex items-center justify-center gap-2 px-5 py-3 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold shadow-purple-glow transition-all"
          >
            <Plus className="w-4 h-4" />
            <span>Spill Tea or Post Quote</span>
          </button>
        </div>
      </div>

      {/* 2. FILTER & SORT BAR */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-3 bg-brand-navySecondary/60 p-3 rounded-2xl border border-brand-border/70">
        {/* Type tabs */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0 scrollbar-none">
          <button
            onClick={() => setFilterType("all")}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all whitespace-nowrap ${
              filterType === "all"
                ? "bg-brand-purple text-white shadow-sm"
                : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
            }`}
          >
            All Campus Buzz ({posts.length})
          </button>
          <button
            onClick={() => setFilterType("tea")}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all whitespace-nowrap flex items-center gap-1 ${
              filterType === "tea"
                ? "bg-brand-purple text-white shadow-sm"
                : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
            }`}
          >
            <span>🍵 Hot Tea</span>
          </button>
          <button
            onClick={() => setFilterType("quote")}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all whitespace-nowrap flex items-center gap-1 ${
              filterType === "quote"
                ? "bg-brand-purple text-white shadow-sm"
                : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
            }`}
          >
            <Quote className="w-3.5 h-3.5" />
            <span>Quotes</span>
          </button>
          <button
            onClick={() => setFilterType("anonymous")}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all whitespace-nowrap flex items-center gap-1 ${
              filterType === "anonymous"
                ? "bg-brand-purple text-white shadow-sm"
                : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
            }`}
          >
            <EyeOff className="w-3.5 h-3.5" />
            <span>Anonymous</span>
          </button>
          <button
            onClick={() => setFilterType("profiled")}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all whitespace-nowrap flex items-center gap-1 ${
              filterType === "profiled"
                ? "bg-brand-purple text-white shadow-sm"
                : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
            }`}
          >
            <User className="w-3.5 h-3.5" />
            <span>Profiled</span>
          </button>
        </div>

        {/* Sort By */}
        <div className="flex items-center gap-2 text-xs text-brand-muted self-end md:self-auto">
          <span>Sort:</span>
          <button
            onClick={() => setSortBy("latest")}
            className={`px-2.5 py-1 rounded-md transition-colors ${
              sortBy === "latest" ? "text-brand-teal font-bold bg-brand-teal/10" : "hover:text-white"
            }`}
          >
            ⚡ Latest
          </button>
          <button
            onClick={() => setSortBy("spicy")}
            className={`px-2.5 py-1 rounded-md transition-colors ${
              sortBy === "spicy" ? "text-brand-lavender font-bold bg-brand-purple/20" : "hover:text-white"
            }`}
          >
            🔥 Spiciest
          </button>
        </div>
      </div>

      {/* 3. TEA FEED */}
      <div className="space-y-5">
        {filteredPosts.map((item) => {
          const isAnon = item.author_type === "anonymous";
          const isQuote = item.type === "quote";
          const isCommentsOpen = !!expandedComments[item.id];
          const isAuthor = Boolean(user?.id && item.user_id && user.id === item.user_id);

          return (
            <article
              key={item.id}
              className="glass-panel rounded-2xl border border-brand-border/80 p-5 sm:p-6 space-y-4 hover:border-brand-purple/40 transition-colors shadow-lg"
            >
              {/* Header: Author + Tags */}
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-center gap-3">
                  {isAnon ? (
                    (() => {
                      const aliasObj = getAliasByName(item.anonymous_alias) || ANONYMOUS_ALIASES.find(a => a.name.toLowerCase() === (item.anonymous_alias || "").toLowerCase()) || ANONYMOUS_ALIASES[0];
                      const avatarUrl = aliasObj?.local_icon || item.anonymous_icon || aliasObj?.icon || "/avatars/aliases/damu.jpg";
                      const objectPos = aliasObj?.object_position || "center";
                      return (
                        <div className="relative w-11 h-11 rounded-full overflow-hidden border-2 border-brand-purple/70 bg-brand-navy shadow-md flex-shrink-0 ring-2 ring-brand-purple/20">
                          <img
                            src={avatarUrl}
                            alt={item.anonymous_alias || "Anonymous Character"}
                            className="w-full h-full object-cover"
                            style={{ objectPosition: objectPos }}
                          />
                        </div>
                      );
                    })()
                  ) : (
                    <UserAvatar
                      src={item.author_avatar}
                      name={item.author_name}
                      size={44}
                    />
                  )}

                  <div>
                    <div className="flex flex-wrap items-center gap-1.5 sm:gap-2">
                      {isAnon ? (
                        <>
                          <span className="font-bold text-sm text-white">
                            {item.anonymous_alias || "Dasamoolam Damu"}
                          </span>
                          <span className="px-2.5 py-0.5 rounded-full bg-brand-purple/20 border border-brand-purple/40 text-[10px] font-semibold text-brand-lavender flex items-center gap-1 shadow-sm">
                            <EyeOff className="w-2.5 h-2.5 text-brand-purple" />
                            (Anonymous Post)
                          </span>
                        </>
                      ) : (
                        <>
                          <span className="font-bold text-sm text-white">
                            {item.author_name}
                          </span>
                          <span className="px-2 py-0.5 rounded-full bg-brand-teal/15 border border-brand-teal/30 text-[10px] font-semibold text-brand-teal flex items-center gap-1">
                            <User className="w-2.5 h-2.5" /> Profiled
                          </span>
                        </>
                      )}
                    </div>

                    <div className="text-[11px] text-brand-muted flex items-center gap-2 mt-0.5">
                      <span>{item.created_at}</span>
                      <span>&bull;</span>
                      <span className="text-brand-text/80">{item.department}</span>
                    </div>
                  </div>
                </div>

                {/* Post Category Badge */}
                <div className="flex items-center gap-2">
                  {item.allow_comments === false && (
                    <span className="px-2 py-0.5 rounded-full bg-amber-400/15 border border-amber-400/30 text-[10px] font-semibold text-amber-300 flex items-center gap-1">
                      <Lock className="w-2.5 h-2.5" /> Comments Off
                    </span>
                  )}
                  <span
                    className={`px-2.5 py-1 rounded-lg text-xs font-semibold border ${
                      isQuote
                        ? "bg-indigo-950/40 text-brand-lavender border-indigo-800/50"
                        : "bg-emerald-950/30 text-brand-teal border-emerald-800/40"
                    }`}
                  >
                    {isQuote ? "💬 Quote" : item.type === "confession" ? "🤫 Confession" : "🍵 Tea"}
                  </span>
                </div>
              </div>

              {/* Title (if tea / confession) */}
              {item.title && (
                <h3 className="font-bold text-base text-white">
                  {item.title}
                </h3>
              )}

              {/* Body Content */}
              {isQuote ? (
                /* Quote Card Styling */
                <div className="relative p-5 rounded-xl bg-gradient-to-r from-purple-950/30 via-brand-navyCard to-indigo-950/30 border border-brand-purple/30 space-y-2">
                  <Quote className="w-8 h-8 text-brand-purple/30 absolute top-3 right-4 pointer-events-none" />
                  <p className="text-base sm:text-lg font-serif italic text-white/95 leading-relaxed tracking-wide">
                    {item.content}
                  </p>
                  {item.quote_author && (
                    <div className="text-xs text-brand-teal font-medium flex items-center gap-1.5 pt-1">
                      <span>&mdash;</span>
                      <span>{item.quote_author}</span>
                    </div>
                  )}
                </div>
              ) : (
                /* Regular Tea Body */
                <p className="text-sm text-brand-text/90 leading-relaxed whitespace-pre-line">
                  {item.content}
                </p>
              )}

              {/* Direct Image Link Render */}
              {item.image_url && (
                <div className="space-y-1.5 pt-1">
                  <div
                    onClick={() => setLightboxImage(item.image_url!)}
                    className="relative group rounded-xl overflow-hidden border border-brand-border bg-black/50 cursor-pointer max-h-96 flex items-center justify-center"
                  >
                    {/* Using standard img with fallback for user direct links */}
                    <img
                      src={item.image_url}
                      alt="Tea attachment"
                      className="w-full h-auto max-h-96 object-contain group-hover:scale-[1.01] transition-transform duration-200"
                      loading="lazy"
                    />
                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/30 transition-colors flex items-center justify-center opacity-0 group-hover:opacity-100">
                      <span className="px-3 py-1.5 rounded-lg bg-black/80 text-white text-xs font-semibold border border-white/20">
                        Click to enlarge image
                      </span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between text-[11px] text-brand-muted px-1">
                    <span className="truncate max-w-md">🔗 Direct Image: <code className="text-brand-lavender font-mono">{item.image_url}</code></span>
                    <a
                      href={item.image_url}
                      target="_blank"
                      rel="noreferrer"
                      className="text-brand-teal hover:underline flex items-center gap-1 flex-shrink-0"
                    >
                      <ExternalLink className="w-3 h-3" /> Open Link
                    </a>
                  </div>
                </div>
              )}

              {/* Footer Actions: Like, Fire, Comment toggle, Share */}
              <div className="pt-2 border-t border-brand-border/60 flex items-center justify-between">
                <div className="flex items-center gap-2 sm:gap-3">
                  {/* Like Button */}
                  <button
                    onClick={() => handleLike(item.id, "like")}
                    className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
                      item.is_liked_by_me
                        ? "bg-brand-teal/20 text-brand-teal border border-brand-teal/40"
                        : "bg-brand-navyCard hover:bg-brand-navySecondary text-brand-muted hover:text-white border border-brand-border"
                    }`}
                  >
                    <span>🍵</span>
                    <span>{item.likes_count}</span>
                  </button>

                  {/* Fire Button */}
                  <button
                    onClick={() => handleLike(item.id, "fire")}
                    className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
                      item.is_fired_by_me
                        ? "bg-amber-500/20 text-amber-400 border border-amber-500/40"
                        : "bg-brand-navyCard hover:bg-brand-navySecondary text-brand-muted hover:text-white border border-brand-border"
                    }`}
                  >
                    <span>🔥</span>
                    <span>{item.fires_count}</span>
                  </button>

                  {/* Comments Count / Toggle */}
                  <button
                    onClick={() =>
                      setExpandedComments({
                        ...expandedComments,
                        [item.id]: !isCommentsOpen,
                      })
                    }
                    className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-brand-navyCard hover:bg-brand-navySecondary text-brand-muted hover:text-white text-xs font-semibold border border-brand-border transition-colors"
                  >
                    <MessageSquare className="w-3.5 h-3.5" />
                    <span>{item.comments.length} Comments</span>
                    {item.allow_comments === false && (
                      <span className="text-[10px] text-amber-400 font-normal ml-0.5">
                        (Locked)
                      </span>
                    )}
                  </button>

                  {/* Toggle Comments ON / OFF strictly for author */}
                  {isAuthor && (
                    <button
                      onClick={() => handleToggleComments(item.id)}
                      className={`inline-flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-xs font-semibold border transition-all ${
                        item.allow_comments !== false
                          ? "bg-brand-navyCard hover:bg-brand-navySecondary border-brand-border text-brand-muted hover:text-white"
                          : "bg-amber-400/15 border-amber-400/30 text-amber-300 hover:bg-amber-400/25"
                      }`}
                      title={item.allow_comments !== false ? "Click to turn comments OFF on this post" : "Click to turn comments ON on this post"}
                    >
                      {item.allow_comments !== false ? (
                        <>
                          <MessageSquare className="w-3 h-3 text-brand-teal" />
                          <span>Comments: ON</span>
                        </>
                      ) : (
                        <>
                          <Lock className="w-3 h-3 text-amber-400" />
                          <span>Comments: OFF</span>
                        </>
                      )}
                    </button>
                  )}
                </div>

                <div className="flex items-center gap-3">
                  {/* Report Button */}
                  <button
                    onClick={() => setReportingPost(item)}
                    className="inline-flex items-center gap-1 text-xs text-brand-muted hover:text-red-400 transition-colors px-2 py-1 rounded-lg hover:bg-red-500/10"
                    title="Report post to campus admin"
                  >
                    <Flag className="w-3.5 h-3.5" />
                    <span>Report</span>
                  </button>

                  {/* Share Button */}
                  <button
                    onClick={() => copyPostShare(item)}
                    className="inline-flex items-center gap-1 text-xs text-brand-muted hover:text-white transition-colors"
                    title="Copy quote or tea text"
                  >
                    {copiedId === item.id ? (
                      <span className="text-brand-teal flex items-center gap-1 font-semibold">
                        <Check className="w-3.5 h-3.5" /> Copied!
                      </span>
                    ) : (
                      <span className="flex items-center gap-1">
                        <Share2 className="w-3.5 h-3.5" /> Share
                      </span>
                    )}
                  </button>
                </div>
              </div>

              {/* Inline Comments Section */}
              {isCommentsOpen && (
                <div className="pt-3 border-t border-brand-border/40 space-y-3">
                  {/* Notice if comments disabled */}
                  {item.allow_comments === false && (
                    <div className="p-3 rounded-xl bg-amber-400/10 border border-amber-400/20 text-amber-300 text-xs flex items-center justify-between gap-2">
                      <div className="flex items-center gap-2">
                        <Lock className="w-4 h-4 text-amber-400 flex-shrink-0" />
                        <span>The author has turned off comments for this post.</span>
                      </div>
                      {isAuthor && (
                        <button
                          onClick={() => handleToggleComments(item.id)}
                          className="text-[11px] font-semibold underline text-amber-200 hover:text-white flex-shrink-0"
                        >
                          Turn ON Comments
                        </button>
                      )}
                    </div>
                  )}

                  {/* Comments List */}
                  {item.comments.length > 0 ? (
                    <div className="space-y-2">
                      {item.comments.map((c) => {
                        const isCommentAnon = c.author_type === "anonymous";
                        const commentAlias = isCommentAnon
                          ? (getAliasByName(c.author_alias || c.author_name) || ANONYMOUS_ALIASES.find(a => a.name.toLowerCase() === (c.author_alias || c.author_name || "").toLowerCase()) || ANONYMOUS_ALIASES[0])
                          : null;
                        const commentAvatarUrl = commentAlias?.local_icon || c.author_icon || commentAlias?.icon || "/avatars/aliases/damu.jpg";
                        const commentObjPos = commentAlias?.object_position || "center";

                        return (
                          <div
                            key={c.id}
                            className="p-2.5 rounded-xl bg-brand-navyCard/70 border border-brand-border/60 text-xs space-y-1"
                          >
                            <div className="flex items-center justify-between text-[11px]">
                              <div className="flex items-center gap-2">
                                {isCommentAnon ? (
                                  <div className="w-5 h-5 rounded-full overflow-hidden border border-brand-purple/50 bg-brand-navy flex-shrink-0">
                                    <img
                                      src={commentAvatarUrl}
                                      alt={c.author_name}
                                      className="w-full h-full object-cover"
                                      style={{ objectPosition: commentObjPos }}
                                    />
                                  </div>
                                ) : (
                                  <UserAvatar src={c.author_avatar} name={c.author_name} size={20} />
                                )}
                                <span className="font-bold text-white flex items-center gap-1.5">
                                  {c.author_name}
                                  {isCommentAnon && (
                                    <span className="text-[10px] text-brand-lavender font-medium bg-brand-purple/20 px-1.5 py-0.2 rounded border border-brand-purple/30">
                                      (Anonymous)
                                    </span>
                                  )}
                                </span>
                              </div>
                              <span className="text-brand-muted">{c.created_at}</span>
                            </div>
                            <p className="text-brand-text/90 pl-7">{c.content}</p>
                          </div>
                        );
                      })}
                    </div>
                  ) : item.allow_comments !== false ? (
                    <p className="text-xs text-brand-muted italic py-1">
                      No comments yet. Be the first to chime in!
                    </p>
                  ) : null}

                  {/* Add Comment Box - ONLY rendered when allow_comments is not false */}
                  {item.allow_comments !== false ? (
                    <div className="pt-2 flex flex-col gap-2">
                      <div className="flex items-center gap-2">
                        <input
                          type="text"
                          value={commentInputs[item.id] || ""}
                          onChange={(e) =>
                            setCommentInputs({
                              ...commentInputs,
                              [item.id]: e.target.value,
                            })
                          }
                          onKeyDown={(e) => {
                            if (e.key === "Enter") handleAddComment(item.id);
                          }}
                          placeholder={
                            commentAnonMap[item.id] ?? true
                              ? "Reply anonymously to this tea..."
                              : "Reply as yourself..."
                          }
                          className="flex-1 bg-brand-navyCard border border-brand-border rounded-xl px-3 py-2 text-xs text-white placeholder-brand-muted focus:outline-none focus:border-brand-purple"
                        />
                        <button
                          onClick={() => handleAddComment(item.id)}
                          className="p-2.5 rounded-xl bg-brand-purple hover:bg-brand-purple/90 text-white flex-shrink-0 transition-colors"
                          aria-label="Send reply"
                        >
                          <Send className="w-3.5 h-3.5" />
                        </button>
                      </div>

                      <div className="flex items-center justify-between text-[11px] text-brand-muted">
                        <button
                          onClick={() =>
                            setCommentAnonMap({
                              ...commentAnonMap,
                              [item.id]: !(commentAnonMap[item.id] ?? true),
                            })
                          }
                          className="text-brand-lavender hover:underline flex items-center gap-1"
                        >
                          {(commentAnonMap[item.id] ?? true) ? (
                            <>
                              <EyeOff className="w-3 h-3" />
                              <span>Posting Anonymously (Click to switch to Profile)</span>
                            </>
                          ) : (
                            <>
                              <User className="w-3 h-3 text-brand-teal" />
                              <span className="text-brand-teal">Posting as Profile (Click to switch to Anonymous)</span>
                            </>
                          )}
                        </button>
                      </div>
                    </div>
                  ) : null}
                </div>
              )}
            </article>
          );
        })}
      </div>

      {/* 4. NEW TEA / QUOTE MODAL */}
      {modalOpen && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-3 sm:p-5 animate-in fade-in duration-150">
          <div
            className="bg-brand-navySecondary border border-brand-border rounded-2xl max-w-xl w-full max-h-[90vh] flex flex-col shadow-2xl relative overflow-hidden"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="px-5 py-4 border-b border-brand-border/70 flex items-center justify-between bg-brand-navy/60">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-xl bg-brand-purple/20 border border-brand-purple/30 flex items-center justify-center text-brand-lavender">
                  <Coffee className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="text-base font-bold text-white">Spill Tea or Post a Quote</h3>
                  <p className="text-[11px] text-brand-muted">Share thoughts with the TKMCE campus</p>
                </div>
              </div>
              <button
                onClick={() => setModalOpen(false)}
                className="p-1.5 text-brand-muted hover:text-white rounded-lg hover:bg-brand-navyCard"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Modal Form */}
            <form onSubmit={handleCreatePost} className="p-5 overflow-y-auto space-y-4 flex-1 text-xs">
              {/* Identity Toggle: Anonymous vs Profiled */}
              <div className="space-y-1.5">
                <label className="font-semibold text-white block uppercase tracking-wider text-[11px]">
                  Posting Identity
                </label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => setAuthorType("anonymous")}
                    className={`p-3 rounded-xl border flex flex-col items-start gap-1 transition-all text-left ${
                      authorType === "anonymous"
                        ? "bg-brand-purple/20 border-brand-purple text-white shadow-sm"
                        : "bg-brand-navyCard border-brand-border text-brand-muted hover:text-white"
                    }`}
                  >
                    <span className="font-bold flex items-center gap-1.5 text-xs text-brand-lavender">
                      <EyeOff className="w-3.5 h-3.5" /> Anonymous
                    </span>
                    <span className="text-[10px] text-brand-muted leading-tight">
                      Your identity is hidden. Displays with a fun campus alias.
                    </span>
                  </button>

                  <button
                    type="button"
                    onClick={() => setAuthorType("profiled")}
                    className={`p-3 rounded-xl border flex flex-col items-start gap-1 transition-all text-left ${
                      authorType === "profiled"
                        ? "bg-brand-teal/20 border-brand-teal text-white shadow-sm"
                        : "bg-brand-navyCard border-brand-border text-brand-muted hover:text-white"
                    }`}
                  >
                    <span className="font-bold flex items-center gap-1.5 text-xs text-brand-teal">
                      <User className="w-3.5 h-3.5" /> With My Profile
                    </span>
                    <span className="text-[10px] text-brand-muted leading-tight">
                      Shows your real student name, department &amp; avatar.
                    </span>
                  </button>
                </div>
              </div>

              {/* Anonymous Alias Customizer - Malayalam Pop Culture Characters */}
              {authorType === "anonymous" && (
                <div className="space-y-3 p-3.5 rounded-xl bg-purple-950/30 border border-purple-800/40">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <div className="w-11 h-11 rounded-full overflow-hidden border-2 border-brand-purple shadow-md flex-shrink-0 bg-brand-navy">
                        <img
                          src={selectedAlias.local_icon || selectedAlias.icon}
                          alt={selectedAlias.name}
                          className="w-full h-full object-cover"
                          style={{ objectPosition: selectedAlias.object_position }}
                        />
                      </div>
                      <div>
                        <span className="text-[10px] uppercase font-bold text-brand-muted block">Selected Character Alias</span>
                        <div className="flex items-center gap-1.5">
                          <span className="font-bold text-white text-sm">{selectedAlias.name}</span>
                          <span className="text-[10px] text-brand-lavender font-medium bg-brand-purple/25 border border-brand-purple/40 px-1.5 py-0.5 rounded-full">
                            (Anonymous Post)
                          </span>
                        </div>
                      </div>
                    </div>

                    <button
                      type="button"
                      onClick={randomizeAlias}
                      className="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg bg-brand-navyCard border border-brand-border text-brand-lavender hover:text-white text-xs font-semibold transition-colors shadow-sm"
                    >
                      <Shuffle className="w-3.5 h-3.5" /> Roll Random
                    </button>
                  </div>

                  {/* Character Picker Grid */}
                  <div>
                    <span className="text-[10px] uppercase font-bold tracking-wider text-brand-muted block mb-2">
                      Choose Your Character Face &amp; Alias:
                    </span>
                    <div className="grid grid-cols-5 gap-2">
                      {ANONYMOUS_ALIASES.map((alias) => {
                        const isSelected = selectedAlias.id === alias.id;
                        return (
                          <button
                            key={alias.id}
                            type="button"
                            onClick={() => setSelectedAlias(alias)}
                            title={alias.name}
                            className={`flex flex-col items-center gap-1 p-1.5 rounded-xl border transition-all ${
                              isSelected
                                ? "bg-brand-purple/30 border-brand-purple ring-2 ring-brand-purple/60 shadow-md scale-105"
                                : "bg-brand-navyCard/60 border-brand-border/60 hover:border-brand-purple/50 opacity-80 hover:opacity-100"
                            }`}
                          >
                            <div className="w-10 h-10 rounded-full overflow-hidden border border-brand-purple/40 bg-brand-navy">
                              <img
                                src={alias.local_icon || alias.icon}
                                alt={alias.name}
                                className="w-full h-full object-cover"
                                style={{ objectPosition: alias.object_position }}
                              />
                            </div>
                            <span className="text-[9px] font-medium text-white truncate max-w-full text-center">
                              {alias.name.split(" ")[0]}
                            </span>
                          </button>
                        );
                      })}
                    </div>
                  </div>
                </div>
              )}

              {/* Post Type Selector */}
              <div className="space-y-1.5">
                <label className="font-semibold text-white block uppercase tracking-wider text-[11px]">
                  What are you sharing?
                </label>
                <div className="flex flex-wrap gap-2">
                  <button
                    type="button"
                    onClick={() => setPostType("tea")}
                    className={`px-3 py-1.5 rounded-lg border font-semibold transition-all ${
                      postType === "tea"
                        ? "bg-brand-purple text-white border-brand-purple"
                        : "bg-brand-navyCard border-brand-border text-brand-muted hover:text-white"
                    }`}
                  >
                    🍵 Hot Tea
                  </button>
                  <button
                    type="button"
                    onClick={() => setPostType("quote")}
                    className={`px-3 py-1.5 rounded-lg border font-semibold transition-all ${
                      postType === "quote"
                        ? "bg-brand-purple text-white border-brand-purple"
                        : "bg-brand-navyCard border-brand-border text-brand-muted hover:text-white"
                    }`}
                  >
                    💬 Campus Quote
                  </button>
                  <button
                    type="button"
                    onClick={() => setPostType("confession")}
                    className={`px-3 py-1.5 rounded-lg border font-semibold transition-all ${
                      postType === "confession"
                        ? "bg-brand-purple text-white border-brand-purple"
                        : "bg-brand-navyCard border-brand-border text-brand-muted hover:text-white"
                    }`}
                  >
                    🤫 Confession
                  </button>
                </div>
              </div>

              {/* Title (for Tea / Confession) */}
              {postType !== "quote" && (
                <div className="space-y-1">
                  <label className="font-semibold text-brand-muted block uppercase tracking-wider text-[11px]">
                    Topic / Headline (Optional)
                  </label>
                  <input
                    type="text"
                    value={postTitle}
                    onChange={(e) => setPostTitle(e.target.value)}
                    placeholder="e.g. Canteen parotta update, Amphi mystery..."
                    className="w-full bg-brand-navyCard border border-brand-border rounded-xl px-3 py-2 text-white placeholder-brand-muted focus:outline-none focus:border-brand-purple"
                  />
                </div>
              )}

              {/* Main Content */}
              <div className="space-y-1">
                <label className="font-semibold text-white block uppercase tracking-wider text-[11px]">
                  {postType === "quote" ? "The Quote Text *" : "The Scoop / Details *"}
                </label>
                <textarea
                  rows={4}
                  required
                  value={postContent}
                  onChange={(e) => setPostContent(e.target.value)}
                  placeholder={
                    postType === "quote"
                      ? "“Enter the memorable quote heard on campus or during lectures...”"
                      : "Spill the details here. Keep it respectful and fun!"
                  }
                  className="w-full bg-brand-navyCard border border-brand-border rounded-xl p-3 text-white placeholder-brand-muted focus:outline-none focus:border-brand-purple resize-none"
                />
              </div>

              {/* Quote Attribution (if quote) */}
              {postType === "quote" && (
                <div className="space-y-1">
                  <label className="font-semibold text-brand-muted block uppercase tracking-wider text-[11px]">
                    Who said it / Where was it heard?
                  </label>
                  <input
                    type="text"
                    value={quoteAuthor}
                    onChange={(e) => setQuoteAuthor(e.target.value)}
                    placeholder="e.g. Heard in S6 Operating Systems Lab, or Anonymous Mech Senior"
                    className="w-full bg-brand-navyCard border border-brand-border rounded-xl px-3 py-2 text-white placeholder-brand-muted focus:outline-none focus:border-brand-purple"
                  />
                </div>
              )}

              {/* Department Tag */}
              <div className="space-y-1">
                <label className="font-semibold text-brand-muted block uppercase tracking-wider text-[11px]">
                  Campus Department / Topic
                </label>
                <select
                  value={postDept}
                  onChange={(e) => setPostDept(e.target.value)}
                  className="w-full bg-brand-navyCard border border-brand-border rounded-xl px-3 py-2 text-white focus:outline-none focus:border-brand-purple"
                >
                  <option value="Campus-wide">Campus-wide (All TKMCE)</option>
                  <option value="Computer Science & Engineering">Computer Science &amp; Engineering</option>
                  <option value="Electronics & Communication">Electronics &amp; Communication</option>
                  <option value="Mechanical Engineering">Mechanical Engineering</option>
                  <option value="Civil Engineering">Civil Engineering</option>
                  <option value="Electrical & Electronics">Electrical &amp; Electronics</option>
                  <option value="Chemical Engineering">Chemical Engineering</option>
                  <option value="Architecture">Architecture</option>
                  <option value="Computer Applications (MCA)">MCA</option>
                </select>
              </div>

              {/* Direct Image Link Section (Per User Specification) */}
              <div className="p-3.5 rounded-xl bg-brand-navyCard/60 border border-brand-border space-y-2.5">
                <div className="flex items-start justify-between gap-2">
                  <div>
                    <label className="font-bold text-white flex items-center gap-1.5 text-xs">
                      <ImageIcon className="w-3.5 h-3.5 text-brand-teal" />
                      Attach Image (Direct Link Only)
                    </label>
                    <p className="text-[10px] text-brand-muted mt-0.5 leading-snug">
                      Paste a direct image URL (e.g. from ibb.co, imgur, or any raw image URL ending in .png, .jpg).
                    </p>
                  </div>

                  {/* 1-Click Test Case Button */}
                  <button
                    type="button"
                    onClick={() => setImageUrl(TEST_IMAGE_URL)}
                    className="px-2.5 py-1 rounded-lg bg-brand-purple/20 border border-brand-purple/40 text-brand-lavender hover:text-white text-[10px] font-semibold flex-shrink-0 transition-colors"
                  >
                    ✨ Use Test Case Image
                  </button>
                </div>

                <div className="relative">
                  <input
                    type="url"
                    value={imageUrl}
                    onChange={(e) => setImageUrl(e.target.value)}
                    placeholder="https://i.ibb.co/0jBt3Gvm/brand-banner-crop.png"
                    className="w-full bg-brand-navyCard border border-brand-border rounded-xl px-3 py-2 text-white placeholder-brand-muted/60 focus:outline-none focus:border-brand-purple font-mono text-[11px]"
                  />
                  {imageUrl && (
                    <button
                      type="button"
                      onClick={() => setImageUrl("")}
                      className="absolute right-2.5 top-2.5 text-brand-muted hover:text-white"
                    >
                      <X className="w-3.5 h-3.5" />
                    </button>
                  )}
                </div>

                {/* Validation Indicator & Live Preview */}
                {imageUrl && (
                  <div className="space-y-2 pt-1">
                    <div className="flex items-center gap-1.5 text-[11px]">
                      {imageChecking ? (
                        <span className="text-brand-muted">Checking image URL...</span>
                      ) : imageValid ? (
                        <span className="text-brand-teal font-semibold flex items-center gap-1">
                          <Check className="w-3 h-3 text-brand-teal" /> Direct image verified
                        </span>
                      ) : (
                        <span className="text-brand-error flex items-center gap-1">
                          <AlertCircle className="w-3 h-3 text-brand-error" /> Unable to preview image from URL
                        </span>
                      )}
                    </div>

                    {imageValid && (
                      <div className="rounded-xl overflow-hidden border border-brand-border bg-black/40 max-h-48 flex items-center justify-center p-1">
                        <img
                          src={imageUrl}
                          alt="Preview"
                          className="max-h-44 w-auto object-contain rounded-lg"
                        />
                      </div>
                    )}
                  </div>
                )}
              </div>

              {/* Allow Comments Toggle for Post Author */}
              <div className="p-3.5 rounded-xl bg-brand-navyCard/60 border border-brand-border flex items-center justify-between gap-3">
                <div>
                  <label
                    onClick={() => setAllowComments(!allowComments)}
                    className="font-bold text-white flex items-center gap-1.5 text-xs cursor-pointer"
                  >
                    <MessageSquare className="w-3.5 h-3.5 text-brand-lavender" />
                    Allow Comments on this Post
                  </label>
                  <p className="text-[10px] text-brand-muted mt-0.5 leading-snug">
                    {allowComments
                      ? "Students can reply and discuss this post publicly or anonymously."
                      : "Comments will be locked. Nobody can reply to this post."}
                  </p>
                </div>

                <button
                  type="button"
                  onClick={() => setAllowComments(!allowComments)}
                  className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                    allowComments ? "bg-brand-purple" : "bg-gray-700"
                  }`}
                  role="switch"
                  aria-checked={allowComments}
                >
                  <span
                    className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                      allowComments ? "translate-x-5" : "translate-x-0"
                    }`}
                  />
                </button>
              </div>

              {/* Guidelines reminder */}
              <div className="p-2.5 rounded-xl bg-brand-navy/60 border border-brand-border/60 text-[11px] text-brand-muted flex items-start gap-2">
                <Info className="w-4 h-4 text-brand-teal flex-shrink-0 mt-0.5" />
                <span>
                  Community Rule: Keep conversations constructive and friendly. No hate speech, harassment, or private phone numbers.
                </span>
              </div>

              {/* Submit Buttons */}
              <div className="pt-2 flex items-center justify-end gap-2 border-t border-brand-border/60">
                <button
                  type="button"
                  onClick={() => setModalOpen(false)}
                  className="px-4 py-2 rounded-tk-btn border border-brand-border text-brand-muted hover:text-white"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={!postContent.trim()}
                  className="px-5 py-2 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white font-semibold flex items-center gap-1.5 shadow-purple-glow disabled:opacity-50"
                >
                  <Send className="w-3.5 h-3.5" />
                  <span>Publish to Campus</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 5. LIGHTBOX MODAL */}
      {lightboxImage && (
        <div
          className="fixed inset-0 z-50 bg-black/90 backdrop-blur-md flex items-center justify-center p-4 animate-in fade-in"
          onClick={() => setLightboxImage(null)}
        >
          <div className="relative max-w-4xl w-full max-h-[90vh] flex flex-col items-center">
            <button
              onClick={() => setLightboxImage(null)}
              className="absolute -top-10 right-0 p-2 text-white hover:text-brand-purple text-sm font-semibold flex items-center gap-1"
            >
              <X className="w-6 h-6" /> Close
            </button>
            <img
              src={lightboxImage}
              alt="Enlarged tea attachment"
              className="max-h-[85vh] w-auto object-contain rounded-2xl border border-brand-border shadow-2xl"
              onClick={(e) => e.stopPropagation()}
            />
          </div>
        </div>
      )}

      {/* 6. REPORT TEA POST MODAL */}
      {reportingPost && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75 backdrop-blur-sm animate-fade-in">
          <div className="relative w-full max-w-md bg-brand-navy border border-brand-border rounded-2xl p-6 shadow-2xl space-y-4">
            <button
              onClick={() => {
                if (!isSubmittingReport) setReportingPost(null);
              }}
              className="absolute top-4 right-4 p-1.5 rounded-lg text-brand-muted hover:text-white hover:bg-brand-navyCard transition-colors"
            >
              <X className="w-4 h-4" />
            </button>

            <div className="flex items-center gap-3">
              <div className="p-2.5 rounded-full bg-red-500/15 border border-red-500/30 text-red-400">
                <Flag className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-base font-bold text-white">Report Tea Post</h3>
                <p className="text-xs text-brand-muted">Flag post for admin review and moderation</p>
              </div>
            </div>

            {reportSuccessMsg ? (
              <div className="p-4 rounded-xl bg-emerald-500/15 border border-emerald-500/30 text-emerald-400 text-xs font-semibold text-center flex items-center justify-center gap-2">
                <Check className="w-4 h-4" />
                <span>{reportSuccessMsg}</span>
              </div>
            ) : (
              <form onSubmit={handleReportSubmit} className="space-y-4">
                {/* Post snippet */}
                <div className="p-3 rounded-xl bg-brand-navySecondary/60 border border-brand-border/60 text-xs text-brand-muted">
                  <div className="font-semibold text-brand-lavender mb-1">
                    {reportingPost.anonymous_alias || reportingPost.author_name} • {reportingPost.department}
                  </div>
                  <p className="line-clamp-3 text-brand-text">
                    {reportingPost.title ? `${reportingPost.title}: ` : ""}
                    {reportingPost.content}
                  </p>
                </div>

                {/* Reason Selection */}
                <div>
                  <label className="block text-xs font-semibold text-brand-text mb-1.5">
                    Reason for report <span className="text-red-400">*</span>
                  </label>
                  <select
                    value={reportReason}
                    onChange={(e) => setReportReason(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl bg-brand-navyCard border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                  >
                    <option value="Defamation or Personal Target">Defamation or Personal Target</option>
                    <option value="Harassment or Hate Speech">Harassment or Hate Speech</option>
                    <option value="Inappropriate / NSFW Content">Inappropriate / NSFW Content</option>
                    <option value="False Rumors / Misinformation">False Rumors / Misinformation</option>
                    <option value="Spam or Unsolicited Promotion">Spam or Unsolicited Promotion</option>
                    <option value="Other Violation">Other Campus Guideline Violation</option>
                  </select>
                </div>

                {/* Additional Details */}
                <div>
                  <label className="block text-xs font-semibold text-brand-text mb-1.5">
                    Additional Details (Optional)
                  </label>
                  <textarea
                    rows={3}
                    value={reportDetails}
                    onChange={(e) => setReportDetails(e.target.value)}
                    placeholder="Provide additional context to help moderators understand the violation..."
                    className="w-full px-3 py-2 rounded-xl bg-brand-navyCard border border-brand-border text-xs text-white placeholder-brand-muted focus:outline-none focus:border-brand-purple resize-none"
                  />
                </div>

                <div className="flex items-center justify-end gap-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setReportingPost(null)}
                    disabled={isSubmittingReport}
                    className="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:text-white transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={isSubmittingReport}
                    className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-red-600 hover:bg-red-500 text-white text-xs font-semibold transition-all disabled:opacity-50"
                  >
                    {isSubmittingReport ? (
                      <span>Submitting...</span>
                    ) : (
                      <>
                        <Flag className="w-3.5 h-3.5" />
                        <span>Submit Report</span>
                      </>
                    )}
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

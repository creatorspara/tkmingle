"use client";

import React, { useState } from "react";
import Image from "next/image";
import {
  Users2,
  Plus,
  MessageSquare,
  Heart,
  Share2,
  Sparkles,
  Send,
  CheckCircle2,
} from "lucide-react";
import { MOCK_CIRCLES, MOCK_POSTS, CirclePostItem } from "@/lib/mockData";
import { useCurrentUser } from "@/lib/useUser";

export default function CirclesPage() {
  const { user, profile } = useCurrentUser();
  const [selectedCategory, setSelectedCategory] = useState("All");
  const [joinedCircleIds, setJoinedCircleIds] = useState<string[]>([
    MOCK_CIRCLES[1].id,
    MOCK_CIRCLES[2].id,
  ]);
  const [posts, setPosts] = useState<CirclePostItem[]>(MOCK_POSTS);
  const [newPostContent, setNewPostContent] = useState("");
  const [newPostTitle, setNewPostTitle] = useState("");
  const [showPostModal, setShowPostModal] = useState(false);

  const categories = ["All", "Technical", "Entrepreneurship", "Technology", "Engineering", "Cultural"];

  const filteredCircles = MOCK_CIRCLES.filter(
    (c) => selectedCategory === "All" || c.category === selectedCategory
  );

  const handleToggleJoin = (id: string) => {
    if (joinedCircleIds.includes(id)) {
      setJoinedCircleIds(joinedCircleIds.filter((cid) => cid !== id));
    } else {
      setJoinedCircleIds([...joinedCircleIds, id]);
    }
  };

  const handleCreatePost = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newPostContent.trim()) return;

    const newPost: CirclePostItem = {
      id: "p_" + Date.now(),
      circle_id: MOCK_CIRCLES[2].id,
      author_name: profile?.full_name || user?.user_metadata?.full_name || "TKM Student",
      author_image: profile?.profile_image || "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80",
      title: newPostTitle.trim() || "Campus Update",
      content: newPostContent.trim(),
      likes_count: 1,
      comments_count: 0,
      created_at: "Just now",
    };

    setPosts([newPost, ...posts]);
    setNewPostContent("");
    setNewPostTitle("");
    setShowPostModal(false);
  };

  return (
    <div className="p-4 sm:p-6 lg:p-8 max-w-7xl mx-auto space-y-8">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-white">Campus Circles</h1>
          <p className="text-xs text-brand-muted">
            Join technical clubs, hobby societies, and project teams across TKMCE
          </p>
        </div>

        <button
          onClick={() => setShowPostModal(true)}
          className="inline-flex items-center gap-2 px-4 py-2.5 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold shadow-purple-glow transition-all"
        >
          <Plus className="w-4 h-4" /> Start Discussion
        </button>
      </div>

      {/* Categories Bar */}
      <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-none">
        {categories.map((cat) => (
          <button
            key={cat}
            onClick={() => setSelectedCategory(cat)}
            className={`px-3.5 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap transition-all ${
              selectedCategory === cat
                ? "bg-brand-purple text-white shadow-purple-glow"
                : "bg-brand-navyCard text-brand-muted hover:text-white border border-brand-border/70"
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Circles Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredCircles.map((circle) => {
          const isJoined = joinedCircleIds.includes(circle.id);
          return (
            <div
              key={circle.id}
              className="glass-panel glass-panel-hover rounded-tk-card p-5 flex flex-col justify-between space-y-4"
            >
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <div className="w-12 h-12 rounded-2xl bg-brand-purple/20 text-brand-lavender border border-brand-purple/40 flex items-center justify-center font-bold text-lg">
                    {circle.name.charAt(0)}
                  </div>
                  <span className="text-[11px] px-2.5 py-1 rounded-full bg-brand-navyCard border border-brand-border text-brand-teal font-medium">
                    {circle.category}
                  </span>
                </div>
                <div>
                  <h3 className="font-bold text-base text-white">{circle.name}</h3>
                  <p className="text-xs text-brand-muted mt-1 leading-relaxed">
                    {circle.description}
                  </p>
                </div>
              </div>

              <div className="pt-3 border-t border-brand-border/60 flex items-center justify-between">
                <span className="text-xs text-brand-muted font-medium">
                  {circle.member_count} Members
                </span>
                <button
                  onClick={() => handleToggleJoin(circle.id)}
                  className={`px-4 py-1.5 rounded-lg text-xs font-semibold transition-all ${
                    isJoined
                      ? "bg-brand-teal/15 text-brand-teal border border-brand-teal/40"
                      : "bg-brand-purple hover:bg-brand-purple/90 text-white shadow-purple-glow"
                  }`}
                >
                  {isJoined ? "Joined" : "Join Circle"}
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {/* Circle Discussions Feed */}
      <div className="space-y-4 pt-4">
        <div className="flex items-center justify-between">
          <h2 className="text-lg font-bold text-white flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-brand-teal" />
            Recent Campus Discussions
          </h2>
        </div>

        <div className="space-y-4">
          {posts.map((post) => (
            <div
              key={post.id}
              className="glass-panel rounded-tk-card p-5 border border-brand-border/80 space-y-3"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="relative w-9 h-9 rounded-full overflow-hidden border border-brand-border">
                    <Image
                      src={post.author_image}
                      alt={post.author_name}
                      fill
                      className="object-cover"
                    />
                  </div>
                  <div>
                    <div className="font-bold text-xs text-white flex items-center gap-1.5">
                      {post.author_name}
                      <CheckCircle2 className="w-3.5 h-3.5 text-brand-teal" />
                    </div>
                    <div className="text-[10px] text-brand-muted">{post.created_at}</div>
                  </div>
                </div>
              </div>

              {post.title && (
                <h4 className="font-bold text-sm text-white">{post.title}</h4>
              )}
              <p className="text-xs text-brand-text/90 leading-relaxed">
                {post.content}
              </p>

              <div className="pt-2 border-t border-brand-border/40 flex items-center gap-6 text-xs text-brand-muted">
                <button className="flex items-center gap-1.5 hover:text-brand-purple transition-colors">
                  <Heart className="w-4 h-4 text-brand-purple" />
                  <span>{post.likes_count}</span>
                </button>
                <button className="flex items-center gap-1.5 hover:text-brand-teal transition-colors">
                  <MessageSquare className="w-4 h-4 text-brand-teal" />
                  <span>{post.comments_count} replies</span>
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* New Post Modal */}
      {showPostModal && (
        <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-brand-navySecondary border border-brand-border rounded-2xl max-w-md w-full p-6 space-y-4 relative shadow-2xl">
            <h3 className="text-lg font-bold text-white">Post to Campus Circle</h3>
            <form onSubmit={handleCreatePost} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-brand-muted uppercase mb-1">
                  Topic / Title
                </label>
                <input
                  type="text"
                  value={newPostTitle}
                  onChange={(e) => setNewPostTitle(e.target.value)}
                  placeholder="e.g. Project brainstorm, hackathon announcement..."
                  className="w-full px-3 py-2 rounded-tk-btn bg-brand-navyCard border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-brand-muted uppercase mb-1">
                  Message Content
                </label>
                <textarea
                  required
                  rows={4}
                  value={newPostContent}
                  onChange={(e) => setNewPostContent(e.target.value)}
                  placeholder="Share details, questions, or invite peers..."
                  className="w-full px-3 py-2 rounded-tk-btn bg-brand-navyCard border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                />
              </div>

              <div className="flex items-center justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowPostModal(false)}
                  className="px-4 py-2 rounded-lg text-xs font-semibold text-brand-muted hover:text-white"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 rounded-lg bg-brand-purple text-white text-xs font-semibold shadow-purple-glow flex items-center gap-1.5"
                >
                  <Send className="w-3.5 h-3.5" /> Publish
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

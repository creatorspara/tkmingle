"use client";

import React, { useState, useRef, useEffect } from "react";
import Image from "next/image";
import {
  Send,
  CheckCircle2,
  Lock,
  MoreVertical,
  Paperclip,
  Smile,
  ShieldCheck,
} from "lucide-react";
import { MOCK_STUDENTS, MOCK_MESSAGES, ChatMessage } from "@/lib/mockData";
import { useCurrentUser } from "@/lib/useUser";

export default function MessagesPage() {
  const { user, profile } = useCurrentUser();
  const [messages, setMessages] = useState<ChatMessage[]>(MOCK_MESSAGES);
  const [inputText, setInputText] = useState("");
  const activeStudent = MOCK_STUDENTS[1]; // Sneha Varma
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputText.trim()) return;

    const newMsg: ChatMessage = {
      id: "msg_" + Date.now(),
      sender_id: user?.id || "current_user",
      sender_name: profile?.full_name || user?.user_metadata?.full_name || "Me",
      content: inputText.trim(),
      created_at: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
      is_mine: true,
    };

    setMessages([...messages, newMsg]);
    setInputText("");

    // Simulate instant real-time reply from connected student
    setTimeout(() => {
      const replyMsg: ChatMessage = {
        id: "msg_" + (Date.now() + 1),
        sender_id: activeStudent.id,
        sender_name: activeStudent.full_name,
        content: "Awesome! Looking forward to it.",
        created_at: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
        is_mine: false,
      };
      setMessages((prev) => [...prev, replyMsg]);
    }, 1500);
  };

  return (
    <div className="h-[calc(100vh-5rem)] md:h-screen flex flex-col md:flex-row overflow-hidden bg-brand-navy">
      {/* Conversation List Sidebar */}
      <div className="w-full md:w-80 border-r border-brand-border/70 bg-brand-navySecondary flex-shrink-0 flex flex-col">
        <div className="p-4 border-b border-brand-border/60 flex items-center justify-between">
          <h2 className="font-bold text-base text-white">Campus Chats</h2>
          <span className="text-[10px] px-2 py-0.5 rounded-full bg-brand-purple/20 text-brand-lavender font-semibold">
            1 Active
          </span>
        </div>

        {/* Single active chat item */}
        <div className="p-3">
          <div className="flex items-center gap-3 p-3 rounded-tk-card bg-brand-navyCard border border-brand-purple/40 shadow-sm cursor-pointer">
            <div className="relative w-12 h-12 rounded-xl overflow-hidden border border-brand-purple/60">
              <Image
                src={activeStudent.profile_image}
                alt={activeStudent.full_name}
                fill
                className="object-cover"
              />
              <span className="absolute bottom-0.5 right-0.5 w-2.5 h-2.5 rounded-full bg-brand-teal border-2 border-brand-navy" />
            </div>

            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between">
                <span className="font-bold text-xs text-white truncate">
                  {activeStudent.full_name}
                </span>
                <span className="text-[10px] text-brand-muted">Just now</span>
              </div>
              <p className="text-[11px] text-brand-lavender truncate mt-0.5">
                {messages[messages.length - 1].content}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Chat Conversation Pane */}
      <div className="flex-1 flex flex-col min-w-0 bg-brand-navy relative">
        {/* Chat Header */}
        <div className="px-6 py-3.5 bg-brand-navySecondary/90 backdrop-blur-md border-b border-brand-border/70 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="relative w-10 h-10 rounded-xl overflow-hidden border border-brand-purple/50">
              <Image
                src={activeStudent.profile_image}
                alt={activeStudent.full_name}
                fill
                className="object-cover"
              />
            </div>
            <div>
              <div className="font-bold text-sm text-white flex items-center gap-1.5">
                {activeStudent.full_name}
                <CheckCircle2 className="w-3.5 h-3.5 text-brand-teal" />
              </div>
              <div className="text-[10px] text-brand-teal flex items-center gap-1">
                <span>ECE • 3rd Year</span>
                <span>•</span>
                <span className="flex items-center gap-0.5 text-brand-muted">
                  <Lock className="w-3 h-3 text-brand-teal" /> Mutual Connection
                </span>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <span className="hidden sm:inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-brand-navyCard border border-brand-border text-[10px] text-brand-muted">
              <ShieldCheck className="w-3 h-3 text-brand-teal" /> Protected by Supabase RLS
            </span>
          </div>
        </div>

        {/* Message Thread */}
        <div className="flex-1 p-4 sm:p-6 overflow-y-auto space-y-4">
          <div className="text-center my-2">
            <span className="text-[10px] px-3 py-1 rounded-full bg-brand-navyCard border border-brand-border/60 text-brand-muted">
              Connection accepted • Chat unlocked
            </span>
          </div>

          {messages.map((msg) => (
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
                {msg.created_at} {msg.is_mine && "• Delivered"}
              </span>
            </div>
          ))}
          <div ref={messagesEndRef} />
        </div>

        {/* Input Composer */}
        <div className="p-3 sm:p-4 bg-brand-navySecondary border-t border-brand-border/70">
          <form onSubmit={handleSendMessage} className="flex items-center gap-2">
            <input
              type="text"
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              placeholder={`Message ${activeStudent.full_name}...`}
              className="flex-1 px-4 py-2.5 rounded-tk-btn bg-brand-navyCard border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
            />
            <button
              type="submit"
              disabled={!inputText.trim()}
              className="p-2.5 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 disabled:opacity-40 text-white shadow-purple-glow transition-all flex items-center justify-center"
            >
              <Send className="w-4 h-4" />
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

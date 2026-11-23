"use client";

import React from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  Compass,
  Users2,
  MessageSquare,
  User,
  Settings,
  LogOut,
  Bell,
  Sparkles,
  Loader2,
  Coffee,
} from "lucide-react";
import { useCurrentUser } from "@/lib/useUser";
import { fetchReceivedRequests } from "@/lib/connections";
import { supabase } from "@/lib/supabaseClient";
import UserAvatar from "@/components/UserAvatar";

export default function AppLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { user, profile, loading, logout } = useCurrentUser();
  const [incomingCount, setIncomingCount] = React.useState(0);

  React.useEffect(() => {
    if (!user) return;
    let mounted = true;

    async function loadRequests() {
      try {
        const received = await fetchReceivedRequests(user!.id);
        if (mounted) setIncomingCount(received.length);
      } catch (e) {
        // ignore
      }
    }

    loadRequests();

    const channel = supabase
      .channel(`nav_conns_${user.id}`)
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "connection_requests",
          filter: `receiver_id=eq.${user.id}`,
        },
        () => {
          loadRequests();
        }
      )
      .subscribe();

    return () => {
      mounted = false;
      supabase.removeChannel(channel);
    };
  }, [user]);

  const navItems = [
    { label: "Discover", href: "/app/discover", icon: Compass },
    { label: "Campus Circles", href: "/app/circles", icon: Users2 },
    { label: "Spill the Tea ☕", href: "/app/tea", icon: Coffee },
    { label: "Messages", href: "/app/messages", icon: MessageSquare },
    { label: "My Profile", href: "/app/profile", icon: User },
    { label: "Settings", href: "/app/settings", icon: Settings },
  ];

  React.useEffect(() => {
    if (!loading && !user) {
      supabase.auth.getSession().then(({ data }) => {
        if (!data?.session?.user) {
          router.replace("/login");
        }
      });
    }
  }, [loading, user, router]);

  const handleLogout = async () => {
    await logout();
  };

  if (loading || !user) {
    return (
      <div className="min-h-screen bg-brand-navy flex flex-col items-center justify-center text-white">
        <Loader2 className="w-8 h-8 animate-spin text-brand-purple mb-3" />
        <p className="text-xs text-brand-muted">Loading campus portal...</p>
      </div>
    );
  }

  // Fallback display if profile still syncing
  const displayName = profile?.full_name || user?.user_metadata?.full_name || user?.email?.split("@")[0] || "Student";
  const displayDept = profile?.department || user?.user_metadata?.department || "TKMCE";

  return (
    <div className="min-h-screen bg-brand-navy flex flex-col md:flex-row text-brand-text">
      {/* Desktop Sidebar */}
      <aside className="hidden md:flex flex-col w-64 bg-brand-navySecondary border-r border-brand-border/70 flex-shrink-0 justify-between p-4">
        <div className="space-y-6">
          {/* Brand header */}
          <Link href="/" className="flex items-center gap-3 px-2 py-2">
            <div className="w-10 h-10 rounded-xl bg-brand-navyCard border border-brand-border flex items-center justify-center p-1.5 shadow-purple-glow">
              <Image
                src="/images/logo_compact.svg"
                alt="TKMingle"
                width={32}
                height={32}
              />
            </div>
            <div>
              <span className="font-bold text-lg text-white tracking-tight">
                TKM<span className="text-brand-purple">ingle</span>
              </span>
              <span className="block text-[10px] text-brand-teal font-medium uppercase tracking-wide">
                Campus Portal
              </span>
            </div>
          </Link>

          {/* Navigation Items */}
          <nav className="space-y-1">
            {navItems.map((item) => {
              const Icon = item.icon;
              const isActive = pathname.startsWith(item.href);
              const showBadge = item.label === "Discover" && incomingCount > 0;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`flex items-center gap-3 px-3 py-2.5 rounded-tk-btn text-xs font-semibold transition-all ${
                    isActive
                      ? "bg-brand-purple text-white shadow-purple-glow"
                      : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
                  }`}
                >
                  <Icon className="w-4 h-4 flex-shrink-0" />
                  <span className="flex-1">{item.label}</span>
                  {showBadge && (
                    <span className="px-1.5 py-0.5 rounded-full text-[10px] font-bold bg-brand-teal text-brand-navy leading-none animate-pulse">
                      {incomingCount}
                    </span>
                  )}
                </Link>
              );
            })}
          </nav>
        </div>

        {/* Current User Card */}
        <div className="pt-4 border-t border-brand-border/60 space-y-3">
          <div className="flex items-center gap-3 px-2">
            <UserAvatar
              src={profile?.profile_image}
              name={displayName}
              size={36}
              showVerifiedBadge={profile?.verification_status === "verified"}
            />
            <div className="flex-1 min-w-0">
              <div className="font-bold text-xs text-white truncate">
                {displayName}
              </div>
              <div className="text-[10px] text-brand-teal truncate font-medium">
                {profile?.verification_status === "verified" ? "Verified" : "Student"} • {displayDept}
              </div>
            </div>
          </div>

          <button
            onClick={handleLogout}
            className="w-full flex items-center justify-center gap-2 py-2 text-xs font-semibold rounded-lg bg-brand-navyCard hover:bg-brand-navy hover:text-brand-error text-brand-muted transition-colors border border-brand-border/60"
          >
            <LogOut className="w-3.5 h-3.5" />
            Sign Out
          </button>
        </div>
      </aside>

      {/* Mobile Top Header */}
      <header className="md:hidden sticky top-0 z-40 bg-brand-navy/90 backdrop-blur-md border-b border-brand-border px-4 py-3 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-2">
          <Image
            src="/images/logo_compact.svg"
            alt="TKMingle"
            width={28}
            height={28}
          />
          <span className="font-bold text-base text-white">
            TKM<span className="text-brand-purple">ingle</span>
          </span>
        </Link>
        <div className="flex items-center gap-2.5">
          {incomingCount > 0 && (
            <Link
              href="/app/discover"
              className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-brand-purple/20 border border-brand-purple text-xs text-brand-lavender font-semibold animate-pulse"
            >
              <Bell className="w-3.5 h-3.5 text-brand-lavender" />
              <span>{incomingCount}</span>
            </Link>
          )}
          <Link
            href="/app/profile"
            className="relative inline-flex items-center justify-center"
          >
            <UserAvatar
              src={profile?.profile_image}
              name={displayName}
              size={32}
              showVerifiedBadge={profile?.verification_status === "verified"}
            />
          </Link>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 min-w-0 pb-20 md:pb-6 overflow-y-auto">
        {children}
      </main>

      {/* Mobile Bottom Navigation Bar */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 z-40 bg-brand-navySecondary/95 backdrop-blur-lg border-t border-brand-border px-4 py-2.5 flex justify-between items-center">
        {navItems.slice(0, 5).map((item) => {
          const Icon = item.icon;
          const isActive = pathname.startsWith(item.href);
          const showBadge = item.label === "Discover" && incomingCount > 0;
          const mobileLabel = item.label.includes("Tea") ? "Tea ☕" : item.label.split(" ")[0];
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`relative flex flex-col items-center gap-1 text-[10px] font-medium transition-colors ${
                isActive ? "text-brand-purple" : "text-brand-muted"
              }`}
            >
              <div className="relative">
                <Icon className="w-5 h-5" />
                {showBadge && (
                  <span className="absolute -top-1 -right-2 px-1 py-0.2 rounded-full text-[9px] font-bold bg-brand-teal text-brand-navy leading-tight">
                    {incomingCount}
                  </span>
                )}
              </div>
              <span>{mobileLabel}</span>
            </Link>
          );
        })}
      </nav>
    </div>
  );
}

import { supabase, isLiveSupabaseConfigured } from "./supabaseClient";

export type TeaType = "tea" | "quote" | "confession" | "shoutout";
export type AuthorType = "anonymous" | "profiled";

export interface TeaComment {
  id: string;
  author_name: string;
  author_type: AuthorType;
  author_avatar?: string;
  author_alias?: string;
  author_icon?: string;
  content: string;
  created_at: string;
}

export interface TeaItem {
  id: string;
  user_id?: string;
  type: TeaType;
  author_type: AuthorType;
  author_name: string;
  author_username?: string;
  author_dept?: string;
  author_avatar?: string;
  anonymous_alias?: string;
  anonymous_tag?: string;
  anonymous_icon?: string;
  title?: string;
  content: string;
  quote_author?: string;
  image_url?: string;
  department: string;
  likes_count: number;
  fires_count: number;
  comments: TeaComment[];
  allow_comments: boolean;
  created_at: string;
  is_liked_by_me?: boolean;
  is_fired_by_me?: boolean;
}

export interface AnonymousAlias {
  id: string;
  name: string;
  icon: string;
  local_icon: string;
  object_position: string;
}

export const ANONYMOUS_ALIASES: AnonymousAlias[] = [
  {
    id: "damu",
    name: "Dasamoolam Damu",
    icon: "https://malayalidino.webappbazaar.com/img/damulogo.jpg",
    local_icon: "/avatars/aliases/damu.jpg",
    object_position: "center",
  },
  {
    id: "pavanayi",
    name: "Pavanayi",
    icon: "https://images.indianexpress.com/2018/09/captain-raju-7591.jpg",
    local_icon: "/avatars/aliases/pavanayi.jpg",
    object_position: "top",
  },
  {
    id: "ramanan",
    name: "Ramanan",
    icon: "https://mir-s3-cdn-cf.behance.net/projects/404/3fa15995862635.Y3JvcCwxMDgwLDg0NCwwLDExNw.jpg",
    local_icon: "/avatars/aliases/ramanan.jpg",
    object_position: "center",
  },
  {
    id: "appukkuttan",
    name: "Appukkuttan",
    icon: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-1QgEUc0Kk_4wDxwkHOTJtbPJm2blqeP2BU1juLuP6w&s=10",
    local_icon: "/avatars/aliases/appukkuttan.jpg",
    object_position: "center",
  },
  {
    id: "gafoor",
    name: "Gafoor",
    icon: "https://i.ytimg.com/vi/VWENsLwR00Q/hqdefault.jpg",
    local_icon: "/avatars/aliases/gafoor.jpg",
    object_position: "center",
  },
  {
    id: "arakkal_abu",
    name: "Arakkal Abu",
    icon: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpix3vrUAyvxgBGAM9aFrwyo5wv4b2vaB6nJp-db-Tre8SlvyA35aN-rL5&s=10",
    local_icon: "/avatars/aliases/arakkal_abu.jpg",
    object_position: "center",
  },
  {
    id: "shaji_pappan",
    name: "Shaji Pappan",
    icon: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTarKvyIzBQnGZLZZuHZQ4bkLyPAeJIcBXnqDTKEMNung7WTn9Wo8UkeFQ&s=10",
    local_icon: "/avatars/aliases/shaji_pappan.jpg",
    object_position: "center",
  },
  {
    id: "nagavalli",
    name: "Nagavalli",
    icon: "https://mir-s3-cdn-cf.behance.net/project_modules/max_1200_webp/a0004e97160833.5ebe96eff2e5f.jpg",
    local_icon: "/avatars/aliases/nagavalli.webp",
    object_position: "50% 20%",
  },
  {
    id: "kumbidi",
    name: "Kumbidi",
    icon: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKlxTjAe--_NYQq_LhjLrS3QrTOXGeF9VPFcH5exrCg9fkabfZHGbu0rTP&s=10",
    local_icon: "/avatars/aliases/kumbidi.jpg",
    object_position: "center",
  },
  {
    id: "manavalan",
    name: "Manavalan",
    icon: "https://i.pinimg.com/736x/28/40/dd/2840dd7b53519681c94105e8a5739bf8.jpg",
    local_icon: "/avatars/aliases/manavalan.jpg",
    object_position: "50% 18%",
  },
];

export function getAliasByName(name?: string): AnonymousAlias | undefined {
  if (!name) return undefined;
  return ANONYMOUS_ALIASES.find(
    (a) => a.name.toLowerCase() === name.toLowerCase()
  );
}

export const TEST_IMAGE_URL = "https://i.ibb.co/0jBt3Gvm/brand-banner-crop.png";

export const INITIAL_TEA_POSTS: TeaItem[] = [
  {
    id: "tea-1",
    type: "tea",
    author_type: "anonymous",
    author_name: "Anonymous Student",
    anonymous_alias: "Dasamoolam Damu",
    anonymous_icon: "https://malayalidino.webappbazaar.com/img/damulogo.jpg",
    anonymous_tag: "Anonymous • Mech",
    department: "Mechanical Engineering",
    title: "SAE Race Car Prototype Leak 🏎️",
    content: "Spilling fresh tea: The Formula Student crew pulled an all-nighter at the workshop and left the master aero concept mockup right on the projector table! Attached the teaser proof below. Campus racing is about to get intense!",
    image_url: "https://i.ibb.co/0jBt3Gvm/brand-banner-crop.png",
    likes_count: 58,
    fires_count: 32,
    allow_comments: true,
    created_at: "15 minutes ago",
    comments: [
      {
        id: "c-1",
        author_name: "Rahul Menon",
        author_type: "profiled",
        author_avatar: "preset:tk_avatar_04",
        content: "Who took this photo?! Don't reveal our rear wing downforce setup before regional scrutineering! 😅",
        created_at: "8 minutes ago",
      },
      {
        id: "c-2",
        author_name: "Ramanan",
        author_type: "anonymous",
        author_alias: "Ramanan",
        author_icon: "https://mir-s3-cdn-cf.behance.net/projects/404/3fa15995862635.Y3JvcCwxMDgwLDg0NCwwLDExNw.jpg",
        content: "Looks sick though, clean carbon weave render!",
        created_at: "3 minutes ago",
      },
    ],
  },
  {
    id: "tea-2",
    type: "quote",
    author_type: "profiled",
    author_name: "Aditya S.",
    author_username: "aditya_s",
    author_dept: "Computer Science & Engineering",
    author_avatar: "preset:tk_avatar_02",
    department: "Computer Science & Engineering",
    content: "“If your code compiles on the first try with zero warnings, do not celebrate. Close your IDE and start getting suspicious.”",
    quote_author: "Overheard in S6 Advanced Lab during KTU OS internals",
    likes_count: 84,
    fires_count: 45,
    allow_comments: true,
    created_at: "1 hour ago",
    comments: [
      {
        id: "c-3",
        author_name: "Sneha Varma",
        author_type: "profiled",
        author_avatar: "preset:tk_avatar_01",
        content: "Segmentation fault (core dumped) waiting around the corner 💀",
        created_at: "45 minutes ago",
      },
    ],
  },
  {
    id: "tea-3",
    type: "tea",
    author_type: "profiled",
    author_name: "Sneha Varma",
    author_username: "sneha_v",
    author_dept: "Electronics & Communication",
    author_avatar: "preset:tk_avatar_01",
    department: "Campus-wide",
    title: "The Main Canteen Parotta Supremacy ☕",
    content: "Hot take: The 11:15 AM batch of crispy parottas with hot vegetable kurma at the TKMCE main canteen beats any fancy cafe in Karicode or Kollam town. Best ₹30 you can spend between double period lectures.",
    likes_count: 112,
    fires_count: 67,
    allow_comments: true,
    created_at: "3 hours ago",
    comments: [
      {
        id: "c-4",
        author_name: "Dasamoolam Damu",
        author_type: "anonymous",
        author_alias: "Dasamoolam Damu",
        author_icon: "https://malayalidino.webappbazaar.com/img/damulogo.jpg",
        content: "Finally someone speaks the absolute truth. Pair it with the canteen bru coffee and you're set.",
        created_at: "2 hours ago",
      },
    ],
  },
  {
    id: "tea-4",
    type: "quote",
    author_type: "anonymous",
    author_name: "Anonymous Student",
    anonymous_alias: "Nagavalli",
    anonymous_icon: "https://mir-s3-cdn-cf.behance.net/project_modules/max_1200_webp/a0004e97160833.5ebe96eff2e5f.jpg",
    anonymous_tag: "Anonymous • Architecture",
    department: "Architecture",
    content: "“Architecture studio is not a college degree. It is a 24-hour sleep deprivation social experiment disguised as structural aesthetics.”",
    quote_author: "Whispered in Architecture Block Studio at 3:45 AM before final jury",
    likes_count: 96,
    fires_count: 51,
    allow_comments: false,
    created_at: "5 hours ago",
    comments: [],
  },
  {
    id: "tea-5",
    type: "confession",
    author_type: "anonymous",
    author_name: "Anonymous Student",
    anonymous_alias: "Ramanan",
    anonymous_icon: "https://mir-s3-cdn-cf.behance.net/projects/404/3fa15995862635.Y3JvcCwxMDgwLDg0NCwwLDExNw.jpg",
    anonymous_tag: "Anonymous • Electrical",
    department: "Electrical & Electronics",
    title: "To the warrior at the corner library desk 🔌",
    content: "I admire your dedication running at 8:30 AM to secure the only working wall plug in the first floor reference room. But please, if you're going to the canteen for an hour, don't leave just a pencil pouch reserving the entire desk!",
    likes_count: 73,
    fires_count: 29,
    allow_comments: true,
    created_at: "Yesterday",
    comments: [
      {
        id: "c-5",
        author_name: "Aditya S.",
        author_type: "profiled",
        author_avatar: "preset:tk_avatar_02",
        content: "The pencil pouch reservation treaty is sacred on campus law!",
        created_at: "Yesterday",
      },
    ],
  },
];

const LOCAL_STORAGE_KEY = "tkmingle_tea_posts_v4";

export function getStoredTeaPosts(): TeaItem[] {
  if (typeof window === "undefined") return INITIAL_TEA_POSTS;
  try {
    const raw = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (!raw) {
      localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(INITIAL_TEA_POSTS));
      return INITIAL_TEA_POSTS;
    }
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed) && parsed.length > 0) {
      return parsed.map((item: any) => ({
        ...item,
        allow_comments: item.allow_comments !== undefined ? Boolean(item.allow_comments) : true,
      }));
    }
    return INITIAL_TEA_POSTS;
  } catch {
    return INITIAL_TEA_POSTS;
  }
}

export function saveTeaPosts(posts: TeaItem[]): void {
  if (typeof window === "undefined") return;
  try {
    localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(posts));
  } catch (e) {
    console.error("Failed to persist tea posts:", e);
  }
}

export function formatTimeAgo(dateStr: string): string {
  try {
    const date = new Date(dateStr);
    if (isNaN(date.getTime())) return dateStr;
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffSec = Math.floor(diffMs / 1000);
    if (diffSec < 60) return "Just now";
    const diffMin = Math.floor(diffSec / 60);
    if (diffMin < 60) return `${diffMin}m ago`;
    const diffHr = Math.floor(diffMin / 60);
    if (diffHr < 24) return `${diffHr}h ago`;
    const diffDays = Math.floor(diffHr / 24);
    if (diffDays === 1) return "Yesterday";
    if (diffDays < 7) return `${diffDays}d ago`;
    return date.toLocaleDateString();
  } catch {
    return dateStr;
  }
}

export async function fetchLiveTeaPosts(): Promise<TeaItem[]> {
  if (!isLiveSupabaseConfigured()) {
    return getStoredTeaPosts();
  }

  try {
    const { data: postsData, error: postsError } = await supabase
      .from("tea_posts")
      .select("*")
      .order("created_at", { ascending: false });

    if (postsError || !postsData) {
      console.warn("fetchLiveTeaPosts notice:", postsError);
      return getStoredTeaPosts();
    }

    const { data: commentsData } = await supabase
      .from("tea_comments")
      .select("*")
      .order("created_at", { ascending: true });

    const commentsByPost: Record<string, TeaComment[]> = {};
    (commentsData || []).forEach((c: any) => {
      if (!commentsByPost[c.post_id]) commentsByPost[c.post_id] = [];
      commentsByPost[c.post_id].push({
        id: c.id,
        author_name: c.author_name,
        author_type: c.author_type,
        author_avatar: c.author_avatar,
        author_alias: c.anonymous_alias || c.author_name,
        author_icon: c.anonymous_icon,
        content: c.content,
        created_at: formatTimeAgo(c.created_at),
      });
    });

    let likedPostIds = new Set<string>();
    let firedPostIds = new Set<string>();
    if (typeof window !== "undefined") {
      try {
        const storedLikes = localStorage.getItem("tk_liked_tea_post_ids");
        if (storedLikes) likedPostIds = new Set(JSON.parse(storedLikes));
        const storedFires = localStorage.getItem("tk_fired_tea_post_ids");
        if (storedFires) firedPostIds = new Set(JSON.parse(storedFires));
      } catch (_) {}
    }

    const items: TeaItem[] = postsData.map((p: any) => ({
      id: p.id,
      user_id: p.user_id || undefined,
      type: p.type,
      author_type: p.author_type,
      author_name: p.author_name,
      author_username: p.author_username,
      author_dept: p.author_dept,
      author_avatar: p.author_avatar,
      anonymous_alias: p.anonymous_alias,
      anonymous_tag: p.anonymous_tag,
      anonymous_icon: p.anonymous_icon,
      title: p.title,
      content: p.content,
      quote_author: p.quote_author,
      image_url: p.image_url,
      department: p.department,
      likes_count: p.likes_count ?? 0,
      fires_count: p.fires_count ?? 0,
      is_liked_by_me: likedPostIds.has(p.id),
      is_fired_by_me: firedPostIds.has(p.id),
      allow_comments: p.allow_comments !== undefined ? Boolean(p.allow_comments) : true,
      comments: commentsByPost[p.id] || [],
      created_at: formatTimeAgo(p.created_at),
    }));

    saveTeaPosts(items);
    return items;
  } catch (err) {
    console.error("fetchLiveTeaPosts error:", err);
    return getStoredTeaPosts();
  }
}

export async function insertTeaPost(post: TeaItem, userId?: string): Promise<void> {
  if (!isLiveSupabaseConfigured()) return;
  try {
    await supabase.from("tea_posts").insert({
      id: post.id,
      user_id: userId || null,
      type: post.type,
      author_type: post.author_type,
      author_name: post.author_name,
      author_username: post.author_username || null,
      author_dept: post.author_dept || null,
      author_avatar: post.author_avatar || null,
      anonymous_alias: post.anonymous_alias || null,
      anonymous_tag: post.anonymous_tag || null,
      anonymous_icon: post.anonymous_icon || null,
      title: post.title || null,
      content: post.content,
      quote_author: post.quote_author || null,
      image_url: post.image_url || null,
      department: post.department,
      likes_count: post.likes_count,
      fires_count: post.fires_count,
      allow_comments: post.allow_comments,
    });
  } catch (err) {
    console.error("insertTeaPost notice:", err);
  }
}

export async function insertTeaComment(comment: TeaComment, postId: string, userId?: string): Promise<void> {
  if (!isLiveSupabaseConfigured()) return;
  try {
    await supabase.from("tea_comments").insert({
      id: comment.id,
      post_id: postId,
      user_id: userId || null,
      author_type: comment.author_type,
      author_name: comment.author_name,
      author_avatar: comment.author_avatar || null,
      anonymous_alias: comment.author_alias || (comment.author_type === "anonymous" ? comment.author_name : null),
      anonymous_icon: comment.author_icon || null,
      content: comment.content,
    });
  } catch (err) {
    console.error("insertTeaComment notice:", err);
  }
}

export async function toggleTeaCommentsInDb(postId: string, allowComments: boolean, userId?: string): Promise<void> {
  if (!isLiveSupabaseConfigured()) return;
  try {
    let query = supabase.from("tea_posts").update({ allow_comments: allowComments }).eq("id", postId);
    if (userId) {
      query = query.eq("user_id", userId);
    }
    await query;
  } catch (err) {
    console.error("toggleTeaCommentsInDb notice:", err);
  }
}

export async function updateTeaReactionsInDb(
  postId: string,
  likes: number,
  fires: number,
  reactionKind?: "like" | "fire",
  isActive?: boolean,
  userId?: string
): Promise<void> {
  // 1. Update localStorage immediately so reaction survives reload
  if (typeof window !== "undefined" && reactionKind && isActive !== undefined) {
    try {
      const key = reactionKind === "fire" ? "tk_fired_tea_post_ids" : "tk_liked_tea_post_ids";
      const stored = localStorage.getItem(key);
      const set = new Set<string>(stored ? JSON.parse(stored) : []);
      if (isActive) {
        set.add(postId);
      } else {
        set.delete(postId);
      }
      localStorage.setItem(key, JSON.stringify(Array.from(set)));
    } catch (_) {}
  }

  if (!isLiveSupabaseConfigured()) return;

  // 2. Update post reaction counts in tea_posts
  try {
    await supabase.from("tea_posts").update({ likes_count: likes, fires_count: fires }).eq("id", postId);
  } catch (err) {
    console.error("updateTeaReactionsInDb notice:", err);
  }

  // 3. Upsert / delete from tea_reactions table
  if (reactionKind && isActive !== undefined) {
    try {
      const effectiveUserId = userId || (await supabase.auth.getUser()).data?.user?.id;
      if (effectiveUserId) {
        if (isActive) {
          await supabase.from("tea_reactions").upsert(
            {
              post_id: postId,
              user_id: effectiveUserId,
              reaction_type: reactionKind,
            },
            { onConflict: "post_id,user_id,reaction_type" }
          );
        } else {
          await supabase.from("tea_reactions").delete().match({
            post_id: postId,
            user_id: effectiveUserId,
            reaction_type: reactionKind,
          });
        }
      }
    } catch (err) {
      console.warn("tea_reactions sync notice:", err);
    }
  }
}

export interface TeaReport {
  id: string;
  post_id: string;
  reporter_id?: string;
  reporter_name?: string;
  reason: string;
  details?: string;
  post_snippet?: string;
  author_alias?: string;
  status: "pending" | "resolved" | "dismissed";
  created_at: string;
}

export async function reportTeaPost(params: {
  postId: string;
  reason: string;
  details?: string;
  reporterId?: string;
  reporterName?: string;
  postSnippet?: string;
  authorAlias?: string;
}): Promise<void> {
  if (!isLiveSupabaseConfigured()) return;
  try {
    const { error } = await supabase.from("tea_reports").insert({
      post_id: params.postId,
      reason: params.reason,
      details: params.details || null,
      reporter_id: params.reporterId || null,
      reporter_name: params.reporterName || "TKM Student",
      post_snippet: params.postSnippet || null,
      author_alias: params.authorAlias || null,
      status: "pending",
    });
    if (error) {
      console.error("reportTeaPost error:", error);
      throw error;
    }
  } catch (err) {
    console.error("reportTeaPost exception:", err);
    throw err;
  }
}

export async function fetchTeaReportsFromDb(): Promise<TeaReport[]> {
  if (!isLiveSupabaseConfigured()) return [];
  try {
    const { data, error } = await supabase
      .from("tea_reports")
      .select("*")
      .order("created_at", { ascending: false });
    if (error) {
      console.error("fetchTeaReports error:", error);
      return [];
    }
    return data || [];
  } catch (err) {
    console.error("fetchTeaReports exception:", err);
    return [];
  }
}

export async function updateReportStatusInDb(
  reportId: string,
  status: "resolved" | "dismissed",
  deletePostId?: string
): Promise<void> {
  if (!isLiveSupabaseConfigured()) return;
  try {
    const { error } = await supabase.from("tea_reports").update({ status }).eq("id", reportId);
    if (error) {
      console.error("updateReportStatusInDb error:", error);
      throw error;
    }
    if (deletePostId) {
      await supabase.from("tea_posts").delete().eq("id", deletePostId);
    }
  } catch (err) {
    console.error("updateReportStatusInDb exception:", err);
    throw err;
  }
}

export async function deleteTeaPostFromDb(postId: string): Promise<void> {
  if (!isLiveSupabaseConfigured()) return;
  try {
    const { error } = await supabase.from("tea_posts").delete().eq("id", postId);
    if (error) {
      console.error("deleteTeaPostFromDb error:", error);
      throw error;
    }
  } catch (err) {
    console.error("deleteTeaPostFromDb exception:", err);
    throw err;
  }
}

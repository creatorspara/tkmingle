export interface TkAvatar {
  id: string;
  name: string;
  category: "Tech & Code" | "Engineering" | "Arts & Design" | "Science & Maker" | "Campus Life";
  accent: string;
  svgPath: string;
  pngPath: string;
}

export const TK_AVATARS: TkAvatar[] = [
  { id: "tk_avatar_01", name: "Cyber Techie", category: "Tech & Code", accent: "#50D6C2", svgPath: "/avatars/tk_avatar_01.svg", pngPath: "/avatars/tk_avatar_01.png" },
  { id: "tk_avatar_02", name: "Campus Coder", category: "Tech & Code", accent: "#8875FF", svgPath: "/avatars/tk_avatar_02.svg", pngPath: "/avatars/tk_avatar_02.png" },
  { id: "tk_avatar_03", name: "Creative Artist", category: "Arts & Design", accent: "#FF6584", svgPath: "/avatars/tk_avatar_03.svg", pngPath: "/avatars/tk_avatar_03.png" },
  { id: "tk_avatar_04", name: "Robotics Engineer", category: "Engineering", accent: "#FFB84D", svgPath: "/avatars/tk_avatar_04.svg", pngPath: "/avatars/tk_avatar_04.png" },
  { id: "tk_avatar_05", name: "Campus Scholar", category: "Campus Life", accent: "#B9A9FF", svgPath: "/avatars/tk_avatar_05.svg", pngPath: "/avatars/tk_avatar_05.png" },
  { id: "tk_avatar_06", name: "Space Explorer", category: "Science & Maker", accent: "#50D6C2", svgPath: "/avatars/tk_avatar_06.svg", pngPath: "/avatars/tk_avatar_06.png" },
  { id: "tk_avatar_07", name: "Music Producer", category: "Arts & Design", accent: "#EC4899", svgPath: "/avatars/tk_avatar_07.svg", pngPath: "/avatars/tk_avatar_07.png" },
  { id: "tk_avatar_08", name: "Athletic Runner", category: "Campus Life", accent: "#10B981", svgPath: "/avatars/tk_avatar_08.svg", pngPath: "/avatars/tk_avatar_08.png" },
  { id: "tk_avatar_09", name: "Design Architect", category: "Arts & Design", accent: "#38BDF8", svgPath: "/avatars/tk_avatar_09.svg", pngPath: "/avatars/tk_avatar_09.png" },
  { id: "tk_avatar_10", name: "AI Innovator", category: "Tech & Code", accent: "#8875FF", svgPath: "/avatars/tk_avatar_10.svg", pngPath: "/avatars/tk_avatar_10.png" },
  { id: "tk_avatar_11", name: "Eco Pioneer", category: "Science & Maker", accent: "#4ADE80", svgPath: "/avatars/tk_avatar_11.svg", pngPath: "/avatars/tk_avatar_11.png" },
  { id: "tk_avatar_12", name: "Debate Champion", category: "Campus Life", accent: "#F59E0B", svgPath: "/avatars/tk_avatar_12.svg", pngPath: "/avatars/tk_avatar_12.png" },
  { id: "tk_avatar_13", name: "Mechanical Maker", category: "Engineering", accent: "#F97316", svgPath: "/avatars/tk_avatar_13.svg", pngPath: "/avatars/tk_avatar_13.png" },
  { id: "tk_avatar_14", name: "Literature Scribe", category: "Arts & Design", accent: "#C084FC", svgPath: "/avatars/tk_avatar_14.svg", pngPath: "/avatars/tk_avatar_14.png" },
  { id: "tk_avatar_15", name: "Photographer", category: "Arts & Design", accent: "#06B6D4", svgPath: "/avatars/tk_avatar_15.svg", pngPath: "/avatars/tk_avatar_15.png" },
  { id: "tk_avatar_16", name: "Data Scientist", category: "Tech & Code", accent: "#3B82F6", svgPath: "/avatars/tk_avatar_16.svg", pngPath: "/avatars/tk_avatar_16.png" },
  { id: "tk_avatar_17", name: "Quantum Physicist", category: "Science & Maker", accent: "#A855F7", svgPath: "/avatars/tk_avatar_17.svg", pngPath: "/avatars/tk_avatar_17.png" },
  { id: "tk_avatar_18", name: "Game Developer", category: "Tech & Code", accent: "#F43F5E", svgPath: "/avatars/tk_avatar_18.svg", pngPath: "/avatars/tk_avatar_18.png" },
  { id: "tk_avatar_19", name: "Campus Leader", category: "Campus Life", accent: "#EAB308", svgPath: "/avatars/tk_avatar_19.svg", pngPath: "/avatars/tk_avatar_19.png" },
  { id: "tk_avatar_20", name: "Social Explorer", category: "Campus Life", accent: "#8875FF", svgPath: "/avatars/tk_avatar_20.svg", pngPath: "/avatars/tk_avatar_20.png" },
  { id: "tk_avatar_21", name: "Startup Founder", category: "Campus Life", accent: "#14B8A6", svgPath: "/avatars/tk_avatar_21.svg", pngPath: "/avatars/tk_avatar_21.png" },
  { id: "tk_avatar_22", name: "Circuit Hacker", category: "Tech & Code", accent: "#22C55E", svgPath: "/avatars/tk_avatar_22.svg", pngPath: "/avatars/tk_avatar_22.png" },
  { id: "tk_avatar_23", name: "Astronomy Stargazer", category: "Science & Maker", accent: "#818CF8", svgPath: "/avatars/tk_avatar_23.svg", pngPath: "/avatars/tk_avatar_23.png" },
  { id: "tk_avatar_24", name: "TKM Pioneer", category: "Campus Life", accent: "#50D6C2", svgPath: "/avatars/tk_avatar_24.svg", pngPath: "/avatars/tk_avatar_24.png" }
];

const AVATAR_MAP = new Map<string, TkAvatar>(
  TK_AVATARS.map((a) => [a.id, a])
);

export function getTkAvatar(idOrPreset?: string | null): TkAvatar | undefined {
  if (!idOrPreset) return undefined;
  const cleanId = idOrPreset.startsWith("preset:")
    ? idOrPreset.replace("preset:", "")
    : idOrPreset;
  return AVATAR_MAP.get(cleanId);
}

export function isPresetAvatar(value?: string | null): boolean {
  if (!value) return false;
  const cleanId = value.startsWith("preset:") ? value.replace("preset:", "") : value;
  return AVATAR_MAP.has(cleanId);
}

export function getInitials(name?: string | null): string {
  if (!name || !name.trim()) return "?";
  const parts = name.trim().split(/\s+/);
  if (parts.length > 1) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return name.trim().slice(0, 2).toUpperCase();
}

export const BRAND_GRADIENTS = [
  "from-[#8875FF] to-[#50D6C2]", // Violet to Teal
  "from-[#6366F1] to-[#B9A9FF]", // Indigo to Lavender
  "from-[#EC4899] to-[#8875FF]", // Pink to Violet
  "from-[#10B981] to-[#50D6C2]", // Emerald to Teal
  "from-[#F59E0B] to-[#EC4899]", // Amber to Pink
  "from-[#06B6D4] to-[#3B82F6]", // Cyan to Blue
  "from-[#8B5CF6] to-[#D946EF]", // Violet to Fuchsia
  "from-[#14B8A6] to-[#6366F1]", // Teal to Indigo
];

export function getDeterministicGradient(seed?: string | null): string {
  if (!seed) return BRAND_GRADIENTS[0];
  let hash = 0;
  for (let i = 0; i < seed.length; i++) {
    hash = (hash * 31 + seed.charCodeAt(i)) & 0xfffffff;
  }
  return BRAND_GRADIENTS[hash % BRAND_GRADIENTS.length];
}

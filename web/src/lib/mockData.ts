export interface StudentProfile {
  id: string;
  full_name: string;
  username: string;
  department: string;
  academic_year: string;
  bio: string;
  profile_image: string;
  avatar_type?: "upload" | "preset" | "initial";
  avatar_id?: string;
  interests: string[];
  skills: string[];
  languages: string[];
  availability: string;
  discoverable: boolean;
  verification_status: "verified" | "pending" | "rejected" | "suspended";
}

export interface CircleItem {
  id: string;
  name: string;
  slug: string;
  description: string;
  category: string;
  icon: string;
  member_count: number;
}

export interface CirclePostItem {
  id: string;
  circle_id: string;
  author_name: string;
  author_image: string;
  title: string;
  content: string;
  likes_count: number;
  comments_count: number;
  created_at: string;
}

export interface ChatMessage {
  id: string;
  sender_id: string;
  sender_name: string;
  content: string;
  created_at: string;
  is_mine: boolean;
}

export const TKMCE_DEPARTMENTS = [
  "All Departments",
  "Computer Science & Engineering",
  "Electronics & Communication",
  "Mechanical Engineering",
  "Electrical & Electronics",
  "Civil Engineering",
  "Chemical Engineering",
  "Architecture",
  "Computer Applications (MCA)",
];

export const MOCK_STUDENTS: StudentProfile[] = [
  {
    id: "11111111-1111-1111-1111-111111111111",
    full_name: "Arjun Krishna",
    username: "arjun_k",
    department: "Computer Science & Engineering",
    academic_year: "3rd Year",
    bio: "Flutter fanatic & hackathon enthusiast. Looking to meet designers and hardware folks across TKM!",
    profile_image: "preset:tk_avatar_02",
    avatar_type: "preset",
    avatar_id: "tk_avatar_02",
    interests: ["Mobile Dev", "AI/ML", "Hackathons", "Anime", "Football"],
    skills: ["Flutter", "Python", "Dart", "Git"],
    languages: ["English", "Malayalam"],
    availability: "Free after 4:30 PM (Library/Amphi)",
    discoverable: true,
    verification_status: "verified",
  },
  {
    id: "22222222-2222-2222-2222-222222222222",
    full_name: "Sneha Varma",
    username: "sneha_v",
    department: "Electronics & Communication",
    academic_year: "3rd Year",
    bio: "Embedded systems explorer, avid coffee drinker, and casual badminton player. Always curious about creative web projects!",
    profile_image: "preset:tk_avatar_01",
    avatar_type: "preset",
    avatar_id: "tk_avatar_01",
    interests: ["Robotics", "IoT", "UI/UX Design", "Badminton", "Coffee"],
    skills: ["Embedded C", "Arduino", "Figma"],
    languages: ["English", "Malayalam", "Hindi"],
    availability: "Available weekends & evenings",
    discoverable: true,
    verification_status: "verified",
  },
  {
    id: "33333333-3333-3333-3333-333333333333",
    full_name: "Rahul Menon",
    username: "rahul_m",
    department: "Mechanical Engineering",
    academic_year: "4th Year",
    bio: "Formula Student racing team lead. Passionate about 3D printing, aerodynamics, and rock music.",
    profile_image: "preset:tk_avatar_04",
    avatar_type: "preset",
    avatar_id: "tk_avatar_04",
    interests: ["Automotive", "3D Printing", "Rock Music", "Gym", "Robotics"],
    skills: ["SolidWorks", "ANSYS", "Welding"],
    languages: ["English", "Malayalam"],
    availability: "Near Mech Workshop after 5 PM",
    discoverable: true,
    verification_status: "verified",
  },
  {
    id: "44444444-4444-4444-4444-444444444444",
    full_name: "Anjali Nair",
    username: "anjali_arch",
    department: "Architecture",
    academic_year: "2nd Year",
    bio: "Fascinated by Kerala heritage architecture & sustainable urban design. Looking for people who appreciate art and photography.",
    profile_image: "preset:tk_avatar_09",
    avatar_type: "preset",
    avatar_id: "tk_avatar_09",
    interests: ["Architecture", "Photography", "Graphic Design", "Sketching", "Indie Music"],
    skills: ["AutoCAD", "Revit", "Illustrator", "Watercolor"],
    languages: ["English", "Malayalam", "Tamil"],
    availability: "Architecture Block studio hours",
    discoverable: true,
    verification_status: "verified",
  },
  {
    id: "55555555-5555-5555-5555-555555555555",
    full_name: "Rohit Pillai",
    username: "rohit_p",
    department: "Civil Engineering",
    academic_year: "2nd Year",
    bio: "Structural modeling enthusiast, campus quizzer, and avid chess player. Let’s connect for campus events!",
    profile_image: "preset:tk_avatar_16",
    avatar_type: "preset",
    avatar_id: "tk_avatar_16",
    interests: ["Quizzing", "Chess", "Structural Design", "Reading"],
    skills: ["STAAD Pro", "Public Speaking"],
    languages: ["English", "Malayalam"],
    availability: "Library quadrangle afternoons",
    discoverable: true,
    verification_status: "verified",
  },
  {
    id: "66666666-6666-6666-6666-666666666666",
    full_name: "Devika S.",
    username: "devika_chem",
    department: "Chemical Engineering",
    academic_year: "3rd Year",
    bio: "Renewable energy researcher, STEPS volunteer, and lover of classical dance and literature.",
    profile_image: "preset:tk_avatar_11",
    avatar_type: "preset",
    avatar_id: "tk_avatar_11",
    interests: ["Green Energy", "Social Service", "Classical Dance", "Volunteering"],
    skills: ["Lab Research", "Event Management"],
    languages: ["English", "Malayalam"],
    availability: "Open to chat",
    discoverable: true,
    verification_status: "verified",
  },
  {
    id: "77777777-7777-7777-7777-777777777777",
    full_name: "Bilal Mohammed",
    username: "bilal_m",
    department: "Electrical & Electronics",
    academic_year: "1st Year",
    bio: "Freshman discovering TKM! Passionate about electric vehicles, guitar, and web development.",
    profile_image: "preset:tk_avatar_07",
    avatar_type: "preset",
    avatar_id: "tk_avatar_07",
    interests: ["Electric Vehicles", "Guitar", "Web Dev", "Football"],
    skills: ["HTML/CSS", "Python", "Guitar"],
    languages: ["English", "Malayalam"],
    availability: "Hostel 1 evenings",
    discoverable: true,
    verification_status: "verified",
  },
  {
    id: "88888888-8888-8888-8888-888888888888",
    full_name: "Fathima Zahra",
    username: "fathima_z",
    department: "Computer Applications (MCA)",
    academic_year: "1st Year",
    bio: "Full-stack developer building cloud web apps. Excited to collaborate on inter-departmental ideas!",
    profile_image: "preset:tk_avatar_05",
    avatar_type: "preset",
    avatar_id: "tk_avatar_05",
    interests: ["Cloud Computing", "Web Dev", "Cybersecurity", "Podcasts"],
    skills: ["Next.js", "PostgreSQL", "Docker"],
    languages: ["English", "Malayalam"],
    availability: "Available online",
    discoverable: true,
    verification_status: "verified",
  },
];

export const MOCK_CIRCLES: CircleItem[] = [
  {
    id: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
    name: "IEEE TKMCE Student Branch",
    slug: "ieee-tkmce",
    description: "The premier technical society of TKMCE fostering technological innovation across disciplines.",
    category: "Technical",
    icon: "cpu",
    member_count: 142,
  },
  {
    id: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
    name: "IEDC TKMCE",
    slug: "iedc-tkmce",
    description: "Innovation and Entrepreneurship Development Centre. Ideate, incubate, and launch campus startups.",
    category: "Entrepreneurship",
    icon: "rocket",
    member_count: 198,
  },
  {
    id: "cccccccc-cccc-cccc-cccc-cccccccccccc",
    name: "TKM Coding Club (FOSS)",
    slug: "tkm-coding-club",
    description: "Open source enthusiasts, competitive programmers, and developers sharing knowledge and hackathons.",
    category: "Technology",
    icon: "code",
    member_count: 230,
  },
  {
    id: "dddddddd-dddd-dddd-dddd-dddddddddddd",
    name: "RoboTKM",
    slug: "robotkm",
    description: "Hands-on robotics, drone dynamics, autonomous rovers, and mechatronics for collegiate challenges.",
    category: "Engineering",
    icon: "bot",
    member_count: 86,
  },
  {
    id: "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee",
    name: "Chithra & Symphony Arts Club",
    slug: "arts-club-tkm",
    description: "Music, theatre, dance, fine arts, and literary events celebrating the vibrant creative spirit of TKM.",
    category: "Cultural",
    icon: "palette",
    member_count: 175,
  },
];

export const MOCK_POSTS: CirclePostItem[] = [
  {
    id: "p1",
    circle_id: "cccccccc-cccc-cccc-cccc-cccccccccccc",
    author_name: "Arjun Krishna",
    author_image: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=400&q=80",
    title: "HackTKM 2026 Announcement!",
    content: "Hey coders! We are organizing a 24-hour campus hackathon next month at the Diamond Jubilee Complex. Cross-departmental teams are heavily encouraged!",
    likes_count: 42,
    comments_count: 8,
    created_at: "2 hours ago",
  },
  {
    id: "p2",
    circle_id: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
    author_name: "Sneha Varma",
    author_image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80",
    title: "Grant Pitching Session Next Thursday",
    content: "Have a product idea you want to incubate? Submit your one-page abstract by Tuesday to participate in the seed grant review.",
    likes_count: 29,
    comments_count: 5,
    created_at: "5 hours ago",
  },
  {
    id: "p3",
    circle_id: "dddddddd-dddd-dddd-dddd-dddddddddddd",
    author_name: "Rahul Menon",
    author_image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80",
    title: "Line Follower & Combat Bot Workshop",
    content: "Hands-on session this Saturday in the Robotics Lab. Bring your Arduino kits and laptops. Open to all branches!",
    likes_count: 35,
    comments_count: 12,
    created_at: "Yesterday",
  },
];

export const MOCK_MESSAGES: ChatMessage[] = [
  {
    id: "m1",
    sender_id: "22222222-2222-2222-2222-222222222222",
    sender_name: "Sneha Varma",
    content: "Hey Arjun! Saw your post about the campus hackathon.",
    created_at: "2:30 PM",
    is_mine: false,
  },
  {
    id: "m2",
    sender_id: "11111111-1111-1111-1111-111111111111",
    sender_name: "Arjun Krishna",
    content: "Hey Sneha! Yes, we need someone with IoT/hardware skills for the smart campus track.",
    created_at: "2:35 PM",
    is_mine: true,
  },
  {
    id: "m3",
    sender_id: "22222222-2222-2222-2222-222222222222",
    sender_name: "Sneha Varma",
    content: "That sounds awesome! I have been working with ESP32 sensors all semester.",
    created_at: "2:40 PM",
    is_mine: false,
  },
  {
    id: "m4",
    sender_id: "11111111-1111-1111-1111-111111111111",
    sender_name: "Arjun Krishna",
    content: "Sounds like a plan! Let’s meet at the Amphi after 4:30.",
    created_at: "2:45 PM",
    is_mine: true,
  },
];

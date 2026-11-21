"use client";

import React, { useState, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";
import {
  Search,
  Filter,
  CheckCircle2,
  Users2,
  GraduationCap,
  Sparkles,
  Heart,
  X,
  MessageSquare,
  Loader2,
} from "lucide-react";
import { MOCK_STUDENTS, TKMCE_DEPARTMENTS, StudentProfile } from "@/lib/mockData";
import { useCurrentUser } from "@/lib/useUser";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";

export default function DiscoverPage() {
  const { user } = useCurrentUser();
  const [students, setStudents] = useState<StudentProfile[]>([]);
  const [loadingStudents, setLoadingStudents] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedDept, setSelectedDept] = useState("All Departments");
  const [selectedYear, setSelectedYear] = useState("All Years");
  const [requestedIds, setRequestedIds] = useState<string[]>([]);
  const [selectedStudent, setSelectedStudent] = useState<StudentProfile | null>(null);

  const years = ["All Years", "1st Year", "2nd Year", "3rd Year", "4th Year"];

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
            profile_image: p.profile_image || "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80",
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

  // Filter out self (current authenticated user) and match search query and department
  const filteredStudents = students.filter((student) => {
    if (user && student.id === user.id) return false; // exclude self
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

  const handleToggleConnect = (id: string) => {
    if (requestedIds.includes(id)) {
      setRequestedIds(requestedIds.filter((item) => item !== id));
    } else {
      setRequestedIds([...requestedIds, id]);
    }
  };

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
        <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-brand-navyCard border border-brand-border text-xs text-brand-teal font-medium">
          <Sparkles className="w-3.5 h-3.5 text-brand-teal" />
          <span>Showing {filteredStudents.length} verified students</span>
        </div>
      </div>

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
            const isRequested = requestedIds.includes(student.id);
            return (
              <div
                key={student.id}
                className="glass-panel glass-panel-hover rounded-tk-card p-5 flex flex-col justify-between space-y-4"
              >
                <div className="space-y-3">
                  <div className="flex items-center gap-3">
                    <div
                      onClick={() => setSelectedStudent(student)}
                      className="relative w-14 h-14 rounded-2xl overflow-hidden border border-brand-border cursor-pointer hover:border-brand-purple transition-colors"
                    >
                      <Image
                        src={student.profile_image}
                        alt={student.full_name}
                        fill
                        className="object-cover"
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

                {/* Card Footer */}
                <div className="pt-3 border-t border-brand-border/50 space-y-2">
                  <div className="text-[11px] text-brand-muted flex items-center gap-1.5">
                    <GraduationCap className="w-3.5 h-3.5 text-brand-teal" />
                    <span className="truncate">{student.availability}</span>
                  </div>

                  <button
                    onClick={() => handleToggleConnect(student.id)}
                    className={`w-full py-2 rounded-tk-btn text-xs font-semibold transition-all flex items-center justify-center gap-1.5 ${
                      isRequested
                        ? "bg-brand-navySecondary border border-brand-teal text-brand-teal"
                        : "bg-brand-purple hover:bg-brand-purple/90 text-white shadow-purple-glow"
                    }`}
                  >
                    <Users2 className="w-3.5 h-3.5" />
                    {isRequested ? "Request Sent" : "Connect"}
                  </button>
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
              <div className="relative w-16 h-16 rounded-2xl overflow-hidden border border-brand-purple/60">
                <Image
                  src={selectedStudent.profile_image}
                  alt={selectedStudent.full_name}
                  fill
                  className="object-cover"
                />
              </div>
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
              <button
                onClick={() => {
                  handleToggleConnect(selectedStudent.id);
                  setSelectedStudent(null);
                }}
                className="flex-1 py-2.5 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold shadow-purple-glow"
              >
                {requestedIds.includes(selectedStudent.id) ? "Request Pending" : "Send Connection Request"}
              </button>
              <Link
                href={`/app/messages?to=${selectedStudent.id}`}
                className="px-4 py-2.5 rounded-tk-btn bg-brand-navyCard border border-brand-teal/40 hover:border-brand-teal text-brand-teal text-xs font-semibold flex items-center gap-1.5 transition-colors"
              >
                <MessageSquare className="w-3.5 h-3.5" />
                Message
              </Link>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

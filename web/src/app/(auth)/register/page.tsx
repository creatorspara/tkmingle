"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft, User, Mail, Lock, GraduationCap, Building2, Loader2, Sparkles, AlertCircle } from "lucide-react";
import { TKMCE_DEPARTMENTS } from "@/lib/mockData";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";
import { getAuthRedirectUrl } from "@/lib/authConfig";

export default function RegisterPage() {
  const router = useRouter();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [department, setDepartment] = useState(TKMCE_DEPARTMENTS[1]);
  const [academicYear, setAcademicYear] = useState("1st Year");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const years = ["1st Year", "2nd Year", "3rd Year", "4th Year", "Postgraduate / MCA", "PhD Scholar"];

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg(null);

    try {
      if (isLiveSupabaseConfigured()) {
        const emailRedirectTo = getAuthRedirectUrl("/verify-email");
        const { data, error } = await supabase.auth.signUp({
          email: email.trim(),
          password,
          options: {
            emailRedirectTo,
            data: {
              full_name: fullName.trim(),
              department,
              academic_year: academicYear,
            },
          },
        });
        if (error) throw error;
      } else {
        await new Promise((r) => setTimeout(r, 700));
      }
      router.push("/verify-email?email=" + encodeURIComponent(email));
    } catch (err: unknown) {
      setErrorMsg(err instanceof Error ? err.message : "Failed to register");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-brand-navy text-brand-text flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[300px] bg-brand-purple/15 blur-[100px] rounded-full pointer-events-none" />

      <div className="sm:mx-auto sm:w-full sm:max-w-lg relative z-10 px-4">
        <Link
          href="/"
          className="inline-flex items-center gap-1.5 text-xs text-brand-muted hover:text-white mb-6 transition-colors"
        >
          <ArrowLeft className="w-3.5 h-3.5" /> Back to Home
        </Link>

        {/* Brand Header */}
        <div className="text-center space-y-2">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-brand-navyCard border border-brand-border p-2 shadow-purple-glow">
            <Image
              src="/images/logo_compact.svg"
              alt="TKMingle"
              width={40}
              height={40}
            />
          </div>
          <h2 className="text-2xl font-bold tracking-tight text-white">
            Join the TKMCE Community
          </h2>
          <p className="text-xs text-brand-muted">
            Connect across departments, discover project partners and make campus friends
          </p>

          {/* Registration Cap Notice */}
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-teal/10 border border-brand-teal/30 text-[11px] text-brand-teal font-medium mt-1">
            <Sparkles className="w-3.5 h-3.5" />
            <span>Registration Cap: 400 Student Pioneer Cohort</span>
          </div>
        </div>

        {/* Form Box */}
        <div className="mt-6 glass-panel rounded-tk-card p-6 sm:p-8 border border-brand-border/80 shadow-2xl space-y-5">
          {errorMsg && (
            <div className="p-3 rounded-lg bg-brand-error/15 border border-brand-error/30 text-xs text-brand-error flex items-center gap-2">
              <AlertCircle className="w-4 h-4 flex-shrink-0" />
              <span>{errorMsg}</span>
            </div>
          )}

          <form onSubmit={handleRegister} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-brand-muted uppercase tracking-wider mb-1">
                Full Name
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-brand-muted">
                  <User className="w-4 h-4" />
                </div>
                <input
                  type="text"
                  required
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  placeholder="e.g. Arjun Krishna"
                  className="w-full pl-10 pr-3.5 py-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-sm text-white focus:outline-none focus:border-brand-purple focus:ring-1 focus:ring-brand-purple"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-brand-muted uppercase tracking-wider mb-1">
                Campus Email
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-brand-muted">
                  <Mail className="w-4 h-4" />
                </div>
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name.dept@tkmce.ac.in"
                  className="w-full pl-10 pr-3.5 py-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-sm text-white focus:outline-none focus:border-brand-purple focus:ring-1 focus:ring-brand-purple"
                />
              </div>
              <span className="text-[10px] text-brand-muted mt-1 block">
                Official institutional email or verified student address
              </span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-semibold text-brand-muted uppercase tracking-wider mb-1">
                  Department
                </label>
                <div className="relative">
                  <select
                    value={department}
                    onChange={(e) => setDepartment(e.target.value)}
                    className="w-full px-3 py-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                  >
                    {TKMCE_DEPARTMENTS.filter((d) => d !== "All Departments").map((dept) => (
                      <option key={dept} value={dept} className="bg-brand-navy">
                        {dept}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-brand-muted uppercase tracking-wider mb-1">
                  Academic Year
                </label>
                <select
                  value={academicYear}
                  onChange={(e) => setAcademicYear(e.target.value)}
                  className="w-full px-3 py-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                >
                  {years.map((yr) => (
                    <option key={yr} value={yr} className="bg-brand-navy">
                      {yr}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-brand-muted uppercase tracking-wider mb-1">
                Password
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-brand-muted">
                  <Lock className="w-4 h-4" />
                </div>
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="At least 8 characters"
                  minLength={8}
                  className="w-full pl-10 pr-3.5 py-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-sm text-white focus:outline-none focus:border-brand-purple focus:ring-1 focus:ring-brand-purple"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white font-semibold text-sm shadow-purple-glow transition-all flex items-center justify-center gap-2 mt-2"
            >
              {loading ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" /> Registering Profile...
                </>
              ) : (
                "Create Student Account"
              )}
            </button>
          </form>

          <div className="text-center text-xs text-brand-muted pt-2 border-t border-brand-border/60">
            Already have an account?{" "}
            <Link href="/login" className="font-semibold text-brand-lavender hover:text-white">
              Sign In
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}

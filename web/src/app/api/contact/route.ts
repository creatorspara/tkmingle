import { NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";

// Initialize Supabase client
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || "https://mwwjuibehscukzueykjc.supabase.co";
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "";

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { persistSession: false },
});

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { name, email, department, category, message, source } = body;

    if (!message || typeof message !== "string" || !message.trim()) {
      return NextResponse.json(
        { error: "Message content is required" },
        { status: 400 }
      );
    }

    // Strictly enforce anonymity if no name or default name is given
    const rawName = typeof name === "string" ? name.trim() : "";
    const cleanName = rawName.length > 0 ? rawName : "Anonymous Student";
    const cleanEmail = typeof email === "string" && email.trim().length > 0 ? email.trim() : "anonymous@tkmce.ac.in";
    const cleanDept = typeof department === "string" && department.trim().length > 0 ? department.trim() : "TKMCE Campus";
    const cleanCategory = typeof category === "string" && category.trim().length > 0 ? category.trim() : "Suggestions & Feedback";
    const cleanSource = typeof source === "string" && source.trim().length > 0 ? source.trim() : "web_portal";

    // 1. Record inquiry into Supabase database
    let dbSuccess = false;
    try {
      const { error: dbError } = await supabase.from("contact_inquiries").insert({
        name: cleanName,
        email: cleanEmail,
        department: cleanDept,
        category: cleanCategory,
        message: message.trim(),
        status: "unread",
      });

      if (dbError) {
        console.warn("Supabase contact_inquiries insert notice:", dbError.message);
      } else {
        dbSuccess = true;
      }
    } catch (dbErr) {
      console.warn("Supabase insert exception:", dbErr);
    }

    // 2. Dispatch real email notification to tkmmingle@gmail.com
    let emailDispatched = false;
    try {
      const emailPayload = {
        _subject: `[TKMingle Contact] ${cleanCategory} from ${cleanName}`,
        name: cleanName,
        email: cleanEmail,
        category: cleanCategory,
        department: cleanDept,
        source: cleanSource,
        message: message.trim(),
        submitted_at: new Date().toISOString(),
        _replyto: cleanEmail,
        _template: "table",
        _captcha: "false",
      };

      const res = await fetch("https://formsubmit.co/ajax/tkmmingle@gmail.com", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify(emailPayload),
      });

      if (res.ok) {
        emailDispatched = true;
      }
    } catch (mailErr) {
      console.warn("FormSubmit email notification notice:", mailErr);
    }

    // 3. Prepare direct mailto URL fallback
    const mailtoSubject = encodeURIComponent(`[TKMingle] ${cleanCategory} - ${cleanName}`);
    const mailtoBody = encodeURIComponent(
      `Name: ${cleanName}\nEmail: ${cleanEmail}\nDepartment: ${cleanDept}\nCategory: ${cleanCategory}\n\nMessage:\n${message.trim()}`
    );
    const mailtoUrl = `mailto:tkmmingle@gmail.com?subject=${mailtoSubject}&body=${mailtoBody}`;

    return NextResponse.json({
      success: true,
      message: "Message received and forwarded to tkmmingle@gmail.com",
      persisted: dbSuccess,
      emailDispatched: emailDispatched,
      mailtoUrl: mailtoUrl,
    });
  } catch (error: any) {
    console.error("Contact API error:", error);
    return NextResponse.json(
      { error: "Failed to process contact submission", details: error?.message },
      { status: 500 }
    );
  }
}

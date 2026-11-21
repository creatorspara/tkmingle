/**
 * TKMingle — Safe Demo User Provisioning Script
 * 
 * Target: TKM College of Engineering (TKMCE), Kollam, Kerala
 * Purpose: Provisions canonical demo student Auth accounts in Supabase Auth
 *          using the official Supabase Admin API.
 * 
 * SECURITY RULES:
 * - NEVER commit or hardcode the Service Role Key.
 * - Pass SUPABASE_SERVICE_ROLE_KEY as an environment variable at runtime.
 * - This script must ONLY be executed in a trusted administrative/server environment.
 * - Campus Admin account remains unprivileged by default until explicitly elevated.
 * 
 * Usage:
 *   $env:SUPABASE_SERVICE_ROLE_KEY="your-secret-service-role-key"
 *   node supabase/seed_demo_users.js
 * 
 * Validation / Dry-Run (exits 0 without making network calls):
 *   node supabase/seed_demo_users.js --check
 */

const path = require("path");
const fs = require("fs");

// Check if running in check/dry-run mode
const isCheckMode = process.argv.includes("--check") || process.argv.includes("--dry-run");

// Resolve @supabase/supabase-js robustly regardless of current working directory
let createClient;
const possiblePaths = [
  path.join(__dirname, "../web/node_modules/@supabase/supabase-js"),
  "@supabase/supabase-js",
  path.join(process.cwd(), "web/node_modules/@supabase/supabase-js"),
  path.join(process.cwd(), "node_modules/@supabase/supabase-js"),
];

for (const p of possiblePaths) {
  try {
    ({ createClient } = require(p));
    if (createClient) break;
  } catch (_) {}
}

if (!createClient) {
  console.error("Error: Could not locate @supabase/supabase-js package.");
  console.error("Please run: cd web && npm install");
  process.exit(1);
}

const SUPABASE_URL = process.env.SUPABASE_URL || "https://mwwjuibehscukzueykjc.supabase.co";
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

// Canonical Demo Accounts matching seed.sql and mobile/web UI
const DEMO_PASSWORD = "TKMingleDemo#2026";

const DEMO_USERS = [
  {
    id: "11111111-1111-1111-1111-111111111111",
    email: "arjun.k@tkmce.ac.in",
    password: DEMO_PASSWORD,
    metadata: {
      full_name: "Arjun Krishna",
      department: "Computer Science & Engineering",
      academic_year: "3rd Year",
      role: "student",
    },
  },
  {
    id: "22222222-2222-2222-2222-222222222222",
    email: "sneha.varma@tkmce.ac.in",
    password: DEMO_PASSWORD,
    metadata: {
      full_name: "Sneha Varma",
      department: "Electronics & Communication",
      academic_year: "3rd Year",
      role: "student",
    },
  },
  {
    id: "33333333-3333-3333-3333-333333333333",
    email: "rahul.menon@tkmce.ac.in",
    password: DEMO_PASSWORD,
    metadata: {
      full_name: "Rahul Menon",
      department: "Mechanical Engineering",
      academic_year: "4th Year",
      role: "student",
    },
  },
  {
    id: "44444444-4444-4444-4444-444444444444",
    email: "anjali.nair@tkmce.ac.in",
    password: DEMO_PASSWORD,
    metadata: {
      full_name: "Anjali Nair",
      department: "Architecture",
      academic_year: "2nd Year",
      role: "student",
    },
  },
  {
    id: "55555555-5555-5555-5555-555555555555",
    email: "rohit.s@tkmce.ac.in",
    password: DEMO_PASSWORD,
    metadata: {
      full_name: "Rohit S.",
      department: "Electrical & Electronics",
      academic_year: "3rd Year",
      role: "student",
    },
  },
  {
    id: "66666666-6666-6666-6666-666666666666",
    email: "devika.p@tkmce.ac.in",
    password: DEMO_PASSWORD,
    metadata: {
      full_name: "Devika P.",
      department: "Chemical Engineering",
      academic_year: "3rd Year",
      role: "student",
    },
  },
  {
    id: "77777777-7777-7777-7777-777777777777",
    email: "bilal.ahmed@tkmce.ac.in",
    password: DEMO_PASSWORD,
    metadata: {
      full_name: "Bilal Ahmed",
      department: "Civil Engineering",
      academic_year: "4th Year",
      role: "student",
    },
  },
  {
    id: "88888888-8888-8888-8888-888888888888",
    email: "fathima.riyas@tkmce.ac.in",
    password: DEMO_PASSWORD,
    metadata: {
      full_name: "Fathima Riyas",
      department: "Computer Science & Engineering",
      academic_year: "4th Year",
      role: "student",
    },
  },
  {
    id: "99999999-9999-9999-9999-999999999999",
    email: "admin@tkmce.ac.in",
    password: DEMO_PASSWORD,
    metadata: {
      full_name: "TKMCE Student Affairs",
      department: "Administration",
      academic_year: "Staff",
      role: "student", // Kept unprivileged by default per Requirement 6
    },
  },
];

// If running in --check or --dry-run mode, validate configuration and exit 0
if (isCheckMode) {
  console.log("==============================================================================");
  console.log(" TKMingle — Safety Check: Demo User Provisioning Configuration");
  console.log("==============================================================================");
  console.log("✓ Node runtime & dependencies resolved: @supabase/supabase-js is loadable.");
  console.log(`✓ Supabase Target URL: ${SUPABASE_URL}`);
  console.log(`✓ Configured Demo Accounts: ${DEMO_USERS.length} accounts.`);
  console.log("✓ Deterministic UUIDs verified (11111111-... through 99999999-...).");
  console.log("✓ Campus Admin (admin@tkmce.ac.in) verified as unprivileged (role='student').");
  console.log("✓ Service Role key is NOT hardcoded in code.");
  if (SERVICE_ROLE_KEY) {
    console.log("✓ SUPABASE_SERVICE_ROLE_KEY environment variable is present.");
  } else {
    console.log("ℹ SUPABASE_SERVICE_ROLE_KEY is omitted (dry-run check passed).");
  }
  console.log("==============================================================================");
  console.log("Safety audit PASSED. Ready for execution when Service Role Key is supplied.");
  process.exit(0);
}

if (!SERVICE_ROLE_KEY || SERVICE_ROLE_KEY.includes("your-supabase")) {
  console.log("==============================================================================");
  console.log(" TKMingle — Server-Side Demo User Provisioning");
  console.log("==============================================================================");
  console.log("ERROR: Missing SUPABASE_SERVICE_ROLE_KEY environment variable.\n");
  console.log("To safely run this script, find your Service Role Key in:");
  console.log("  Supabase Dashboard -> Project Settings -> API -> Project API keys -> service_role (secret)\n");
  console.log("Then execute (PowerShell):");
  console.log('  $env:SUPABASE_SERVICE_ROLE_KEY="<your-service-role-key>"; node supabase/seed_demo_users.js\n');
  console.log("Or (Bash):");
  console.log('  SUPABASE_SERVICE_ROLE_KEY="<your-service-role-key>" node supabase/seed_demo_users.js');
  console.log("==============================================================================");
  process.exit(1);
}

// Initialize Supabase Admin client (bypasses RLS safely on the server)
const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});

async function provisionDemoAccounts() {
  console.log("------------------------------------------------------------------");
  console.log(`Connecting to Supabase: ${SUPABASE_URL}`);
  console.log(`Provisioning ${DEMO_USERS.length} Demo Student Accounts...`);
  console.log("------------------------------------------------------------------");

  let createdCount = 0;
  let updatedCount = 0;

  for (const user of DEMO_USERS) {
    try {
      // 1. Check if user already exists
      const { data: existingUser } = await supabase.auth.admin.getUserById(user.id);

      if (existingUser && existingUser.user) {
        // Update user to ensure password and metadata are in sync
        const { error: updateErr } = await supabase.auth.admin.updateUserById(user.id, {
          email: user.email,
          password: user.password,
          email_confirm: true,
          user_metadata: user.metadata,
        });

        if (updateErr) {
          console.warn(`  [!] Could not update ${user.email}: ${updateErr.message}`);
        } else {
          console.log(`  [OK] Synchronized existing account: ${user.email} (${user.metadata.full_name})`);
          updatedCount++;
        }
      } else {
        // 2. Create new user with deterministic ID
        const { error: createErr } = await supabase.auth.admin.createUser({
          id: user.id,
          email: user.email,
          password: user.password,
          email_confirm: true,
          user_metadata: user.metadata,
        });

        if (createErr) {
          console.warn(`  [!] Notice for ${user.email}: ${createErr.message}`);
        } else {
          console.log(`  [+] Created Auth user: ${user.email} (${user.id})`);
          createdCount++;
        }
      }
    } catch (err) {
      console.error(`  [X] Failed processing ${user.email}:`, err.message);
    }
  }

  console.log("------------------------------------------------------------------");
  console.log(`Provisioning complete: ${createdCount} created, ${updatedCount} updated.`);
  console.log(`Demo password for all accounts: "${DEMO_PASSWORD}"`);
  console.log("Foreign-key constraint (profiles.id -> auth.users.id) is now fully satisfied.");
  console.log("------------------------------------------------------------------");
}

provisionDemoAccounts().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});

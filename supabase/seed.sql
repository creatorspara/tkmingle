-- ==============================================================================
-- TKMingle — Production Application Seed Data
-- Target Institution: TKM College of Engineering (TKMCE), Kollam, Kerala
-- Description: Fully idempotent application data seed (profiles, circles, memberships,
--              posts, connections, and conversations).
-- 
-- PREREQUISITE:
--   1. You MUST first execute the database migration in the Supabase SQL Editor:
--        supabase/migrations/20261121000001_initial_schema.sql
--   2. Ensure the corresponding Auth users have been provisioned via the Supabase Admin API:
--        $env:SUPABASE_SERVICE_ROLE_KEY="your-key"; node supabase/seed_demo_users.js
--
-- SECURITY COMPLIANCE:
--   - Does NOT directly insert or modify auth.users or auth.identities.
--   - Verifies Auth user existence before linking application profiles.
--   - Does NOT automatically grant admin privileges. Campus administration accounts
--     remain unprivileged until explicitly configured in public.admin_roles by the project owner.
--   - Fully idempotent: Safe to execute multiple times without data duplication.
-- ==============================================================================

-- 0. Safety Guard: Verify that the schema migration has been executed
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'system_settings'
    ) THEN
        RAISE EXCEPTION 'Database schema missing! Please run "supabase/migrations/20261121000001_initial_schema.sql" in the Supabase SQL Editor BEFORE running seed.sql.';
    END IF;
END $$;

-- 1. Initialize Global System Settings for TKMCE
INSERT INTO public.system_settings (
    id,
    registration_enabled,
    registration_cap,
    current_registered_count,
    college_domain,
    require_college_email
)
VALUES ('global', TRUE, 400, 9, 'tkmce.ac.in', FALSE)
ON CONFLICT (id) DO UPDATE SET
    registration_enabled = EXCLUDED.registration_enabled,
    registration_cap = EXCLUDED.registration_cap,
    college_domain = EXCLUDED.college_domain;

-- 2. Execute Application Seed Block
DO $$
DECLARE
    -- Deterministic UUIDs matching Supabase Auth users provisioned by seed_demo_users.js
    uid_arjun   UUID := '11111111-1111-1111-1111-111111111111';
    uid_sneha   UUID := '22222222-2222-2222-2222-222222222222';
    uid_rahul   UUID := '33333333-3333-3333-3333-333333333333';
    uid_anjali  UUID := '44444444-4444-4444-4444-444444444444';
    uid_rohit   UUID := '55555555-5555-5555-5555-555555555555';
    uid_devika  UUID := '66666666-6666-6666-6666-666666666666';
    uid_bilal   UUID := '77777777-7777-7777-7777-777777777777';
    uid_fathima UUID := '88888888-8888-8888-8888-888888888888';
    uid_admin   UUID := '99999999-9999-9999-9999-999999999999';

    -- Circle UUIDs
    cid_ieee     UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    cid_iedc     UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
    cid_coding   UUID := 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    cid_robotics UUID := 'dddddddd-dddd-dddd-dddd-dddddddddddd';
    cid_arts     UUID := 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';

    -- Conversation UUID
    conv_id1     UUID := 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1';
BEGIN
    -- -------------------------------------------------------------------------
    -- Step 2.1: Verify Auth User Existence (Satisfies Foreign Key: profiles.id -> auth.users.id)
    -- -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = uid_arjun) THEN
        RAISE NOTICE 'Notice: Auth user % does not exist in auth.users yet. Please run "node supabase/seed_demo_users.js" first to provision Auth users.', uid_arjun;
    END IF;

    -- -------------------------------------------------------------------------
    -- Step 2.2: Upsert public.profiles (Student Profiles with Rich TKMCE Context)
    -- -------------------------------------------------------------------------
    -- Arjun Krishna (CSE 3rd Year)
    IF EXISTS (SELECT 1 FROM auth.users WHERE id = uid_arjun) THEN
        INSERT INTO public.profiles (
            id, full_name, username, email, department, academic_year, bio, profile_image,
            interests, hobbies, skills, languages, availability, discoverable, verification_status, verification_method, role
        ) VALUES (
            uid_arjun,
            'Arjun Krishna',
            'arjun_k',
            'arjun.k@tkmce.ac.in',
            'Computer Science & Engineering',
            '3rd Year',
            'Flutter fanatic & hackathon enthusiast. Looking to meet designers and hardware folks across TKM!',
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=400&q=80',
            ARRAY['Mobile Dev', 'AI/ML', 'Hackathons', 'Anime', 'Football'],
            ARRAY['Guitar', 'Photography', 'Gaming'],
            ARRAY['Flutter', 'Python', 'Dart', 'Git'],
            ARRAY['English', 'Malayalam'],
            'Free after 4:30 PM (Library/Amphi)',
            TRUE,
            'verified',
            'email_otp',
            'student'
        ) ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            bio = EXCLUDED.bio,
            interests = EXCLUDED.interests,
            skills = EXCLUDED.skills,
            updated_at = NOW();
    END IF;

    -- Sneha Varma (ECE 3rd Year)
    IF EXISTS (SELECT 1 FROM auth.users WHERE id = uid_sneha) THEN
        INSERT INTO public.profiles (
            id, full_name, username, email, department, academic_year, bio, profile_image,
            interests, hobbies, skills, languages, availability, discoverable, verification_status, verification_method, role
        ) VALUES (
            uid_sneha,
            'Sneha Varma',
            'sneha_v',
            'sneha.varma@tkmce.ac.in',
            'Electronics & Communication',
            '3rd Year',
            'Embedded systems explorer, avid coffee drinker, and casual badminton player. Always curious about creative web projects!',
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
            ARRAY['Robotics', 'IoT', 'UI/UX Design', 'Badminton', 'Coffee'],
            ARRAY['Badminton', 'Sketching', 'Music'],
            ARRAY['Embedded C', 'Arduino', 'Figma'],
            ARRAY['English', 'Malayalam', 'Hindi'],
            'Available weekends & evenings',
            TRUE,
            'verified',
            'email_otp',
            'student'
        ) ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            bio = EXCLUDED.bio,
            interests = EXCLUDED.interests,
            skills = EXCLUDED.skills,
            updated_at = NOW();
    END IF;

    -- Rahul Menon (Mechanical 4th Year)
    IF EXISTS (SELECT 1 FROM auth.users WHERE id = uid_rahul) THEN
        INSERT INTO public.profiles (
            id, full_name, username, email, department, academic_year, bio, profile_image,
            interests, hobbies, skills, languages, availability, discoverable, verification_status, verification_method, role
        ) VALUES (
            uid_rahul,
            'Rahul Menon',
            'rahul_m',
            'rahul.menon@tkmce.ac.in',
            'Mechanical Engineering',
            '4th Year',
            'Formula Student racing team lead. Passionate about 3D printing, aerodynamics, and rock music.',
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
            ARRAY['Automotive', '3D Printing', 'Rock Music', 'Gym', 'Robotics'],
            ARRAY['Motorcycling', 'Football', 'Weightlifting'],
            ARRAY['SolidWorks', 'ANSYS', 'Welding'],
            ARRAY['English', 'Malayalam'],
            'Near Mech Workshop after 5 PM',
            TRUE,
            'verified',
            'id_card',
            'student'
        ) ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            bio = EXCLUDED.bio,
            interests = EXCLUDED.interests,
            skills = EXCLUDED.skills,
            updated_at = NOW();
    END IF;

    -- Anjali Nair (Architecture 2nd Year)
    IF EXISTS (SELECT 1 FROM auth.users WHERE id = uid_anjali) THEN
        INSERT INTO public.profiles (
            id, full_name, username, email, department, academic_year, bio, profile_image,
            interests, hobbies, skills, languages, availability, discoverable, verification_status, verification_method, role
        ) VALUES (
            uid_anjali,
            'Anjali Nair',
            'anjali_arch',
            'anjali.nair@tkmce.ac.in',
            'Architecture',
            '2nd Year',
            'Fascinated by Kerala heritage architecture & sustainable urban design. Looking for people who appreciate art and photography.',
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
            ARRAY['Architecture', 'Photography', 'Graphic Design', 'Sketching', 'Indie Music'],
            ARRAY['Watercolor', 'Urban Sketching', 'Reading'],
            ARRAY['AutoCAD', 'Revit', 'Illustrator', 'Watercolor'],
            ARRAY['English', 'Malayalam', 'Tamil'],
            'Architecture Block studio hours',
            TRUE,
            'verified',
            'email_otp',
            'student'
        ) ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            bio = EXCLUDED.bio,
            interests = EXCLUDED.interests,
            skills = EXCLUDED.skills,
            updated_at = NOW();
    END IF;

    -- Rohit S. (Electrical & Electronics 3rd Year)
    IF EXISTS (SELECT 1 FROM auth.users WHERE id = uid_rohit) THEN
        INSERT INTO public.profiles (
            id, full_name, username, email, department, academic_year, bio, profile_image,
            interests, hobbies, skills, languages, availability, discoverable, verification_status, verification_method, role
        ) VALUES (
            uid_rohit,
            'Rohit S.',
            'rohit_eee',
            'rohit.s@tkmce.ac.in',
            'Electrical & Electronics',
            '3rd Year',
            'Power electronics & EV powertrain enthusiast. IEEE PES volunteer. Always up for chai at the Nescafe corner.',
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
            ARRAY['Clean Energy', 'EV Tech', 'Chess', 'Podcasts', 'Debating'],
            ARRAY['Chess', 'Cycling', 'Quizzing'],
            ARRAY['MATLAB', 'Simulink', 'Circuit Design'],
            ARRAY['English', 'Malayalam', 'Hindi'],
            'Nescafe corner between 4 and 5 PM',
            TRUE,
            'verified',
            'email_otp',
            'student'
        ) ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            bio = EXCLUDED.bio,
            interests = EXCLUDED.interests,
            skills = EXCLUDED.skills,
            updated_at = NOW();
    END IF;

    -- Devika P. (Chemical Engineering 3rd Year)
    IF EXISTS (SELECT 1 FROM auth.users WHERE id = uid_devika) THEN
        INSERT INTO public.profiles (
            id, full_name, username, email, department, academic_year, bio, profile_image,
            interests, hobbies, skills, languages, availability, discoverable, verification_status, verification_method, role
        ) VALUES (
            uid_devika,
            'Devika P.',
            'devika_chem',
            'devika.p@tkmce.ac.in',
            'Chemical Engineering',
            '3rd Year',
            'Polymer research & green processing. Classical dancer (Bharatanatyam) and quiz team member.',
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
            ARRAY['Biofuels', 'Classical Dance', 'Quiz', 'Reading', 'Volunteering'],
            ARRAY['Classical Dance', 'Reading', 'Baking'],
            ARRAY['Aspen Plus', 'Data Analysis', 'Python'],
            ARRAY['English', 'Malayalam'],
            'Library 2nd floor window corner',
            TRUE,
            'verified',
            'email_otp',
            'student'
        ) ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            bio = EXCLUDED.bio,
            interests = EXCLUDED.interests,
            skills = EXCLUDED.skills,
            updated_at = NOW();
    END IF;

    -- Bilal Ahmed (Civil Engineering 4th Year)
    IF EXISTS (SELECT 1 FROM auth.users WHERE id = uid_bilal) THEN
        INSERT INTO public.profiles (
            id, full_name, username, email, department, academic_year, bio, profile_image,
            interests, hobbies, skills, languages, availability, discoverable, verification_status, verification_method, role
        ) VALUES (
            uid_bilal,
            'Bilal Ahmed',
            'bilal_civil',
            'bilal.ahmed@tkmce.ac.in',
            'Civil Engineering',
            '4th Year',
            'Structural engineering geek and college cricket team bowler. Interested in BIM and smart building technology.',
            'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=400&q=80',
            ARRAY['Structural Design', 'Cricket', 'BIM', 'Travel', 'Cinematography'],
            ARRAY['Cricket', 'Filmmaking', 'Swimming'],
            ARRAY['ETABS', 'STAAD Pro', 'Revit'],
            ARRAY['English', 'Malayalam', 'Urdu'],
            'College ground after 4:30 PM',
            TRUE,
            'verified',
            'email_otp',
            'student'
        ) ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            bio = EXCLUDED.bio,
            interests = EXCLUDED.interests,
            skills = EXCLUDED.skills,
            updated_at = NOW();
    END IF;

    -- Fathima Riyas (CSE 4th Year)
    IF EXISTS (SELECT 1 FROM auth.users WHERE id = uid_fathima) THEN
        INSERT INTO public.profiles (
            id, full_name, username, email, department, academic_year, bio, profile_image,
            interests, hobbies, skills, languages, availability, discoverable, verification_status, verification_method, role
        ) VALUES (
            uid_fathima,
            'Fathima Riyas',
            'fathima_r',
            'fathima.riyas@tkmce.ac.in',
            'Computer Science & Engineering',
            '4th Year',
            'Full-stack developer, open source contributor, and community organizer at FOSS TKM. Let’s talk Web3 and distributed systems.',
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
            ARRAY['Full Stack', 'Open Source', 'Cybersecurity', 'Coffee', 'Design Systems'],
            ARRAY['Open Source Contributing', 'Writing', 'Travel'],
            ARRAY['Next.js', 'Go', 'Docker', 'PostgreSQL'],
            ARRAY['English', 'Malayalam'],
            'CCF lab or Student Lounge',
            TRUE,
            'verified',
            'email_otp',
            'student'
        ) ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            bio = EXCLUDED.bio,
            interests = EXCLUDED.interests,
            skills = EXCLUDED.skills,
            updated_at = NOW();
    END IF;

    -- Campus Admin (TKMCE Student Affairs) - Kept unprivileged by default
    IF EXISTS (SELECT 1 FROM auth.users WHERE id = uid_admin) THEN
        INSERT INTO public.profiles (
            id, full_name, username, email, department, academic_year, bio, profile_image,
            interests, hobbies, skills, languages, availability, discoverable, verification_status, verification_method, role
        ) VALUES (
            uid_admin,
            'TKMCE Student Affairs',
            'tkmce_admin',
            'admin@tkmce.ac.in',
            'Administration',
            'Staff',
            'Campus administration and student liaison desk for TKM College of Engineering.',
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=400&q=80',
            ARRAY['Campus Affairs', 'Student Verification', 'Community Safety'],
            ARRAY['Community Building'],
            ARRAY['Administration', 'Moderation'],
            ARRAY['English', 'Malayalam'],
            'Administrative hours',
            FALSE,
            'verified',
            'manual_review',
            'student' -- Kept as standard unprivileged role until explicitly elevated by project owner
        ) ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            updated_at = NOW();
    END IF;

    -- -------------------------------------------------------------------------
    -- Step 2.3: Seed Campus Circles
    -- -------------------------------------------------------------------------
    INSERT INTO public.circles (id, name, slug, description, category, icon, created_by, visibility, member_count)
    VALUES 
    (
        cid_ieee,
        'IEEE TKMCE Student Branch',
        'ieee-tkmce',
        'The premier technical society of TKMCE fostering technological innovation and professional excellence across disciplines.',
        'Technical',
        'electrical_services',
        uid_sneha,
        'public',
        142
    ),
    (
        cid_iedc,
        'IEDC TKMCE',
        'iedc-tkmce',
        'Innovation and Entrepreneurship Development Centre. Ideate, incubate, and launch campus startups.',
        'Entrepreneurship',
        'lightbulb',
        uid_arjun,
        'public',
        198
    ),
    (
        cid_coding,
        'TKM Coding Club (FOSS)',
        'tkm-coding-club',
        'Open source enthusiasts, competitive programmers, and developers sharing knowledge, code, and hackathons.',
        'Technology',
        'code',
        uid_fathima,
        'public',
        230
    ),
    (
        cid_robotics,
        'RoboTKM',
        'robotkm',
        'Hands-on robotics, drone dynamics, autonomous rovers, and mechatronics for collegiate challenges.',
        'Engineering',
        'smart_toy',
        uid_rahul,
        'public',
        86
    ),
    (
        cid_arts,
        'Chithra & Symphony Arts Club',
        'arts-club-tkm',
        'Music, theatre, dance, fine arts, and literary events celebrating the vibrant creative spirit of TKM.',
        'Cultural',
        'palette',
        uid_anjali,
        'public',
        175
    )
    ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        member_count = EXCLUDED.member_count;

    -- -------------------------------------------------------------------------
    -- Step 2.4: Seed Circle Memberships (where profiles exist)
    -- -------------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = uid_sneha) THEN
        INSERT INTO public.circle_members (circle_id, user_id, role)
        VALUES (cid_ieee, uid_sneha, 'admin')
        ON CONFLICT (circle_id, user_id) DO NOTHING;
    END IF;

    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = uid_arjun) THEN
        INSERT INTO public.circle_members (circle_id, user_id, role)
        VALUES 
        (cid_ieee, uid_arjun, 'member'),
        (cid_iedc, uid_arjun, 'admin'),
        (cid_coding, uid_arjun, 'moderator')
        ON CONFLICT (circle_id, user_id) DO NOTHING;
    END IF;

    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = uid_fathima) THEN
        INSERT INTO public.circle_members (circle_id, user_id, role)
        VALUES (cid_coding, uid_fathima, 'admin')
        ON CONFLICT (circle_id, user_id) DO NOTHING;
    END IF;

    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = uid_rahul) THEN
        INSERT INTO public.circle_members (circle_id, user_id, role)
        VALUES (cid_robotics, uid_rahul, 'admin')
        ON CONFLICT (circle_id, user_id) DO NOTHING;
    END IF;

    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = uid_anjali) THEN
        INSERT INTO public.circle_members (circle_id, user_id, role)
        VALUES (cid_arts, uid_anjali, 'admin')
        ON CONFLICT (circle_id, user_id) DO NOTHING;
    END IF;

    -- -------------------------------------------------------------------------
    -- Step 2.5: Seed Circle Posts (where authors exist)
    -- -------------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = uid_arjun) THEN
        INSERT INTO public.circle_posts (id, circle_id, author_id, title, content, likes_count, comments_count)
        VALUES 
        (
            'p1111111-1111-1111-1111-111111111111',
            cid_coding,
            uid_arjun,
            'HackTKM 2026 Announcement!',
            'Hey coders! We are organizing a 24-hour campus hackathon next month at the Diamond Jubilee Complex. Cross-departmental teams are heavily encouraged!',
            42,
            8
        ),
        (
            'p2222222-2222-2222-2222-222222222222',
            cid_iedc,
            uid_arjun,
            'Grant Pitching Session Next Thursday',
            'Have a product idea you want to incubate? Submit your one-page abstract by Tuesday to participate in the seed grant review.',
            29,
            5
        )
        ON CONFLICT (id) DO NOTHING;
    END IF;

    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = uid_rahul) THEN
        INSERT INTO public.circle_posts (id, circle_id, author_id, title, content, likes_count, comments_count)
        VALUES 
        (
            'p3333333-3333-3333-3333-333333333333',
            cid_robotics,
            uid_rahul,
            'Line Follower & Combat Bot Workshop',
            'Hands-on session this Saturday in the Robotics Lab. Bring your Arduino kits and laptops. Open to all branches!',
            35,
            12
        )
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- -------------------------------------------------------------------------
    -- Step 2.6: Seed Sample Connection (Arjun <-> Sneha)
    -- Enforces user_one < user_two constraint
    -- -------------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = uid_arjun) AND
       EXISTS (SELECT 1 FROM public.profiles WHERE id = uid_sneha) THEN
        INSERT INTO public.connections (user_one, user_two)
        VALUES (LEAST(uid_arjun, uid_sneha), GREATEST(uid_arjun, uid_sneha))
        ON CONFLICT (user_one, user_two) DO NOTHING;

        -- Seed Sample Conversation & Messages
        INSERT INTO public.conversations (id, is_group, title, last_message_preview, last_message_at)
        VALUES (conv_id1, FALSE, 'Arjun & Sneha', 'Sounds like a plan! Let’s meet at the Amphi after 4:30.', NOW() - INTERVAL '1 hour')
        ON CONFLICT (id) DO UPDATE SET
            last_message_preview = EXCLUDED.last_message_preview;

        INSERT INTO public.conversation_members (conversation_id, user_id)
        VALUES 
        (conv_id1, uid_arjun),
        (conv_id1, uid_sneha)
        ON CONFLICT (conversation_id, user_id) DO NOTHING;

        INSERT INTO public.messages (id, conversation_id, sender_id, content, created_at)
        VALUES 
        ('m1111111-1111-1111-1111-111111111111', conv_id1, uid_sneha, 'Hey Arjun! Saw your post about the campus hackathon.', NOW() - INTERVAL '2 hours'),
        ('m2222222-2222-2222-2222-222222222222', conv_id1, uid_arjun, 'Hey Sneha! Yes, we need someone with IoT/hardware skills for the smart campus track.', NOW() - INTERVAL '1 hour 45 minutes'),
        ('m3333333-3333-3333-3333-333333333333', conv_id1, uid_sneha, 'That sounds awesome! I have been working with ESP32 sensors all semester.', NOW() - INTERVAL '1 hour 30 minutes'),
        ('m4444444-4444-4444-4444-444444444444', conv_id1, uid_arjun, 'Sounds like a plan! Let’s meet at the Amphi after 4:30.', NOW() - INTERVAL '1 hour')
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- NOTE: No automatic admin privileges are assigned.
    -- To grant campus administrative privileges to an account, the project owner
    -- can explicitly insert into public.admin_roles:
    --   INSERT INTO public.admin_roles (user_id, role) VALUES ('<target-uuid>', 'admin');

END $$;

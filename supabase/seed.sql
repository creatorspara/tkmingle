-- ==============================================================================
-- TKMingle — Production Seed Data with Supabase Auth Provisioning
-- Target Institution: TKM College of Engineering (TKMCE), Kollam, Kerala
-- Description: Fully idempotent seed data provisioning auth users, profiles,
--              circles, memberships, posts, connections, and conversations.
-- Demo Credentials for All Accounts:
--   Email:    <username>@tkmce.ac.in (e.g. arjun.k@tkmce.ac.in)
--   Password: TKMingleDemo#2026
-- ==============================================================================

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

-- 2. Execute Demo Account & Community Provisioning Block
DO $$
DECLARE
    -- Deterministic UUIDs for demo accounts
    uid_arjun   UUID := '11111111-1111-1111-1111-111111111111';
    uid_sneha   UUID := '22222222-2222-2222-2222-222222222222';
    uid_rahul   UUID := '33333333-3333-3333-3333-333333333333';
    uid_anjali  UUID := '44444444-4444-4444-4444-444444444444';
    uid_rohit   UUID := '55555555-5555-5555-5555-555555555555';
    uid_devika  UUID := '66666666-6666-6666-6666-666666666666';
    uid_bilal   UUID := '77777777-7777-7777-7777-777777777777';
    uid_fathima UUID := '88888888-8888-8888-8888-888888888888';
    uid_admin   UUID := '99999999-9999-9999-9999-999999999999';

    -- Encrypted demo password: 'TKMingleDemo#2026'
    v_encrypted_pw TEXT;

    -- Circle UUIDs
    cid_ieee     UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    cid_iedc     UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
    cid_coding   UUID := 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    cid_robotics UUID := 'dddddddd-dddd-dddd-dddd-dddddddddddd';
    cid_arts     UUID := 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';

    -- Conversation UUID
    conv_id1     UUID := 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1';
BEGIN
    -- Generate standard bcrypt hash for password 'TKMingleDemo#2026'
    v_encrypted_pw := extensions.crypt('TKMingleDemo#2026', extensions.gen_salt('bf'));

    -- -------------------------------------------------------------------------
    -- Step 2.1: Provision auth.users (Satisfies Foreign Key: profiles.id -> auth.users.id)
    -- -------------------------------------------------------------------------
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    ) VALUES
    ('00000000-0000-0000-0000-000000000000', uid_arjun,   'authenticated', 'authenticated', 'arjun.k@tkmce.ac.in',    v_encrypted_pw, NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"Arjun Krishna","department":"Computer Science & Engineering"}', NOW(), NOW(), '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', uid_sneha,   'authenticated', 'authenticated', 'sneha.varma@tkmce.ac.in', v_encrypted_pw, NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"Sneha Varma","department":"Electronics & Communication"}', NOW(), NOW(), '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', uid_rahul,   'authenticated', 'authenticated', 'rahul.menon@tkmce.ac.in',  v_encrypted_pw, NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"Rahul Menon","department":"Mechanical Engineering"}', NOW(), NOW(), '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', uid_anjali,  'authenticated', 'authenticated', 'anjali.nair@tkmce.ac.in',  v_encrypted_pw, NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"Anjali Nair","department":"Architecture"}', NOW(), NOW(), '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', uid_rohit,   'authenticated', 'authenticated', 'rohit.s@tkmce.ac.in',      v_encrypted_pw, NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"Rohit S.","department":"Electrical & Electronics"}', NOW(), NOW(), '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', uid_devika,  'authenticated', 'authenticated', 'devika.p@tkmce.ac.in',     v_encrypted_pw, NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"Devika P.","department":"Chemical Engineering"}', NOW(), NOW(), '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', uid_bilal,   'authenticated', 'authenticated', 'bilal.ahmed@tkmce.ac.in',  v_encrypted_pw, NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"Bilal Ahmed","department":"Civil Engineering"}', NOW(), NOW(), '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', uid_fathima, 'authenticated', 'authenticated', 'fathima.riyas@tkmce.ac.in', v_encrypted_pw, NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"Fathima Riyas","department":"Computer Science & Engineering"}', NOW(), NOW(), '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', uid_admin,   'authenticated', 'authenticated', 'admin@tkmce.ac.in',        v_encrypted_pw, NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"TKMCE Student Affairs","department":"Administration"}', NOW(), NOW(), '', '', '', '')
    ON CONFLICT (id) DO UPDATE SET
        encrypted_password = EXCLUDED.encrypted_password,
        email_confirmed_at = COALESCE(auth.users.email_confirmed_at, NOW()),
        updated_at = NOW();

    -- -------------------------------------------------------------------------
    -- Step 2.2: Provision auth.identities
    -- -------------------------------------------------------------------------
    INSERT INTO auth.identities (
        id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    ) VALUES
    (uid_arjun::text,   uid_arjun,   format('{"sub":"%s","email":"%s"}', uid_arjun::text,   'arjun.k@tkmce.ac.in')::jsonb,    'email', NOW(), NOW(), NOW()),
    (uid_sneha::text,   uid_sneha,   format('{"sub":"%s","email":"%s"}', uid_sneha::text,   'sneha.varma@tkmce.ac.in')::jsonb, 'email', NOW(), NOW(), NOW()),
    (uid_rahul::text,   uid_rahul,   format('{"sub":"%s","email":"%s"}', uid_rahul::text,   'rahul.menon@tkmce.ac.in')::jsonb,  'email', NOW(), NOW(), NOW()),
    (uid_anjali::text,  uid_anjali,  format('{"sub":"%s","email":"%s"}', uid_anjali::text,  'anjali.nair@tkmce.ac.in')::jsonb,  'email', NOW(), NOW(), NOW()),
    (uid_rohit::text,   uid_rohit,   format('{"sub":"%s","email":"%s"}', uid_rohit::text,   'rohit.s@tkmce.ac.in')::jsonb,      'email', NOW(), NOW(), NOW()),
    (uid_devika::text,  uid_devika,  format('{"sub":"%s","email":"%s"}', uid_devika::text,  'devika.p@tkmce.ac.in')::jsonb,     'email', NOW(), NOW(), NOW()),
    (uid_bilal::text,   uid_bilal,   format('{"sub":"%s","email":"%s"}', uid_bilal::text,   'bilal.ahmed@tkmce.ac.in')::jsonb,  'email', NOW(), NOW(), NOW()),
    (uid_fathima::text, uid_fathima, format('{"sub":"%s","email":"%s"}', uid_fathima::text, 'fathima.riyas@tkmce.ac.in')::jsonb, 'email', NOW(), NOW(), NOW()),
    (uid_admin::text,   uid_admin,   format('{"sub":"%s","email":"%s"}', uid_admin::text,   'admin@tkmce.ac.in')::jsonb,        'email', NOW(), NOW(), NOW())
    ON CONFLICT (provider, id) DO UPDATE SET
        updated_at = NOW();

    -- -------------------------------------------------------------------------
    -- Step 2.3: Provision public.profiles (Student Profiles with Rich TKMCE Context)
    -- -------------------------------------------------------------------------
    -- Arjun Krishna (CSE 3rd Year)
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

    -- Sneha Varma (ECE 3rd Year)
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

    -- Rahul Menon (Mechanical 4th Year)
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

    -- Anjali Nair (Architecture 2nd Year)
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

    -- Rohit S. (Electrical & Electronics 3rd Year)
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

    -- Devika P. (Chemical Engineering 3rd Year)
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

    -- Bilal Ahmed (Civil Engineering 4th Year)
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

    -- Fathima Riyas (CSE 4th Year)
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

    -- Campus Admin (TKMCE Student Affairs)
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
        'Official moderation and community oversight account for TKM College of Engineering social platform.',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=400&q=80',
        ARRAY['Campus Affairs', 'Student Verification', 'Community Safety'],
        ARRAY['Community Building'],
        ARRAY['Administration', 'Moderation'],
        ARRAY['English', 'Malayalam'],
        'Administrative hours',
        FALSE,
        'verified',
        'manual_review',
        'admin'
    ) ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        updated_at = NOW();

    -- -------------------------------------------------------------------------
    -- Step 2.4: Seed Campus Circles
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
    -- Step 2.5: Seed Circle Memberships
    -- -------------------------------------------------------------------------
    INSERT INTO public.circle_members (circle_id, user_id, role)
    VALUES 
    (cid_ieee, uid_sneha, 'admin'),
    (cid_ieee, uid_arjun, 'member'),
    (cid_ieee, uid_bilal, 'member'),
    (cid_iedc, uid_arjun, 'admin'),
    (cid_iedc, uid_sneha, 'member'),
    (cid_coding, uid_fathima, 'admin'),
    (cid_coding, uid_arjun, 'moderator'),
    (cid_robotics, uid_rahul, 'admin'),
    (cid_arts, uid_anjali, 'admin'),
    (cid_arts, uid_devika, 'member')
    ON CONFLICT (circle_id, user_id) DO NOTHING;

    -- -------------------------------------------------------------------------
    -- Step 2.6: Seed Circle Posts
    -- -------------------------------------------------------------------------
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
    ),
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

    -- -------------------------------------------------------------------------
    -- Step 2.7: Seed Sample Connection (Arjun <-> Sneha)
    -- Enforces user_one < user_two constraint
    -- -------------------------------------------------------------------------
    INSERT INTO public.connections (user_one, user_two)
    VALUES (LEAST(uid_arjun, uid_sneha), GREATEST(uid_arjun, uid_sneha))
    ON CONFLICT (user_one, user_two) DO NOTHING;

    -- -------------------------------------------------------------------------
    -- Step 2.8: Seed Sample Conversation & Real-Time Messages
    -- -------------------------------------------------------------------------
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

    -- -------------------------------------------------------------------------
    -- Step 2.9: Isolated Admin Privileges (Requirement 8)
    -- Assigns admin role ONLY to the dedicated admin@tkmce.ac.in account
    -- -------------------------------------------------------------------------
    INSERT INTO public.admin_roles (user_id, role)
    VALUES (uid_admin, 'admin')
    ON CONFLICT (user_id) DO NOTHING;

END $$;

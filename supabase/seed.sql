-- ==============================================================================
-- TKMingle — Realistic Seed Data for TKMCE Community
-- ==============================================================================

-- 1. Ensure System Settings is set for 400 student target
INSERT INTO public.system_settings (id, registration_enabled, registration_cap, current_registered_count, college_domain, require_college_email)
VALUES ('global', TRUE, 400, 10, 'tkmce.ac.in', FALSE)
ON CONFLICT (id) DO UPDATE SET
    registration_enabled = EXCLUDED.registration_enabled,
    registration_cap = EXCLUDED.registration_cap;

-- 2. Fixed UUIDs for Mock Profiles to maintain relationships
DO $$
DECLARE
    uid_arjun UUID := '11111111-1111-1111-1111-111111111111';
    uid_sneha UUID := '22222222-2222-2222-2222-222222222222';
    uid_rahul UUID := '33333333-3333-3333-3333-333333333333';
    uid_anjali UUID := '44444444-4444-4444-4444-444444444444';
    uid_rohit UUID := '55555555-5555-5555-5555-555555555555';
    uid_devika UUID := '66666666-6666-6666-6666-666666666666';
    uid_bilal UUID := '77777777-7777-7777-7777-777777777777';
    uid_fathima UUID := '88888888-8888-8888-8888-888888888888';
    uid_admin UUID := '99999999-9999-9999-9999-999999999999';

    cid_ieee UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    cid_iedc UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
    cid_coding UUID := 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    cid_robotics UUID := 'dddddddd-dddd-dddd-dddd-dddddddddddd';
    cid_arts UUID := 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';

    conv_id1 UUID := 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1';
BEGIN
    -- Seed Sample Auth Users if they exist or insert dummy auth users
    -- Note: When running in Supabase local or cloud, auth.users table is managed by Gotrue.
    -- We insert into profiles directly assuming demo auth or test setup.

    -- Arjun (Current Demo User - CSE 3rd Year)
    INSERT INTO public.profiles (id, full_name, username, email, department, academic_year, bio, profile_image, interests, skills, languages, availability, discoverable, verification_status, role)
    VALUES (
        uid_arjun,
        'Arjun Krishna',
        'arjun_k',
        'arjun.k@tkmce.ac.in',
        'Computer Science & Engineering',
        '3rd Year',
        'Flutter fanatic & hackathon enthusiast. Looking to meet designers and hardware folks across TKM!',
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=400&q=80',
        ARRAY['Mobile Dev', 'AI/ML', 'Hackathons', 'Anime', 'Football'],
        ARRAY['Flutter', 'Python', 'Dart', 'Git'],
        ARRAY['English', 'Malayalam'],
        'Free after 4:30 PM (Library/Amphi)',
        TRUE,
        'verified',
        'student'
    ) ON CONFLICT (id) DO NOTHING;

    -- Sneha (ECE 3rd Year)
    INSERT INTO public.profiles (id, full_name, username, email, department, academic_year, bio, profile_image, interests, skills, languages, availability, discoverable, verification_status, role)
    VALUES (
        uid_sneha,
        'Sneha Varma',
        'sneha_v',
        'sneha.varma@tkmce.ac.in',
        'Electronics & Communication',
        '3rd Year',
        'Embedded systems explorer, avid coffee drinker, and casual badminton player. Always curious about creative web projects!',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
        ARRAY['Robotics', 'IoT', 'UI/UX Design', 'Badminton', 'Coffee'],
        ARRAY['Embedded C', 'Arduino', 'Figma'],
        ARRAY['English', 'Malayalam', 'Hindi'],
        'Available weekends & evenings',
        TRUE,
        'verified',
        'student'
    ) ON CONFLICT (id) DO NOTHING;

    -- Rahul (Mechanical 4th Year)
    INSERT INTO public.profiles (id, full_name, username, email, department, academic_year, bio, profile_image, interests, skills, languages, availability, discoverable, verification_status, role)
    VALUES (
        uid_rahul,
        'Rahul Menon',
        'rahul_m',
        'rahul.menon@tkmce.ac.in',
        'Mechanical Engineering',
        '4th Year',
        'Formula Student racing team lead. Passionate about 3D printing, aerodynamics, and rock music.',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
        ARRAY['Automotive', '3D Printing', 'Rock Music', 'Gym', 'Robotics'],
        ARRAY['SolidWorks', 'ANSYS', 'Welding'],
        ARRAY['English', 'Malayalam'],
        'Near Mech Workshop after 5 PM',
        TRUE,
        'verified',
        'student'
    ) ON CONFLICT (id) DO NOTHING;

    -- Anjali (Architecture 2nd Year)
    INSERT INTO public.profiles (id, full_name, username, email, department, academic_year, bio, profile_image, interests, skills, languages, availability, discoverable, verification_status, role)
    VALUES (
        uid_anjali,
        'Anjali Nair',
        'anjali_arch',
        'anjali.nair@tkmce.ac.in',
        'Architecture',
        '2nd Year',
        'Fascinated by Kerala heritage architecture & sustainable urban design. Looking for people who appreciate art and photography.',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        ARRAY['Architecture', 'Photography', 'Graphic Design', 'Sketching', 'Indie Music'],
        ARRAY['AutoCAD', 'Revit', 'Illustrator', 'Watercolor'],
        ARRAY['English', 'Malayalam', 'Tamil'],
        'Architecture Block studio hours',
        TRUE,
        'verified',
        'student'
    ) ON CONFLICT (id) DO NOTHING;

    -- Rohit (Civil 2nd Year)
    INSERT INTO public.profiles (id, full_name, username, email, department, academic_year, bio, profile_image, interests, skills, languages, availability, discoverable, verification_status, role)
    VALUES (
        uid_rohit,
        'Rohit Pillai',
        'rohit_p',
        'rohit.pillai@tkmce.ac.in',
        'Civil Engineering',
        '2nd Year',
        'Structural modeling enthusiast, campus quizzer, and avid chess player. Let’s connect for campus events!',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
        ARRAY['Quizzing', 'Chess', 'Structural Design', 'Reading'],
        ARRAY['STAAD Pro', 'Public Speaking'],
        ARRAY['English', 'Malayalam'],
        'Library quadrangle afternoons',
        TRUE,
        'verified',
        'student'
    ) ON CONFLICT (id) DO NOTHING;

    -- Devika (Chemical 3rd Year)
    INSERT INTO public.profiles (id, full_name, username, email, department, academic_year, bio, profile_image, interests, skills, languages, availability, discoverable, verification_status, role)
    VALUES (
        uid_devika,
        'Devika S.',
        'devika_chem',
        'devika.s@tkmce.ac.in',
        'Chemical Engineering',
        '3rd Year',
        'Renewable energy researcher, STEPS volunteer, and lover of classical dance and literature.',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
        ARRAY['Green Energy', 'Social Service', 'Classical Dance', 'Volunteering'],
        ARRAY['Lab Research', 'Event Management'],
        ARRAY['English', 'Malayalam'],
        'Open to chat',
        TRUE,
        'verified',
        'student'
    ) ON CONFLICT (id) DO NOTHING;

    -- Bilal (Electrical & Electronics 1st Year)
    INSERT INTO public.profiles (id, full_name, username, email, department, academic_year, bio, profile_image, interests, skills, languages, availability, discoverable, verification_status, role)
    VALUES (
        uid_bilal,
        'Bilal Mohammed',
        'bilal_m',
        'bilal.m@tkmce.ac.in',
        'Electrical & Electronics',
        '1st Year',
        'Freshman discovering TKM! Passionate about electric vehicles, guitar, and web development.',
        'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=400&q=80',
        ARRAY['Electric Vehicles', 'Guitar', 'Web Dev', 'Football'],
        ARRAY['HTML/CSS', 'Python', 'Guitar'],
        ARRAY['English', 'Malayalam'],
        'Hostel 1 evenings',
        TRUE,
        'verified',
        'student'
    ) ON CONFLICT (id) DO NOTHING;

    -- Fathima (MCA 1st Year)
    INSERT INTO public.profiles (id, full_name, username, email, department, academic_year, bio, profile_image, interests, skills, languages, availability, discoverable, verification_status, role)
    VALUES (
        uid_fathima,
        'Fathima Zahra',
        'fathima_z',
        'fathima.z@tkmce.ac.in',
        'Computer Applications (MCA)',
        '1st Year',
        'Full-stack developer building cloud web apps. Excited to collaborate on inter-departmental ideas!',
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
        ARRAY['Cloud Computing', 'Web Dev', 'Cybersecurity', 'Podcasts'],
        ARRAY['Next.js', 'PostgreSQL', 'Docker'],
        ARRAY['English', 'Malayalam'],
        'Available online',
        TRUE,
        'verified',
        'student'
    ) ON CONFLICT (id) DO NOTHING;

    -- Campus Admin
    INSERT INTO public.profiles (id, full_name, username, email, department, academic_year, bio, profile_image, interests, skills, languages, availability, discoverable, verification_status, role)
    VALUES (
        uid_admin,
        'TKMCE Campus Admin',
        'tkmce_admin',
        'admin@tkmce.ac.in',
        'Computer Science & Engineering',
        'Staff / Admin',
        'Official student community administrator for TKMingle campus moderation.',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=400&q=80',
        ARRAY['Campus Governance', 'Community Moderation'],
        ARRAY['Management', 'Verification'],
        ARRAY['English', 'Malayalam'],
        'Administrative hours',
        FALSE,
        'verified',
        'admin'
    ) ON CONFLICT (id) DO NOTHING;

    -- Admin Role assignment
    INSERT INTO public.admin_roles (user_id, role)
    VALUES (uid_admin, 'super_admin')
    ON CONFLICT (user_id) DO NOTHING;

    -- 3. Seed Campus Circles
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
    ON CONFLICT (id) DO NOTHING;

    -- 4. Seed Circle Memberships
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

    -- 5. Seed Circle Posts
    INSERT INTO public.circle_posts (circle_id, author_id, title, content, likes_count, comments_count)
    VALUES 
    (
        cid_coding,
        uid_arjun,
        'HackTKM 2026 Announcement!',
        'Hey coders! We are organizing a 24-hour campus hackathon next month at the Diamond Jubilee Complex. Cross-departmental teams are heavily encouraged!',
        42,
        8
    ),
    (
        cid_iedc,
        uid_arjun,
        'Grant Pitching Session Next Thursday',
        'Have a product idea you want to incubate? Submit your one-page abstract by Tuesday to participate in the seed grant review.',
        29,
        5
    ),
    (
        cid_robotics,
        uid_rahul,
        'Line Follower & Combat Bot Workshop',
        'Hands-on session this Saturday in the Robotics Lab. Bring your Arduino kits and laptops. Open to all branches!',
        35,
        12
    )
    ON CONFLICT (id) DO NOTHING;

    -- 6. Seed Sample Connection between Arjun and Sneha
    INSERT INTO public.connections (user_one, user_two)
    VALUES (LEAST(uid_arjun, uid_sneha), GREATEST(uid_arjun, uid_sneha))
    ON CONFLICT (user_one, user_two) DO NOTHING;

    -- 7. Seed Sample Conversation and Messages
    INSERT INTO public.conversations (id, is_group, title, last_message_preview)
    VALUES (conv_id1, FALSE, 'Arjun & Sneha', 'Sounds like a plan! Let’s meet at the Amphi after 4:30.')
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO public.conversation_members (conversation_id, user_id)
    VALUES 
    (conv_id1, uid_arjun),
    (conv_id1, uid_sneha)
    ON CONFLICT (conversation_id, user_id) DO NOTHING;

    INSERT INTO public.messages (conversation_id, sender_id, content, created_at)
    VALUES 
    (conv_id1, uid_sneha, 'Hey Arjun! Saw your post about the campus hackathon.', NOW() - INTERVAL '2 hours'),
    (conv_id1, uid_arjun, 'Hey Sneha! Yes, we need someone with IoT/hardware skills for the smart campus track.', NOW() - INTERVAL '1 hour 45 minutes'),
    (conv_id1, uid_sneha, 'That sounds awesome! I have been working with ESP32 sensors all semester.', NOW() - INTERVAL '1 hour 30 minutes'),
    (conv_id1, uid_arjun, 'Sounds like a plan! Let’s meet at the Amphi after 4:30.', NOW() - INTERVAL '1 hour')
    ON CONFLICT (id) DO NOTHING;

END $$;

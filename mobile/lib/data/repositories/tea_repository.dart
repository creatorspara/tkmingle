import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/tea_post_model.dart';

class TeaRepository {
  final SupabaseClient? _supabase;

  TeaRepository({SupabaseClient? supabase})
      : _supabase = supabase ??
            (AppConstants.isSupabaseConfigured ? Supabase.instance.client : null);

  bool get isLive => _supabase != null;

  /// Fetch all posts ordered by creation date desc, with user reactions hydrated
  Future<List<TeaPost>> getTeaPosts() async {
    final client = _supabase;
    if (client == null) {
      return _getSeedPosts();
    }

    try {
      final postsRes = await client
          .from('tea_posts')
          .select()
          .order('created_at', ascending: false);

      final commentsRes = await client
          .from('tea_comments')
          .select()
          .order('created_at', ascending: true);

      final Map<String, List<TeaComment>> commentsMap = {};
      for (final raw in (commentsRes as List)) {
        final comment = TeaComment.fromJson(Map<String, dynamic>.from(raw));
        commentsMap.putIfAbsent(comment.postId, () => []).add(comment);
      }

      // Hydrate user reaction state from SharedPreferences (local persistence across reloads)
      final prefs = await SharedPreferences.getInstance();
      final likedIds = (prefs.getStringList('tk_liked_tea_post_ids') ?? []).toSet();
      final firedIds = (prefs.getStringList('tk_fired_tea_post_ids') ?? []).toSet();

      // Optionally sync from Supabase tea_reactions if user has active session
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId != null && currentUserId.isNotEmpty) {
        try {
          final reactionsRes = await client
              .from('tea_reactions')
              .select('post_id, reaction_type')
              .eq('user_id', currentUserId);
          for (final r in (reactionsRes as List)) {
            final pid = r['post_id']?.toString();
            final type = r['reaction_type']?.toString();
            if (pid != null) {
              if (type == 'like') likedIds.add(pid);
              if (type == 'fire') firedIds.add(pid);
            }
          }
        } catch (_) {}
      }

      final List<TeaPost> posts = [];
      for (final raw in (postsRes as List)) {
        final id = raw['id']?.toString() ?? '';
        final post = TeaPost.fromJson(
          Map<String, dynamic>.from(raw),
          comments: commentsMap[id] ?? [],
        ).copyWith(
          isLiked: likedIds.contains(id),
          isFired: firedIds.contains(id),
        );
        posts.add(post);
      }

      if (posts.isEmpty) {
        return _getSeedPosts();
      }
      return posts;
    } catch (e) {
      debugPrint('Error loading tea posts from Supabase: $e');
      return _getSeedPosts();
    }
  }

  static final RegExp _uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

  /// Create a new tea post
  Future<void> createPost(TeaPost post, {String? userId}) async {
    final client = _supabase;
    if (client == null) return;
    try {
      final payload = post.toJson();
      if (userId != null && userId.isNotEmpty && _uuidRegex.hasMatch(userId)) {
        payload['user_id'] = userId;
      } else {
        payload['user_id'] = null;
      }
      await client.from('tea_posts').insert(payload);
    } catch (e) {
      debugPrint('Error inserting tea post: $e');
      try {
        final fallback = post.toJson();
        fallback['user_id'] = null;
        await client.from('tea_posts').insert(fallback);
      } catch (inner) {
        debugPrint('Fallback error inserting tea post: $inner');
        rethrow;
      }
    }
  }

  /// Add a comment to a post
  Future<void> addComment(TeaComment comment, {String? userId}) async {
    final client = _supabase;
    if (client == null) return;
    try {
      final payload = comment.toJson();
      if (comment.authorType != 'anonymous' &&
          userId != null &&
          userId.isNotEmpty &&
          _uuidRegex.hasMatch(userId)) {
        payload['user_id'] = userId;
      } else {
        payload['user_id'] = null;
      }
      await client.from('tea_comments').insert(payload);
    } catch (e) {
      debugPrint('Error inserting tea comment with user_id: $e');
      try {
        final fallback = comment.toJson();
        fallback['user_id'] = null;
        await client.from('tea_comments').insert(fallback);
      } catch (inner) {
        debugPrint('Fallback error inserting tea comment: $inner');
        rethrow;
      }
    }
  }

  /// Update reaction state persistently in both SharedPreferences and Supabase
  Future<void> updateReactionState({
    required String postId,
    required bool isFire,
    required bool isActive,
    required int likesCount,
    required int firesCount,
    String? userId,
  }) async {
    // 1. Persist locally to SharedPreferences (immediate and survives reload/restart)
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = isFire ? 'tk_fired_tea_post_ids' : 'tk_liked_tea_post_ids';
      final ids = (prefs.getStringList(key) ?? []).toSet();
      if (isActive) {
        ids.add(postId);
      } else {
        ids.remove(postId);
      }
      await prefs.setStringList(key, ids.toList());
    } catch (e) {
      debugPrint('Error updating local reaction prefs: $e');
    }

    final client = _supabase;
    if (client == null) return;

    // 2. Update post reaction counts in tea_posts
    try {
      await client.from('tea_posts').update({
        'likes_count': likesCount,
        'fires_count': firesCount,
      }).eq('id', postId);
    } catch (e) {
      debugPrint('Error updating tea reactions in tea_posts: $e');
    }

    // 3. Persist individual reaction in tea_reactions table
    final effectiveUserId = userId ?? client.auth.currentUser?.id;
    if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
      final reactionType = isFire ? 'fire' : 'like';
      try {
        if (isActive) {
          await client.from('tea_reactions').upsert({
            'post_id': postId,
            'user_id': effectiveUserId,
            'reaction_type': reactionType,
          }, onConflict: 'post_id,user_id,reaction_type');
        } else {
          await client.from('tea_reactions').delete().match({
            'post_id': postId,
            'user_id': effectiveUserId,
            'reaction_type': reactionType,
          });
        }
      } catch (e) {
        debugPrint('Error updating tea_reactions table: $e');
      }
    }
  }

  /// Update like and fire reactions
  Future<void> updateReactions(String postId, int likes, int fires) async {
    final client = _supabase;
    if (client == null) return;
    try {
      await client.from('tea_posts').update({
        'likes_count': likes,
        'fires_count': fires,
      }).eq('id', postId);
    } catch (e) {
      debugPrint('Error updating tea reactions: $e');
    }
  }

  /// Toggle comments ON/OFF (strictly restricted to the post author)
  Future<void> toggleComments(String postId, bool allowComments, {String? userId}) async {
    final client = _supabase;
    if (client == null) return;
    try {
      var query = client.from('tea_posts').update({
        'allow_comments': allowComments,
      }).eq('id', postId);

      if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }

      await query;
    } catch (e) {
      debugPrint('Error updating allow_comments: $e');
    }
  }

  /// Submit a report on a tea post to admin
  Future<void> reportPost({
    required String postId,
    required String reason,
    String? details,
    String? reporterId,
    String? reporterName,
    String? postSnippet,
    String? authorAlias,
  }) async {
    final client = _supabase;
    if (client == null) return;
    try {
      await client.from('tea_reports').insert({
        'post_id': postId,
        'reason': reason,
        'details': details,
        'reporter_id': reporterId,
        'reporter_name': reporterName,
        'post_snippet': postSnippet,
        'author_alias': authorAlias,
        'status': 'pending',
      });
    } catch (e) {
      debugPrint('Error reporting tea post: $e');
      rethrow;
    }
  }

  List<TeaPost> _getSeedPosts() {
    return [
      TeaPost(
        id: 'tea-1',
        type: 'tea',
        authorType: 'anonymous',
        authorName: 'Anonymous Student',
        anonymousAlias: 'Dasamoolam Damu',
        anonymousIcon: 'https://malayalidino.webappbazaar.com/img/damulogo.jpg',
        anonymousTag: 'Anonymous • Mechanical',
        department: 'Mechanical Engineering',
        title: 'SAE Race Car Prototype Leak 🏎️',
        content:
            'Spilling fresh tea: The Formula Student crew pulled an all-nighter at the workshop and left the master aero concept mockup right on the projector table! Attached the teaser proof below. Campus racing is about to get intense!',
        imageUrl: 'https://i.ibb.co/0jBt3Gvm/brand-banner-crop.png',
        likesCount: 58,
        firesCount: 32,
        allowComments: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        comments: [
          TeaComment(
            id: 'c-1',
            postId: 'tea-1',
            authorType: 'profiled',
            authorName: 'Rahul Menon',
            content:
                "Who took this photo?! Don't reveal our rear wing downforce setup before regional scrutineering! 😅",
            createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
          ),
          TeaComment(
            id: 'c-2',
            postId: 'tea-1',
            authorType: 'anonymous',
            authorName: 'Ramanan',
            authorAlias: 'Ramanan',
            authorIcon: 'https://mir-s3-cdn-cf.behance.net/projects/404/3fa15995862635.Y3JvcCwxMDgwLDg0NCwwLDExNw.jpg',
            content: 'Looks sick though, clean carbon weave render!',
            createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
          ),
        ],
      ),
      TeaPost(
        id: 'tea-2',
        type: 'quote',
        authorType: 'profiled',
        authorName: 'Aditya S.',
        authorUsername: 'aditya_s',
        authorDept: 'Computer Science & Engineering',
        department: 'Computer Science & Engineering',
        content:
            '“If your code compiles on the first try with zero warnings, do not celebrate. Close your IDE and start getting suspicious.”',
        quoteAuthor: 'Overheard in S6 Advanced Lab during KTU OS internals',
        likesCount: 84,
        firesCount: 45,
        allowComments: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      TeaPost(
        id: 'tea-3',
        type: 'tea',
        authorType: 'profiled',
        authorName: 'Sneha Varma',
        authorUsername: 'sneha_v',
        authorDept: 'Electronics & Communication',
        department: 'Campus-wide',
        title: 'The Main Canteen Parotta Supremacy ☕',
        content:
            'Hot take: The 11:15 AM batch of crispy parottas with hot vegetable kurma at the TKMCE main canteen beats any fancy cafe in Karicode or Kollam town. Best ₹30 you can spend between double period lectures.',
        likesCount: 112,
        firesCount: 67,
        allowComments: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      TeaPost(
        id: 'tea-4',
        type: 'quote',
        authorType: 'anonymous',
        authorName: 'Anonymous Student',
        anonymousAlias: 'Nagavalli',
        anonymousIcon: 'https://mir-s3-cdn-cf.behance.net/project_modules/max_1200_webp/a0004e97160833.5ebe96eff2e5f.jpg',
        anonymousTag: 'Anonymous • Architecture',
        department: 'Architecture',
        content:
            '“Architecture studio is not a college degree. It is a 24-hour sleep deprivation social experiment disguised as structural aesthetics.”',
        quoteAuthor: 'Whispered in Architecture Block Studio at 3:45 AM before final jury',
        likesCount: 96,
        firesCount: 51,
        allowComments: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}

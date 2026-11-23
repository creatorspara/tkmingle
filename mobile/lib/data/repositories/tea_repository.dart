import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/tea_post_model.dart';

class TeaRepository {
  final SupabaseClient? _supabase;

  TeaRepository({SupabaseClient? supabase})
      : _supabase = supabase ??
            (AppConstants.isSupabaseConfigured ? Supabase.instance.client : null);

  bool get isLive => _supabase != null;

  /// Fetch all posts ordered by creation date desc
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

      final List<TeaPost> posts = [];
      for (final raw in (postsRes as List)) {
        final id = raw['id']?.toString() ?? '';
        final post = TeaPost.fromJson(
          Map<String, dynamic>.from(raw),
          comments: commentsMap[id] ?? [],
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

  /// Create a new tea post
  Future<void> createPost(TeaPost post, {String? userId}) async {
    final client = _supabase;
    if (client == null) return;
    try {
      final payload = post.toJson();
      if (userId != null && userId.isNotEmpty) {
        payload['user_id'] = userId;
      }
      await client.from('tea_posts').insert(payload);
    } catch (e) {
      debugPrint('Error inserting tea post: $e');
      rethrow;
    }
  }

  /// Add a comment to a post
  Future<void> addComment(TeaComment comment, {String? userId}) async {
    final client = _supabase;
    if (client == null) return;
    try {
      final payload = comment.toJson();
      if (userId != null && userId.isNotEmpty) {
        payload['user_id'] = userId;
      }
      await client.from('tea_comments').insert(payload);
    } catch (e) {
      debugPrint('Error inserting tea comment: $e');
      rethrow;
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

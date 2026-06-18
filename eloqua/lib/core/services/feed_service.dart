import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Keep this in sync with _mainBase in api_service.dart.
const String _feedBase =
    'https://eloqua-parallel.onrender.com';

// ── FeedComment ───────────────────────────────────────────────────────────────
class FeedComment {
  final String id;
  final String userName;
  final String text;
  final DateTime postedAt;

  const FeedComment({
    required this.id,
    required this.userName,
    required this.text,
    required this.postedAt,
  });

  factory FeedComment.fromJson(Map<String, dynamic> j) => FeedComment(
        id: j['id'] as String,
        userName: j['userName'] as String,
        text: j['text'] as String,
        postedAt: DateTime.parse(j['postedAt'] as String),
      );
}

// ── FeedPost ──────────────────────────────────────────────────────────────────
class FeedPost {
  final String id;
  final String userName;
  final int overall;
  final int clarity;
  final int pacing;
  final int grammar;
  final int confidence;
  final String topicTitle;
  final String duration;
  final String persona;
  final DateTime postedAt;
  int likes;
  bool likedByMe;
  final List<FeedComment> comments;

  FeedPost({
    required this.id,
    required this.userName,
    required this.overall,
    required this.clarity,
    required this.pacing,
    required this.grammar,
    required this.confidence,
    required this.topicTitle,
    required this.duration,
    required this.persona,
    required this.postedAt,
    this.likes = 0,
    this.likedByMe = false,
    List<FeedComment>? comments,
  }) : comments = comments ?? [];

  factory FeedPost.fromJson(Map<String, dynamic> j) => FeedPost(
        id: j['id'] as String,
        userName: j['userName'] as String,
        overall: j['overall'] as int,
        clarity: j['clarity'] as int,
        pacing: j['pacing'] as int,
        grammar: j['grammar'] as int,
        confidence: j['confidence'] as int,
        topicTitle: j['topicTitle'] as String,
        duration: j['duration'] as String,
        persona: j['persona'] as String,
        postedAt: DateTime.parse(j['postedAt'] as String),
        likes: j['likes'] as int? ?? 0,
        likedByMe: j['likedByMe'] as bool? ?? false,
        comments: (j['comments'] as List<dynamic>?)
                ?.map((e) => FeedComment.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

// ── FeedService ───────────────────────────────────────────────────────────────
class FeedService extends ChangeNotifier {
  FeedService._();
  static final FeedService instance = FeedService._();

  // Set this right after login, same place AuthService stores its token.
  // e.g. FeedService.instance.token = authData.token;
  String? token;

  final List<FeedPost> _posts = [];
  bool _loaded = false;
  String? _error;

  List<FeedPost> get posts => List.unmodifiable(_posts);
  bool get isLoaded => _loaded;
  String? get error => _error;

  // ── Auth header — matches ApiService pattern exactly ──────────────────────
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ── GET /feed ─────────────────────────────────────────────────────────────
  Future<void> load() async {
    try {
      final res = await http
          .get(Uri.parse('$_feedBase/feed'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        _posts
          ..clear()
          ..addAll(
              list.map((e) => FeedPost.fromJson(e as Map<String, dynamic>)));
        _error = null;
      } else {
        _error = 'Server error ${res.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: $e';
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> refresh() => load();

  // ── POST /feed ────────────────────────────────────────────────────────────
  Future<bool> addPost({
    required String
        userName, // kept for call-site compat; server derives name from token
    required int overall,
    required int clarity,
    required int pacing,
    required int grammar,
    required int confidence,
    required String topicTitle,
    required String duration,
    required String persona,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_feedBase/feed'),
            headers: _headers,
            body: jsonEncode({
              'overall': overall,
              'clarity': clarity,
              'pacing': pacing,
              'grammar': grammar,
              'confidence': confidence,
              'topic_title': topicTitle,
              'duration': duration,
              'persona': persona,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 201) {
        final post =
            FeedPost.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
        _posts.insert(0, post);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── POST /feed/{id}/like ──────────────────────────────────────────────────
  Future<void> toggleLike(String postId) async {
    final i = _posts.indexWhere((p) => p.id == postId);
    if (i == -1) return;

    // Optimistic update
    final prevLiked = _posts[i].likedByMe;
    _posts[i].likedByMe = !prevLiked;
    _posts[i].likes = _posts[i].likedByMe
        ? _posts[i].likes + 1
        : (_posts[i].likes - 1).clamp(0, 999999);
    notifyListeners();

    try {
      final res = await http
          .post(
            Uri.parse('$_feedBase/feed/$postId/like'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _posts[i].likes = data['likes'] as int;
        _posts[i].likedByMe = data['likedByMe'] as bool;
        notifyListeners();
      } else {
        // Roll back on server error
        _posts[i].likedByMe = prevLiked;
        _posts[i].likes = prevLiked
            ? _posts[i].likes + 1
            : (_posts[i].likes - 1).clamp(0, 999999);
        notifyListeners();
      }
    } catch (_) {
      // Roll back on network error
      _posts[i].likedByMe = prevLiked;
      _posts[i].likes = prevLiked
          ? _posts[i].likes + 1
          : (_posts[i].likes - 1).clamp(0, 999999);
      notifyListeners();
    }
  }

  // ── POST /feed/{id}/comments ──────────────────────────────────────────────
  Future<void> addComment({
    required String postId,
    required String
        userName, // kept for call-site compat; server uses token identity
    required String text,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_feedBase/feed/$postId/comments'),
            headers: _headers,
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 201) {
        final comment =
            FeedComment.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
        final i = _posts.indexWhere((p) => p.id == postId);
        if (i != -1) {
          _posts[i].comments.add(comment);
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  // ── DELETE /feed/{id} ─────────────────────────────────────────────────────
  Future<void> deletePost(String postId) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$_feedBase/feed/$postId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 204) {
        _posts.removeWhere((p) => p.id == postId);
        notifyListeners();
      }
    } catch (_) {}
  }

  // ── DELETE /feed/{id}/comments/{commentId} ────────────────────────────────
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$_feedBase/feed/$postId/comments/$commentId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 204) {
        final i = _posts.indexWhere((p) => p.id == postId);
        if (i != -1) {
          _posts[i].comments.removeWhere((c) => c.id == commentId);
          notifyListeners();
        }
      }
    } catch (_) {}
  }
}

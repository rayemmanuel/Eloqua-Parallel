import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:video_compress/video_compress.dart';

// ── Backend URL Configuration ─────────────────────────────────────────────────
// LOCAL DEVELOPMENT  → swap to your ngrok or local IP
// PRODUCTION         → Render deployment (active)
String _mainBase = 'https://eloqua-parallel.onrender.com'.trim();


Future<void> initFromNgrok() async {
  return;
}

// ── Result wrapper ────────────────────────────────────────────────────────────
class ApiResult<T> {
  final T? data;
  final String? error;
  bool get success => error == null && data != null;

  const ApiResult.ok(this.data) : error = null;
  const ApiResult.err(this.error) : data = null;
}

// ── Typed response models ─────────────────────────────────────────────────────

class AuthData {
  final String token;
  final String userId;
  final String name;
  final String email;

  const AuthData({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
        token: json['token'] as String? ?? '',
        userId: json['user_id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );
}

class AnalyzeResult {
  final double combinedScore;
  final String practiceMode;
  final double relevanceScore;
  final String relevanceFeedback;

  // Speech
  final String transcript;
  final double durationSeconds;
  final int totalFillers;
  final double wordsPerMinute;
  final String pacingFeedback;
  final double grammarScore;
  final int grammarErrorCount;
  final List<Map<String, String>> grammarSuggestions;
  final double clarityScore; // <--- ADDED CLARITY FIELD

  // Body language
  final double eyeContactScore;
  final String eyeContactFeedback;
  final double postureScore;
  final String postureFeedback;
  final double gestureScore;
  final String gestureFeedback;
  final double bodyLanguageScore;

  // Coverage (preparation mode only)
  final double? coverageScore;
  final String? coverageFeedback;
  final List<Map<String, dynamic>> coverageReport;

  const AnalyzeResult({
    required this.combinedScore,
    required this.practiceMode,
    required this.relevanceScore,
    required this.relevanceFeedback,
    required this.transcript,
    required this.durationSeconds,
    required this.totalFillers,
    required this.wordsPerMinute,
    required this.pacingFeedback,
    required this.grammarScore,
    required this.grammarErrorCount,
    required this.grammarSuggestions,
    required this.clarityScore, // <--- ADDED CLARITY FIELD
    required this.eyeContactScore,
    required this.eyeContactFeedback,
    required this.postureScore,
    required this.postureFeedback,
    required this.gestureScore,
    required this.gestureFeedback,
    required this.bodyLanguageScore,
    this.coverageScore,
    this.coverageFeedback,
    this.coverageReport = const [],
  });

  factory AnalyzeResult.fromJson(Map<String, dynamic> json) {
    final speech = json['speech_analysis'] as Map<String, dynamic>? ?? {};
    final body = json['body_language_analysis'] as Map<String, dynamic>? ?? {};
    final filler = speech['filler_analysis'] as Map<String, dynamic>? ?? {};
    final pacing = speech['pacing_analysis'] as Map<String, dynamic>? ?? {};
    final grammar = speech['grammar_analysis'] as Map<String, dynamic>? ?? {};
    final eye = body['eye_contact'] as Map<String, dynamic>? ?? {};
    final posture = body['posture'] as Map<String, dynamic>? ?? {};
    final gesture = body['gestures'] as Map<String, dynamic>? ?? {};
    final coverage = json['coverage_analysis'] as Map<String, dynamic>?;

    return AnalyzeResult(
      combinedScore: (json['combined_score'] as num?)?.toDouble() ?? 0,
      practiceMode: json['practice_mode'] as String? ?? 'spontaneous',
      relevanceScore:
          (json['relevance_score'] as num?)?.toDouble() ?? 0, // ← add
      relevanceFeedback: json['relevance_feedback'] as String? ?? '',
      transcript: speech['transcript'] as String? ?? '',
      durationSeconds: (speech['duration_seconds'] as num?)?.toDouble() ?? 0,
      totalFillers: (filler['total_fillers'] as num?)?.toInt() ?? 0,
      wordsPerMinute: (pacing['words_per_minute'] as num?)?.toDouble() ?? 0,
      pacingFeedback: pacing['pacing_feedback'] as String? ?? '',
      grammarScore: (grammar['grammar_score'] as num?)?.toDouble() ?? 0,
      grammarErrorCount: (grammar['error_count'] as num?)?.toInt() ?? 0,
      grammarSuggestions: (grammar['suggestions'] as List<dynamic>? ?? [])
          .map((s) => Map<String, String>.from(s as Map))
          .toList(),
      clarityScore: (speech['clarity_score'] as num?)?.toDouble() ??
          0, // <--- PARSING CLARITY FROM BACKEND
      eyeContactScore: (eye['score'] as num?)?.toDouble() ?? 0,
      eyeContactFeedback: eye['feedback'] as String? ?? '',
      postureScore: (posture['score'] as num?)?.toDouble() ?? 0,
      postureFeedback: posture['feedback'] as String? ?? '',
      gestureScore: (gesture['score'] as num?)?.toDouble() ?? 0,
      gestureFeedback: gesture['feedback'] as String? ?? '',
      bodyLanguageScore: (body['body_language_score'] as num?)?.toDouble() ?? 0,
      coverageScore: (coverage?['coverage_score'] as num?)?.toDouble(),
      coverageFeedback: coverage?['coverage_feedback'] as String?,
      coverageReport: (coverage?['coverage_report'] as List<dynamic>? ?? [])
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList(),
    );
  }
}

class PromptResult {
  final String category;
  final String difficulty;
  final String prompt;

  const PromptResult({
    required this.category,
    required this.difficulty,
    required this.prompt,
  });

  factory PromptResult.fromJson(Map<String, dynamic> json) => PromptResult(
        category: json['category'] as String? ?? '',
        difficulty: json['difficulty'] as String? ?? '',
        prompt: json['prompt'] as String? ?? '',
      );
}

class DocumentResult {
  final String title;
  final List<String> talkingPoints;

  const DocumentResult({required this.title, required this.talkingPoints});

  factory DocumentResult.fromJson(Map<String, dynamic> json) => DocumentResult(
        title: json['title'] as String? ?? '',
        talkingPoints:
            List<String>.from(json['talking_points'] as List<dynamic>? ?? []),
      );
}

class BackendSession {
  final String timestamp;
  final String topic;
  final String practiceMode;
  final double combinedScore;
  final double wordsPerMinute;
  final double grammarScore;
  final double fillerCount;
  final double eyeContactScore;
  final double postureScore;
  final double gestureScore;
  final double bodyLanguageScore;
  final double clarityScore; // <--- ADDED CLARITY FIELD
  final double relevanceScore; // <--- ADDED RELEVANCE SCORE
  final String transcript;

  const BackendSession({
    required this.timestamp,
    required this.topic,
    required this.practiceMode,
    required this.combinedScore,
    required this.wordsPerMinute,
    required this.grammarScore,
    required this.fillerCount,
    required this.eyeContactScore,
    required this.postureScore,
    required this.gestureScore,
    required this.bodyLanguageScore,
    required this.clarityScore, // <--- ADDED CLARITY FIELD
    required this.relevanceScore, // <--- ADDED RELEVANCE SCORE
    required this.transcript,
  });

  factory BackendSession.fromJson(Map<String, dynamic> json) => BackendSession(
        timestamp: json['timestamp'] as String? ?? '',
        topic: json['topic'] as String? ?? '',
        practiceMode: json['practice_mode'] as String? ?? 'spontaneous',
        combinedScore: (json['combined_score'] as num?)?.toDouble() ?? 0,
        wordsPerMinute: (json['words_per_minute'] as num?)?.toDouble() ?? 0,
        grammarScore: (json['grammar_score'] as num?)?.toDouble() ?? 0,
        fillerCount: (json['filler_count'] as num?)?.toDouble() ?? 0,
        eyeContactScore: (json['eye_contact_score'] as num?)?.toDouble() ?? 0,
        postureScore: (json['posture_score'] as num?)?.toDouble() ?? 0,
        gestureScore: (json['gesture_score'] as num?)?.toDouble() ?? 0,
        bodyLanguageScore:
            (json['body_language_score'] as num?)?.toDouble() ?? 0,
        clarityScore: (json['clarity_score'] as num?)?.toDouble() ??
            0, // <--- PARSING CLARITY FROM BACKEND
        relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0,
        transcript: json['transcript'] as String? ?? '',
      );
}

// ── ApiService ────────────────────────────────────────────────────────────────
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // ── Shared headers ──────────────────────────────────────────────────────────
  static const Map<String, String> _base = {
    'ngrok-skip-browser-warning': 'true',
  };

  Map<String, String> _headers({String? token, bool json = false}) => {
        ..._base,
        if (json) 'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ── Health check ────────────────────────────────────────────────────────────
  Future<bool> isOnline() async {
    try {
      final res = await http
          .get(Uri.parse('$_mainBase/'), headers: _base)
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── POST /auth/register ─────────────────────────────────────────────────────
  Future<ApiResult<String>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_mainBase/auth/register'),
            headers: _headers(json: true),
            body: jsonEncode(
                {'name': name, 'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final j = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) {
        return ApiResult.ok(j['message'] as String? ?? 'Account created.');
      }
      return ApiResult.err(j['detail'] as String? ?? 'Registration failed.');
    } catch (_) {
      return ApiResult.err(
          'Could not connect to the server. Check your connection.');
    }
  }

  // ── POST /auth/login ────────────────────────────────────────────────────────
  Future<ApiResult<AuthData>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_mainBase/auth/login'),
            headers: _headers(json: true),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      final j = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return ApiResult.ok(AuthData.fromJson(j));
      return ApiResult.err(j['detail'] as String? ?? 'Login failed.');
    } on TimeoutException {
      return ApiResult.err(
          'Server is taking too long to respond. Please try again.');
    } on SocketException {
      return ApiResult.err(
          'Cannot reach the server. Check your internet connection.');
    } catch (e) {
      return ApiResult.err('Login error: ${e.runtimeType}: $e');
    }
  }

  // ── POST /auth/forgot-password ──────────────────────────────────────────────
  Future<ApiResult<String>> forgotPassword(String email) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_mainBase/auth/forgot-password'),
            headers: _headers(json: true),
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));

      final j = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return ApiResult.ok(j['message'] as String? ?? 'Reset link sent.');
      }
      return ApiResult.err(j['detail'] as String? ?? 'Something went wrong.');
    } catch (_) {
      return ApiResult.err(
          'Could not connect to the server. Check your connection.');
    }
  }

  // ── GET /prompt ─────────────────────────────────────────────────────────────
  Future<ApiResult<PromptResult>> getPrompt({
    String category = 'academic',
    String difficulty = 'intermediate',
  }) async {
    final diffMap = {
      'Foundational': 'foundational',
      'Intermediate': 'intermediate',
      'Advanced': 'advanced',
    };
    final backendDiff = diffMap[difficulty] ?? 'intermediate';

    try {
      final res = await http
          .get(
            Uri.parse(
                '$_mainBase/prompt?category=$category&difficulty=$backendDiff'),
            headers: _base,
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        if (j.containsKey('error')) return ApiResult.err(j['error'] as String);
        return ApiResult.ok(PromptResult.fromJson(j));
      }
      return ApiResult.err('Server error ${res.statusCode}');
    } catch (e) {
      return ApiResult.err('Network error: $e');
    }
  }

  // ── GET /categories ─────────────────────────────────────────────────────────
  Future<ApiResult<List<String>>> getCategories() async {
    try {
      final res = await http
          .get(Uri.parse('$_mainBase/categories'), headers: _base)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        final cats = List<String>.from(j['categories'] as List<dynamic>? ?? []);
        return ApiResult.ok(cats);
      }
      return ApiResult.err('Server error ${res.statusCode}');
    } catch (e) {
      return ApiResult.err('Network error: $e');
    }
  }

  // ── POST /upload-document ───────────────────────────────────────────────────
  Future<ApiResult<DocumentResult>> uploadDocument(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_mainBase/upload-document'),
      );
      request.headers.addAll(_base);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        if (j.containsKey('error')) return ApiResult.err(j['error'] as String);
        return ApiResult.ok(DocumentResult.fromJson(j));
      }
      return ApiResult.err('Server error ${res.statusCode}');
    } catch (e) {
      return ApiResult.err('Network error: $e');
    }
  }

  // ── POST /analyze ───────────────────────────────────────────────────────────
  Future<ApiResult<AnalyzeResult>> analyze({
    required File videoFile,
    required String token,
    required String topic,
    required String practiceMode,
    List<String> talkingPoints = const [],
  }) async {
    try {
      print('Original video size: ${await videoFile.length()} bytes');
      print('Compressing video to speed up upload and processing...');
      
      File finalVideoFile = videoFile;
      try {
        final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
          videoFile.path,
          quality: VideoQuality.LowQuality, // 360p / 480p resolution
          deleteOrigin: false, // Keep the user's high-res video locally
        );

        if (mediaInfo != null && mediaInfo.path != null) {
          finalVideoFile = File(mediaInfo.path!);
          print('Compressed video size: ${await finalVideoFile.length()} bytes');
        } else {
          print('Compression returned null, using original video.');
        }
      } catch (compressError) {
        print('Error compressing video: $compressError, falling back to original.');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_mainBase/analyze'),
      );

      request.headers.addAll(_headers(token: token));
      request.fields['topic'] = topic;
      request.fields['practice_mode'] = practiceMode;

      if (talkingPoints.isNotEmpty) {
        request.fields['talking_points'] = jsonEncode(talkingPoints);
      }

      request.files.add(
        await http.MultipartFile.fromPath('video', finalVideoFile.path,
            filename: 'session.mp4'),
      );

      // Save initial response (non-blocking server start)
      final streamed =
          await request.send().timeout(const Duration(minutes: 2));
      final res = await http.Response.fromStream(streamed);

      print('RAW INITIAL BACKEND JSON: ${res.body}');

      if (res.statusCode != 200) {
        return ApiResult.err('Server error ${res.statusCode}: ${res.body}');
      }

      final initJson = jsonDecode(res.body) as Map<String, dynamic>;
      if (initJson.containsKey('error')) {
        return ApiResult.err(initJson['error'] as String);
      }

      final jobId = initJson['job_id'] as String?;
      if (jobId == null) {
        return ApiResult.err('Backend did not return a valid job ID.');
      }

      // Poll the status endpoint until completed, failed, or timed out (2 minutes)
      const int pollIntervalSeconds = 3;
      const int maxPollAttempts = 40; // 40 * 3 = 120 seconds

      for (int attempt = 1; attempt <= maxPollAttempts; attempt++) {
        await Future.delayed(const Duration(seconds: pollIntervalSeconds));
        print('Polling attempt $attempt for job $jobId...');

        try {
          final statusRes = await http.get(
            Uri.parse('$_mainBase/analyze/status/$jobId'),
            headers: _headers(token: token),
          ).timeout(const Duration(seconds: 10));

          print('POLL STATUS JSON: ${statusRes.body}');

          if (statusRes.statusCode == 200) {
            final pollJson = jsonDecode(statusRes.body) as Map<String, dynamic>;
            
            if (pollJson.containsKey('error') && pollJson['status'] == 'failed') {
              return ApiResult.err(pollJson['error'] as String? ?? 'Analysis job failed.');
            }

            final status = pollJson['status'] as String?;
            if (status == 'pending') {
              // Still analyzing, keep polling
              continue;
            } else if (status == 'failed') {
              return ApiResult.err(pollJson['error'] as String? ?? 'Analysis job failed.');
            } else {
              // Analysis completed, parse the full result
              return ApiResult.ok(AnalyzeResult.fromJson(pollJson));
            }
          } else {
            print('Polling error: HTTP ${statusRes.statusCode}');
          }
        } catch (pollError) {
          print('Polling request error: $pollError');
        }
      }

      return ApiResult.err('Analysis timed out on the client. Please check your session history later.');
    } catch (e) {
      return ApiResult.err('Network error: $e');
    } finally {
      // Clean up compressed video temp files to free space on user's phone
      try {
        await VideoCompress.deleteAllCache();
        print('Temporary video compression files cleared.');
      } catch (ex) {
        print('Error cleaning up video compression files: $ex');
      }
    }
  }

  // ── GET /sessions ───────────────────────────────────────────────────────────
  Future<ApiResult<List<BackendSession>>> getSessions(String token) async {
    try {
      final res = await http
          .get(
            Uri.parse('$_mainBase/sessions'),
            headers: _headers(token: token),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        final sessions = list
            .map((e) => BackendSession.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResult.ok(sessions);
      }
      return ApiResult.err('Server error ${res.statusCode}');
    } catch (e) {
      return ApiResult.err('Network error: $e');
    }
  }

  // ── PATCH /profile ──────────────────────────────────────────────────────────
  Future<ApiResult<String>> updateProfile({
    required String token,
    required String name,
  }) async {
    try {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$_mainBase/profile'),
      );
      request.headers.addAll(_headers(token: token));
      request.fields['name'] = name;

      final streamed =
          await request.send().timeout(const Duration(seconds: 15));
      final res = await http.Response.fromStream(streamed);
      final j = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        return ApiResult.ok(j['name'] as String? ?? name);
      }
      return ApiResult.err(j['detail'] as String? ?? 'Update failed.');
    } catch (_) {
      return ApiResult.err('Could not connect to the server.');
    }
  }

  // ── POST /profile/photo ─────────────────────────────────────────────────────
  Future<ApiResult<String>> uploadProfilePhoto({
    required String token,
    required File photo,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_mainBase/profile/photo'),
      );
      request.headers.addAll(_headers(token: token));
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        photo.path,
        contentType: MediaType('image', 'jpeg'), // <--- FORCE IT TO JPEG
      ));
      final streamed =
          await request.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);
      final j = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        return ApiResult.ok(j['message'] as String? ?? 'Photo updated.');
      }
      return ApiResult.err(j['detail'] as String? ?? 'Upload failed.');
    } catch (_) {
      return ApiResult.err('Could not connect to the server.');
    }
  }

  // ── GET /profile ────────────────────────────────────────────────────────────
  Future<ApiResult<AuthData>> getProfile(String token) async {
    try {
      final res = await http
          .get(
            Uri.parse('$_mainBase/profile'),
            headers: _headers(token: token),
          )
          .timeout(const Duration(seconds: 10));

      final j = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return ApiResult.ok(AuthData.fromJson(j));
      return ApiResult.err(j['detail'] as String? ?? 'Failed to load profile.');
    } catch (_) {
      return ApiResult.err('Could not connect to the server.');
    }
  }

  // ── GET /leaderboard ────────────────────────────────────────────────────────
  Future<ApiResult<List<LeaderboardEntry>>> getLeaderboard(String token) async {
    try {
      final res = await http
          .get(
            Uri.parse('$_mainBase/leaderboard'),
            headers: _headers(token: token),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return ApiResult.ok(
          list
              .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return ApiResult.err('Server error ${res.statusCode}');
    } catch (e) {
      return ApiResult.err('Network error: $e');
    }
  }
}

class LeaderboardEntry {
  final String userId;
  final String name;
  final double avgScore;
  final int jarLevel;
  final int sessions;
  final bool isMe;

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.avgScore,
    required this.jarLevel,
    required this.sessions,
    required this.isMe,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        userId: json['user_id']?.toString() ?? '',
        name: json['name'] as String? ?? 'Anonymous',
        avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0,
        jarLevel: (json['jar_level'] as num?)?.toInt() ?? 0,
        sessions: (json['sessions'] as num?)?.toInt() ?? 0,
        isMe: json['is_me'] as bool? ?? false,
      );
}

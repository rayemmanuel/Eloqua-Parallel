import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'auth_service.dart';

// ── SessionData ───────────────────────────────────────────────────────────────
class SessionData {
  final int relevance;
  final String id;
  final String topic;
  final String mode; // 'spontaneous' | 'preparation'
  final int overallScore;
  final int clarity; // mapped from body_language_score
  final int pacing; // mapped from words_per_minute (normalised 0-100)
  final int grammar; // mapped from grammar_score
  final int confidence; // mapped from eye_contact_score
  final int fillerCount;
  final int durationSeconds;
  final DateTime date;
  final String persona;
  final String? transcript; // Added Transcript Field

  const SessionData({
    required this.relevance,
    required this.id,
    required this.topic,
    required this.mode,
    required this.overallScore,
    required this.clarity,
    required this.pacing,
    required this.grammar,
    required this.confidence,
    required this.fillerCount,
    required this.durationSeconds,
    required this.date,
    required this.persona,
    this.transcript,
  });

  // ── Serialisation (local storage) ──────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'relevance': relevance,
        'id': id,
        'topic': topic,
        'mode': mode,
        'overallScore': overallScore,
        'clarity': clarity,
        'pacing': pacing,
        'grammar': grammar,
        'confidence': confidence,
        'fillerCount': fillerCount,
        'durationSeconds': durationSeconds,
        'date': date.toIso8601String(),
        'persona': persona,
        'transcript': transcript,
      };

  factory SessionData.fromJson(Map<String, dynamic> json) => SessionData(
        relevance: json['relevance'] as int? ?? 0,
        id: json['id'] as String? ?? '',
        topic: json['topic'] as String? ?? 'Unknown Topic',
        mode: json['mode'] as String? ?? 'spontaneous',
        overallScore: json['overallScore'] as int? ?? 0,
        clarity: json['clarity'] as int? ?? 0,
        pacing: json['pacing'] as int? ?? 0,
        grammar: json['grammar'] as int? ?? 0,
        confidence: json['confidence'] as int? ?? 0,
        fillerCount: json['fillerCount'] as int? ?? 0,
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        date:
            DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        persona: json['persona'] as String? ?? 'The Practitioner',
        transcript: json['transcript'] as String?,
      );

  // ── Build from backend /analyze response ────────────────────────────────────
  // Field mapping:
  //   clarity    ← body_language_score   (overall body language)
  //   pacing     ← words_per_minute      (normalised: 130 wpm = 100, capped 0-100)
  //   grammar    ← grammar_score         (already 0-100)
  //   confidence ← eye_contact_score     (best proxy for confidence available)
  factory SessionData.fromAnalyzeResult({
    required AnalyzeResult result,
    required String topic,
    required String persona,
  }) {
    // Normalise WPM to 0-100:
    // Ideal range is 110-160 wpm → score 100; outside linearly decays, floor 0.
    int _normalisePacing(double wpm) {
      if (wpm <= 0) return 0;
      if (wpm >= 110 && wpm <= 160) return 100;
      if (wpm < 110) return (wpm / 110 * 100).clamp(0, 100).round();
      // wpm > 160
      return ((1 - (wpm - 160) / 100) * 100).clamp(0, 100).round();
    }

    return SessionData(
      relevance: result.relevanceScore.round(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topic: topic,
      mode: result.practiceMode,
      overallScore: result.combinedScore.round(),
      clarity: result.bodyLanguageScore.round(),
      pacing: _normalisePacing(result.wordsPerMinute),
      grammar: result.grammarScore.round(),
      confidence: result.eyeContactScore.round(),
      fillerCount: result.totalFillers,
      durationSeconds: result.durationSeconds.round(),
      date: DateTime.now(),
      persona: persona,
      transcript: result.transcript, // Map this from your AnalyzeResult model
    );
  }

  // ── Build from backend /sessions/{user_id} response ─────────────────────────
  factory SessionData.fromBackendSession(BackendSession s) {
    int _normalisePacing(double wpm) {
      if (wpm <= 0) return 0;
      if (wpm >= 110 && wpm <= 160) return 100;
      if (wpm < 110) return (wpm / 110 * 100).clamp(0, 100).round();
      return ((1 - (wpm - 160) / 100) * 100).clamp(0, 100).round();
    }

    return SessionData(
      relevance: s.relevanceScore.round(),
      id: s.timestamp, // use timestamp as unique id
      topic: s.topic,
      mode: s.practiceMode,
      overallScore: s.combinedScore.round(),
      clarity: s.bodyLanguageScore.round(),
      pacing: _normalisePacing(s.wordsPerMinute),
      grammar: s.grammarScore.round(),
      confidence: s.eyeContactScore.round(),
      fillerCount: s.fillerCount.round(),
      durationSeconds: 0, // /sessions endpoint doesn't return duration
      date: DateTime.tryParse(s.timestamp) ?? DateTime.now(),
      persona: 'The Practitioner',
      transcript: s.transcript, // Map this from your BackendSession model
    );
  }
}

// ── SessionService ────────────────────────────────────────────────────────────
class SessionService extends ChangeNotifier {
  SessionService._internal();
  static final SessionService instance = SessionService._internal();

  static String _storageKey(String userId) => 'eloqua_sessions_$userId';

  List<SessionData> _sessions = [];
  bool _isLoaded = false;
  bool _syncing = false;

  List<SessionData> get sessions => List.unmodifiable(_sessions);
  bool get isLoaded => _isLoaded;
  bool get syncing => _syncing;

  // ── Getters used by HomeScreen / AnalyticsScreen ───────────────────────────

  List<int> get recentScores {
    if (_sessions.isEmpty) return [];
    final sorted = [..._sessions]..sort((a, b) => a.date.compareTo(b.date));
    final recent =
        sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;
    return recent.map((s) => s.overallScore).toList();
  }

  double get averageScore {
    if (_sessions.isEmpty) return 0.0;
    return _sessions.fold<int>(0, (s, e) => s + e.overallScore) /
        _sessions.length;
  }

  int get currentStreak {
    if (_sessions.isEmpty) return 0;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final uniqueDays = _sessions
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    if (uniqueDays.isEmpty) return 0;
    if (todayNorm.difference(uniqueDays.first).inDays > 1) return 0;
    int streak = 1;
    for (int i = 1; i < uniqueDays.length; i++) {
      if (uniqueDays[i - 1].difference(uniqueDays[i]).inDays == 1) {
        streak++;
      } else
        break;
    }
    return streak;
  }

  int get totalSessions => _sessions.length;

  int get bestScore {
    if (_sessions.isEmpty) return 0;
    return _sessions.map((s) => s.overallScore).reduce((a, b) => a > b ? a : b);
  }

  Map<String, double> get dimensionAverages {
    if (_sessions.isEmpty) {
      return {'clarity': 0, 'pacing': 0, 'grammar': 0, 'confidence': 0};
    }
    final count = _sessions.length;
    return {
      'clarity': _sessions.fold<int>(0, (s, e) => s + e.clarity) / count,
      'pacing': _sessions.fold<int>(0, (s, e) => s + e.pacing) / count,
      'grammar': _sessions.fold<int>(0, (s, e) => s + e.grammar) / count,
      'confidence': _sessions.fold<int>(0, (s, e) => s + e.confidence) / count,
      'relevance': _sessions.fold<int>(0, (s, e) => s + e.relevance) / count,
    };
  }

  Map<int, int> get weeklyActivity {
    final result = <int, int>{0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    for (final s in _sessions) {
      if (s.date.isAfter(cutoff)) {
        final key = (s.date.weekday - 1).clamp(0, 6);
        result[key] = (result[key] ?? 0) + 1;
      }
    }
    return result;
  }

  // ── Local load ─────────────────────────────────────────────────────────────
  Future<void> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(userId));
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _sessions = decoded
          .map((e) => SessionData.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _isLoaded = true;
    notifyListeners();
  }

  // ── Sync from backend ──────────────────────────────────────────────────────
  // Call this after load() — fetches all sessions for this user from
  // GET /sessions/{user_id} and merges them with local storage.
  Future<void> syncFromBackend(String token) async {
    _syncing = true;
    notifyListeners();

    final result = await ApiService.instance.getSessions(token);

    if (result.success && result.data != null) {
      final backendSessions =
          result.data!.map(SessionData.fromBackendSession).toList();

      // Merge: keep local sessions not on backend, add backend ones not local.
      final localIds = _sessions.map((s) => s.id).toSet();
      final backendIds = backendSessions.map((s) => s.id).toSet();

      for (final s in backendSessions) {
        if (!localIds.contains(s.id)) {
          _sessions.add(s);
        }
      }

      // Persist merged list locally
      await _persist(AuthService.instance.userId!);
    }

    _syncing = false;
    notifyListeners();
  }

  Future<void> save(SessionData data, String userId) async {
    _sessions.add(data);
    await _persist(userId);
    notifyListeners();
  }

  Future<void> deleteSession(String id, String userId) async {
    _sessions.removeWhere((s) => s.id == id);
    await _persist(userId);
    notifyListeners();
  }

  Future<void> clearAll(String userId) async {
    _sessions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(userId));
    notifyListeners();
  }

  Future<void> _persist(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey(userId),
        jsonEncode(_sessions.map((s) => s.toJson()).toList()));
  }

  // ── Helper: build + save from AnalyzeResult in one call ───────────────────
  Future<SessionData> saveFromAnalyzeResult({
    required AnalyzeResult result,
    required String topic,
    required String persona,
  }) async {
    final session = SessionData.fromAnalyzeResult(
      result: result,
      topic: topic,
      persona: persona,
    );
    await save(session, AuthService.instance.userId!);
    return session;
  }
}

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ── Score model ───────────────────────────────────────────────────────────────
class PhoneticScore {
  final String phoneme;
  final double score; // 0.0 – 1.0
  final String label; // 'Excellent' | 'Good' | 'Needs Work' | 'Poor'
  final Color color;

  const PhoneticScore({
    required this.phoneme,
    required this.score,
    required this.label,
    required this.color,
  });
}

class SpeechDimension {
  final String name;
  final int score; // 0 – 100
  final String feedback;
  final Color color;
  final IconData icon;

  const SpeechDimension({
    required this.name,
    required this.score,
    required this.feedback,
    required this.color,
    required this.icon,
  });
}

class SpeechEvaluationResult {
  final int clarity;
  final int pacing;
  final int grammar;
  final int confidence;
  final int overall;
  final int fillerCount;
  final List<String> fillerWords;
  final List<String> strengths;
  final List<String> improvements;
  final String coachNote;
  final String persona;
  final List<PhoneticScore> phoneticBreakdown;
  final List<SpeechDimension> dimensions;
  final double wordsPerMinute;
  final double pauseRatio; // ratio of silence to total time
  final int wordCount;

  const SpeechEvaluationResult({
    required this.clarity,
    required this.pacing,
    required this.grammar,
    required this.confidence,
    required this.overall,
    required this.fillerCount,
    required this.fillerWords,
    required this.strengths,
    required this.improvements,
    required this.coachNote,
    required this.persona,
    required this.phoneticBreakdown,
    required this.dimensions,
    required this.wordsPerMinute,
    required this.pauseRatio,
    required this.wordCount,
  });
}

// ── Filler word registry ──────────────────────────────────────────────────────
const List<String> _fillerRegistry = [
  'um', 'uh', 'like', 'you know', 'basically', 'literally',
  'actually', 'right', 'so', 'okay so', 'i mean', 'kind of',
  'sort of', 'just', 'honestly', 'obviously',
];

// ── Color coding thresholds ───────────────────────────────────────────────────
Color _scoreColor(double score) {
  if (score >= 0.80) return const Color(0xFF2ECC71); // green  — excellent
  if (score >= 0.60) return const Color(0xFFF39C12); // amber  — good
  if (score >= 0.40) return const Color(0xFFE67E22); // orange — needs work
  return const Color(0xFFE74C3C);                    // red    — poor
}

String _scoreLabel(double score) {
  if (score >= 0.80) return 'Excellent';
  if (score >= 0.60) return 'Good';
  if (score >= 0.40) return 'Needs Work';
  return 'Poor';
}

// ── Service ───────────────────────────────────────────────────────────────────
class SpeechEvaluationService extends ChangeNotifier {
  SpeechEvaluationService._internal();
  static final SpeechEvaluationService instance =
      SpeechEvaluationService._internal();

  bool _isEvaluating = false;
  SpeechEvaluationResult? _lastResult;

  bool get isEvaluating => _isEvaluating;
  SpeechEvaluationResult? get lastResult => _lastResult;

  // ── Evaluate a completed session ─────────────────────────────────────────
  // In production this sends audio bytes to OpenAI Whisper + GPT-4o-mini.
  // The mock path uses deterministic heuristics so results feel realistic.
  Future<SpeechEvaluationResult> evaluate({
    required int durationSeconds,
    required int fillerCount,
    required String transcript, // empty string triggers mock path
    String? topicContext,
  }) async {
    _isEvaluating = true;
    notifyListeners();

    final SpeechEvaluationResult result;

    if (transcript.trim().isNotEmpty) {
      result = await _evaluateTranscript(
        transcript: transcript,
        durationSeconds: durationSeconds,
        fillerCount: fillerCount,
        topicContext: topicContext ?? '',
      );
    } else {
      result = _mockEvaluation(
        durationSeconds: durationSeconds,
        fillerCount: fillerCount,
      );
    }

    _lastResult = result;
    _isEvaluating = false;
    notifyListeners();
    return result;
  }

  // ── Real transcript evaluation ────────────────────────────────────────────
  Future<SpeechEvaluationResult> _evaluateTranscript({
    required String transcript,
    required int durationSeconds,
    required int fillerCount,
    required String topicContext,
  }) async {
    final words = transcript.trim().split(RegExp(r'\s+'));
    final wordCount = words.length;
    final minutes = durationSeconds / 60.0;
    final wpm = minutes > 0 ? wordCount / minutes : 0.0;

    // Count detected fillers from transcript
    int detectedFillers = fillerCount;
    final List<String> foundFillerWords = [];
    final lowerTranscript = transcript.toLowerCase();
    for (final filler in _fillerRegistry) {
      final matches = RegExp(r'\b' + filler + r'\b').allMatches(lowerTranscript);
      if (matches.isNotEmpty) {
        detectedFillers += matches.length;
        foundFillerWords.add(filler);
      }
    }

    // Pacing score: ideal is 120–160 wpm
    final pacingScore = _computePacingScore(wpm);

    // Clarity score: penalise filler density
    final fillerDensity = wordCount > 0 ? detectedFillers / wordCount : 0.0;
    final clarityScore = (1.0 - (fillerDensity * 5.0)).clamp(0.0, 1.0);

    // Grammar score: simple heuristic — sentence variety, avg sentence length
    final grammarScore = _computeGrammarScore(transcript);

    // Confidence score: absence of hedging language
    final confidenceScore = _computeConfidenceScore(transcript);

    final clarity    = (clarityScore    * 100).round().clamp(0, 100);
    final pacing     = (pacingScore     * 100).round().clamp(0, 100);
    final grammar    = (grammarScore    * 100).round().clamp(0, 100);
    final confidence = (confidenceScore * 100).round().clamp(0, 100);
    final overall    = ((clarity + pacing + grammar + confidence) / 4).round();

    final phoneticBreakdown = _buildPhoneticBreakdown(transcript);
    final pauseRatio = _estimatePauseRatio(durationSeconds, wordCount);

    return SpeechEvaluationResult(
      clarity:    clarity,
      pacing:     pacing,
      grammar:    grammar,
      confidence: confidence,
      overall:    overall,
      fillerCount: detectedFillers,
      fillerWords: foundFillerWords,
      strengths:   _generateStrengths(clarity, pacing, grammar, confidence),
      improvements: _generateImprovements(clarity, pacing, grammar, confidence),
      coachNote:   _generateCoachNote(overall, wpm, detectedFillers),
      persona:     _assignPersona(clarity, pacing, grammar, confidence),
      phoneticBreakdown: phoneticBreakdown,
      dimensions:  _buildDimensions(clarity, pacing, grammar, confidence),
      wordsPerMinute: wpm,
      pauseRatio:  pauseRatio,
      wordCount:   wordCount,
    );
  }

  // ── Mock evaluation (no transcript available) ─────────────────────────────
  SpeechEvaluationResult _mockEvaluation({
    required int durationSeconds,
    required int fillerCount,
  }) {
    final rng = Random();

    // Base scores — influenced by duration and filler count
    final durationBonus = (durationSeconds / 120.0).clamp(0.0, 1.0) * 10;
    final fillerPenalty = (fillerCount * 3).clamp(0, 20);

    final clarity    = (75 + rng.nextInt(15) + durationBonus.round() - fillerPenalty).clamp(0, 100);
    final pacing     = (68 + rng.nextInt(18) + durationBonus.round()).clamp(0, 100);
    final grammar    = (78 + rng.nextInt(12)).clamp(0, 100);
    final confidence = (70 + rng.nextInt(20) - fillerPenalty).clamp(0, 100);
    final overall    = ((clarity + pacing + grammar + confidence) / 4).round();

    final wpm = durationSeconds > 0
        ? (120 + rng.nextInt(60)).toDouble()
        : 0.0;

    return SpeechEvaluationResult(
      clarity:    clarity,
      pacing:     pacing,
      grammar:    grammar,
      confidence: confidence,
      overall:    overall,
      fillerCount: fillerCount,
      fillerWords: _fillerRegistry.take(fillerCount.clamp(0, 5)).toList(),
      strengths:   _generateStrengths(clarity, pacing, grammar, confidence),
      improvements: _generateImprovements(clarity, pacing, grammar, confidence),
      coachNote:   _generateCoachNote(overall, wpm, fillerCount),
      persona:     _assignPersona(clarity, pacing, grammar, confidence),
      phoneticBreakdown: _mockPhoneticBreakdown(),
      dimensions:  _buildDimensions(clarity, pacing, grammar, confidence),
      wordsPerMinute: wpm,
      pauseRatio:  0.18,
      wordCount:   (wpm * durationSeconds / 60).round(),
    );
  }

  // ── Scoring helpers ───────────────────────────────────────────────────────
  double _computePacingScore(double wpm) {
    // Ideal range 120–160 wpm
    if (wpm >= 120 && wpm <= 160) return 1.0;
    if (wpm < 120) {
      // Too slow — penalise proportionally
      return (wpm / 120.0).clamp(0.2, 1.0);
    }
    // Too fast
    return (1.0 - ((wpm - 160) / 80.0)).clamp(0.2, 1.0);
  }

  double _computeGrammarScore(String text) {
    final sentences = text.split(RegExp(r'[.!?]+'));
    if (sentences.isEmpty) return 0.5;
    final avgLen = sentences
        .map((s) => s.trim().split(RegExp(r'\s+')).length)
        .reduce((a, b) => a + b) /
        sentences.length;
    // Penalise very short (<5 words) or very long (>30 words) sentences
    if (avgLen < 5) return 0.55;
    if (avgLen > 30) return 0.60;
    return 0.80 + (avgLen / 100.0).clamp(0.0, 0.18);
  }

  double _computeConfidenceScore(String text) {
    final hedgeWords = [
      'maybe', 'perhaps', 'i think', 'i guess', 'sort of', 'kind of',
      'not sure', 'i believe', 'probably', 'might be',
    ];
    final lower = text.toLowerCase();
    int hedgeCount = 0;
    for (final hedge in hedgeWords) {
      hedgeCount += RegExp(r'\b' + hedge + r'\b').allMatches(lower).length;
    }
    final words = text.split(RegExp(r'\s+')).length;
    final hedgeDensity = words > 0 ? hedgeCount / words : 0.0;
    return (1.0 - hedgeDensity * 8.0).clamp(0.4, 1.0);
  }

  double _estimatePauseRatio(int durationSeconds, int wordCount) {
    // Average speaking: ~2.5 chars/sec = ~0.5 words/sec
    // Remaining time assumed to be pauses
    if (durationSeconds <= 0) return 0.0;
    final speakingSeconds = wordCount / 2.5;
    return (1.0 - (speakingSeconds / durationSeconds)).clamp(0.0, 0.8);
  }

  // ── Phonetic breakdown ────────────────────────────────────────────────────
  List<PhoneticScore> _buildPhoneticBreakdown(String transcript) {
    // Map common phoneme categories to word frequency in transcript
    final phonemeMap = <String, double>{
      'Consonant Clusters': _phonemeScore(transcript, [r'\b\w*[stz]{2}\w*\b']),
      'Vowel Clarity':      _phonemeScore(transcript, [r'\b[aeiou]\w*\b', r'\b\w*[aeiou]\b']),
      'Ending Consonants':  _phonemeScore(transcript, [r'\b\w+[tdngs]\b']),
      'Plosives (p/b/d/t)': _phonemeScore(transcript, [r'\b[pbtd]\w+\b']),
      'Fricatives (f/v/s)': _phonemeScore(transcript, [r'\b[fvs]\w+\b']),
    };

    return phonemeMap.entries.map((entry) {
      final score = entry.value;
      return PhoneticScore(
        phoneme: entry.key,
        score:   score,
        label:   _scoreLabel(score),
        color:   _scoreColor(score),
      );
    }).toList();
  }

  double _phonemeScore(String text, List<String> patterns) {
    int matchCount = 0;
    int totalWords = text.split(RegExp(r'\s+')).length;
    for (final pattern in patterns) {
      matchCount += RegExp(pattern, caseSensitive: false).allMatches(text).length;
    }
    if (totalWords == 0) return 0.5;
    final density = matchCount / totalWords;
    // Normalise — we expect ~20–40% coverage as "good"
    return (density / 0.35).clamp(0.0, 1.0);
  }

  List<PhoneticScore> _mockPhoneticBreakdown() {
    final rng = Random();
    final phonemes = [
      'Consonant Clusters',
      'Vowel Clarity',
      'Ending Consonants',
      'Plosives (p/b/d/t)',
      'Fricatives (f/v/s)',
    ];
    return phonemes.map((phoneme) {
      final score = 0.45 + rng.nextDouble() * 0.50;
      return PhoneticScore(
        phoneme: phoneme,
        score:   score,
        label:   _scoreLabel(score),
        color:   _scoreColor(score),
      );
    }).toList();
  }

  // ── Dimension builder ─────────────────────────────────────────────────────
  List<SpeechDimension> _buildDimensions(
      int clarity, int pacing, int grammar, int confidence) {
    return [
      SpeechDimension(
        name:     'Clarity',
        score:    clarity,
        feedback: clarity >= 80
            ? 'Your speech is clear and easy to follow.'
            : 'Reduce filler words and slow down on complex points.',
        color:    _scoreColor(clarity / 100),
        icon:     Icons.record_voice_over_outlined,
      ),
      SpeechDimension(
        name:     'Pacing',
        score:    pacing,
        feedback: pacing >= 80
            ? 'Excellent rhythm — you held audience attention well.'
            : 'Aim for 130–150 words per minute for optimal engagement.',
        color:    _scoreColor(pacing / 100),
        icon:     Icons.speed_outlined,
      ),
      SpeechDimension(
        name:     'Grammar',
        score:    grammar,
        feedback: grammar >= 80
            ? 'Strong sentence structure throughout.'
            : 'Review your talking points aloud before sessions.',
        color:    _scoreColor(grammar / 100),
        icon:     Icons.spellcheck_outlined,
      ),
      SpeechDimension(
        name:     'Confidence',
        score:    confidence,
        feedback: confidence >= 80
            ? 'You projected authority and conviction.'
            : 'Replace hedging phrases with direct assertive statements.',
        color:    _scoreColor(confidence / 100),
        icon:     Icons.emoji_events_outlined,
      ),
    ];
  }

  // ── Feedback generation ───────────────────────────────────────────────────
  List<String> _generateStrengths(
      int clarity, int pacing, int grammar, int confidence) {
    final strengths = <String>[];
    if (clarity    >= 75) strengths.add('Clear and articulate delivery throughout the session.');
    if (pacing     >= 75) strengths.add('Well-controlled pacing — stayed within the ideal range.');
    if (grammar    >= 75) strengths.add('Strong grammatical structure and sentence variety.');
    if (confidence >= 75) strengths.add('Confident, direct language with minimal hedging.');
    if (strengths.isEmpty) {
      strengths.add('You completed the session — consistency is the foundation of improvement.');
    }
    return strengths;
  }

  List<String> _generateImprovements(
      int clarity, int pacing, int grammar, int confidence) {
    final improvements = <String>[];
    if (clarity    < 75) improvements.add('Reduce filler words by replacing them with intentional pauses.');
    if (pacing     < 75) improvements.add('Practice at 130–150 words per minute using a metronome or pacing drill.');
    if (grammar    < 75) improvements.add('Read your talking points aloud before sessions to reinforce correct structure.');
    if (confidence < 75) improvements.add('Replace phrases like "I think" or "maybe" with direct assertions.');
    if (improvements.isEmpty) {
      improvements.add('Challenge yourself with Advanced difficulty topics to push your ceiling.');
    }
    return improvements;
  }

  String _generateCoachNote(int overall, double wpm, int fillers) {
    if (overall >= 85) {
      return 'Outstanding session. Your delivery is approaching expert level. '
          'Push yourself with more complex topics to continue growing.';
    }
    if (overall >= 70) {
      return 'Solid effort. Your core delivery is strong. Focus on the one or two '
          'dimensions below 70 and you will see rapid improvement.';
    }
    if (fillers > 8) {
      return 'Your biggest win will come from filler reduction. '
          'Try this: every time you want to say "um", pause for one full second instead.';
    }
    if (wpm > 180) {
      return 'You are speaking too quickly for the audience to absorb your ideas. '
          'Slow down by 20% and add deliberate pauses after key statements.';
    }
    return 'Keep practicing consistently. Even two sessions per week will produce '
        'measurable improvement within three weeks.';
  }

  String _assignPersona(int clarity, int pacing, int grammar, int confidence) {
    final scores = {
      'clarity':    clarity,
      'pacing':     pacing,
      'grammar':    grammar,
      'confidence': confidence,
    };
    final best = scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    switch (best) {
      case 'clarity':    return 'The Illuminator';
      case 'pacing':     return 'The Conductor';
      case 'grammar':    return 'The Scholar';
      case 'confidence': return 'The Maverick';
      default:           return 'The Practitioner';
    }
  }

  void reset() {
    _lastResult = null;
    notifyListeners();
  }
}
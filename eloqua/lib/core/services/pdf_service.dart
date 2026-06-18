import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// A single concept anchor — the text shown in a floating bubble
/// during the practice session.
class BubbleData {
  final String text;
  final int index;

  const BubbleData({required this.text, required this.index});
}

class PdfService {
  PdfService._internal();
  static final PdfService instance = PdfService._internal();

  // ── Template fallback when PDF is empty or unreadable ─────────────────
  static const List<String> _templateAnchors = [
    'Introduce your main argument clearly.',
    'Support with evidence or data.',
    'Address a counterpoint.',
    'Reinforce your core position.',
    'Deliver a memorable conclusion.',
  ];

  // ── Primary entry point: file path → List<BubbleData> ─────────────────

  Future<List<BubbleData>> extractBubbles(String filePath) async {
    final anchors = await extractConceptAnchors(filePath);
    return anchors
        .asMap()
        .entries
        .map((e) => BubbleData(text: e.value, index: e.key))
        .toList();
  }

  // ── Extracts concept anchors from a PDF file ───────────────────────────
  // Returns a List<String> of talking-point strings.
  // Falls back to _templateAnchors if extraction yields nothing.

  Future<List<String>> extractConceptAnchors(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return List.from(_templateAnchors);

      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      final extractor = PdfTextExtractor(document);
      final rawText = extractor.extractText();
      document.dispose();

      if (rawText.trim().isEmpty) return List.from(_templateAnchors);

      return _parseAnchors(rawText);
    } catch (e) {
      debugPrint('[PdfService] Extraction error: $e');
      return List.from(_templateAnchors);
    }
  }

  // ── Parse raw text into 5 focused concept anchors ─────────────────────

  List<String> _parseAnchors(String rawText) {
    // Step 1: Split into sentences
    final sentences = rawText
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.length > 20 && s.length < 160)
        .toList();

    if (sentences.isEmpty) return List.from(_templateAnchors);

    // Step 2: Score sentences by informational density
    // (presence of numbers, proper nouns, or key academic terms)
    final scored = sentences.map((sentence) {
      int score = 0;
      // Numbers or percentages
      if (RegExp(r'\d').hasMatch(sentence)) score += 2;
      // Capitalized words (likely proper nouns or key terms)
      final capWords = RegExp(r'\b[A-Z][a-z]{3,}\b').allMatches(sentence);
      score += capWords.length;
      // Academic keywords
      const keywords = [
        'therefore', 'however', 'because', 'evidence', 'research',
        'study', 'analysis', 'result', 'conclusion', 'theory',
        'impact', 'significant', 'demonstrate', 'suggest', 'argue',
      ];
      for (final kw in keywords) {
        if (sentence.toLowerCase().contains(kw)) score += 1;
      }
      return _ScoredSentence(text: sentence, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    // Step 3: Pick top 5 unique anchors
    final anchors = <String>[];
    final seen = <String>{};
    for (final item in scored) {
      final normalised = item.text.toLowerCase().substring(
          0, (item.text.length > 40 ? 40 : item.text.length));
      if (!seen.contains(normalised)) {
        seen.add(normalised);
        anchors.add(_truncate(item.text, 100));
        if (anchors.length >= 5) break;
      }
    }

    // Pad with templates if we got fewer than 5
    if (anchors.length < 5) {
      for (final t in _templateAnchors) {
        if (anchors.length >= 5) break;
        anchors.add(t);
      }
    }

    return anchors;
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  String _truncate(String text, int max) {
    if (text.length <= max) return text;
    final truncated = text.substring(0, max);
    final lastSpace = truncated.lastIndexOf(' ');
    return lastSpace > max ~/ 2
        ? '${truncated.substring(0, lastSpace)}...'
        : '$truncated...';
  }
}

class _ScoredSentence {
  final String text;
  final int score;
  const _ScoredSentence({required this.text, required this.score});
}
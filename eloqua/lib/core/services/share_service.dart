import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Vibe Personas based on dominant score dimension
class VibePersona {
  final String title;
  final String subtitle;
  final IconData icon;

  const VibePersona({required this.title, required this.subtitle, required this.icon});

  static VibePersona fromScores({
    required int clarity,
    required int pacing,
    required int grammar,
    required int confidence,
  }) {
    final best = {
      'clarity':    clarity,
      'pacing':     pacing,
      'grammar':    grammar,
      'confidence': confidence,
    }.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    switch (best) {
      case 'clarity':
        return const VibePersona(
          title: 'The Illuminator',
          subtitle: 'Crystal clear communication',
          icon: Icons.lightbulb_outline,
        );
      case 'pacing':
        return const VibePersona(
          title: 'The Conductor',
          subtitle: 'Perfect rhythm and flow',
          icon: Icons.music_note_outlined,
        );
      case 'grammar':
        return const VibePersona(
          title: 'The Scholar',
          subtitle: 'Precise academic language',
          icon: Icons.school_outlined,
        );
      case 'confidence':
        return const VibePersona(
          title: 'The Maverick',
          subtitle: 'Commanding stage presence',
          icon: Icons.bolt_outlined,
        );
      default:
        return const VibePersona(
          title: 'The Practitioner',
          subtitle: 'Consistent and improving',
          icon: Icons.trending_up_rounded,
        );
    }
  }
}

// ShareService — captures a RepaintBoundary widget as PNG and shares it
class ShareService {
  ShareService._();
  static final ShareService instance = ShareService._();

  // Call this with the GlobalKey of the RepaintBoundary wrapping the share card
  Future<void> shareScoreCard(GlobalKey boundaryKey, String message) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir   = await getTemporaryDirectory();
      final file  = File('${dir.path}/eloqua_score_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: message,
        subject: 'My Eloqua Session Score',
      );
    } catch (e) {
      debugPrint('ShareService error: $e');
    }
  }

  // Share to social feed as a text post (no image)
  Future<void> shareTextPost({
    required String userName,
    required int    overall,
    required String topicTitle,
    required String persona,
  }) async {
    final text = '$userName scored $overall on Eloqua\n'
        'Topic: "$topicTitle"\n'
        'Persona: $persona\n'
        'Practice at Eloqua — Your Personal Speech Coach';
    await Share.share(text, subject: 'My Eloqua Score');
  }
}
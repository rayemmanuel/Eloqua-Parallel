import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/services/share_service.dart';

// ── Score Share Card ──────────────────────────────────────────────────────────
// Wrap this in a RepaintBoundary to capture as image.
// The boundaryKey is passed back to ShareService.shareScoreCard().

class ScoreShareCard extends StatelessWidget {
  final String      userName;
  final int         overall;
  final int         clarity;
  final int         pacing;
  final int         grammar;
  final int         confidence;
  final String      topicTitle;
  final String      duration;
  final VibePersona persona;

  const ScoreShareCard({
    super.key,
    required this.userName,
    required this.overall,
    required this.clarity,
    required this.pacing,
    required this.grammar,
    required this.confidence,
    required this.topicTitle,
    required this.duration,
    required this.persona,
  });

  // QR data encodes a deep-link style string with the session summary
  String get _qrData =>
      'eloqua://session?user=${Uri.encodeComponent(userName)}'
      '&score=$overall&persona=${Uri.encodeComponent(persona.title)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header row — app name + overall score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Eloqua',
                style: TextStyle(color: Colors.white38,
                  fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$overall / 100',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Persona block
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(persona.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(persona.title,
                style: const TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.w700)),
              Text(persona.subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
          ]),

          const SizedBox(height: 20),

          // Topic
          Text(
            topicTitle.length > 42
                ? '${topicTitle.substring(0, 40)}...'
                : topicTitle,
            style: const TextStyle(color: Colors.white70,
              fontSize: 12, height: 1.4),
          ),

          const SizedBox(height: 16),

          // Score bars
          _ScoreRow(label: 'Clarity',    score: clarity),
          const SizedBox(height: 6),
          _ScoreRow(label: 'Pacing',     score: pacing),
          const SizedBox(height: 6),
          _ScoreRow(label: 'Grammar',    score: grammar),
          const SizedBox(height: 6),
          _ScoreRow(label: 'Confidence', score: confidence),

          const SizedBox(height: 20),

          // Bottom row — QR + user info
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // QR code
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data:            _qrData,
                  version:         QrVersions.auto,
                  size:            72,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color:    Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color:           Colors.black,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                      style: const TextStyle(color: Colors.white,
                        fontSize: 13, fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(duration,
                      style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 8),
                    const Text('Scan to view session',
                      style: TextStyle(color: Colors.white30, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int    score;
  const _ScoreRow({required this.label, required this.score});

  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(
      width: 68,
      child: Text(label,
        style: const TextStyle(color: Colors.white54,
          fontSize: 10, fontWeight: FontWeight.w600)),
    ),
    Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: score / 100,
          color: Colors.white,
          backgroundColor: Colors.white.withAlpha(25),
          minHeight: 4,
        ),
      ),
    ),
    const SizedBox(width: 8),
    SizedBox(
      width: 24,
      child: Text('$score',
        style: const TextStyle(color: Colors.white,
          fontSize: 10, fontWeight: FontWeight.w700),
        textAlign: TextAlign.right),
    ),
  ]);
}
import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/constants/strings.dart';

class FillerJarScreen extends StatefulWidget {
  final int fillerCount;
  const FillerJarScreen({super.key, this.fillerCount = 0});
  @override
  State<FillerJarScreen> createState() => _FillerJarScreenState();
}

class _FillerJarScreenState extends State<FillerJarScreen> with TickerProviderStateMixin {
  late AnimationController _fillCtrl;
  late Animation<double>   _fillAnim;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _count = widget.fillerCount;
    _fillCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fillAnim = CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOut);
    if (_count > 0) _fillCtrl.forward();
  }

  double get _fillLevel => (_count / 20).clamp(0.0, 1.0);

  void _addFiller() {
    setState(() => _count++);
    _fillCtrl.animateTo(_fillLevel, duration: const Duration(milliseconds: 400));
  }

  void _reset() {
    setState(() => _count = 0);
    _fillCtrl.animateTo(0, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() { _fillCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.fillerJarTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [

          // Counter display
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('$_count',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w700, height: 1.0)),
            const SizedBox(width: 8),
            const Text('fillers', style: TextStyle(fontSize: 20, color: Colors.black45, fontWeight: FontWeight.w500)),
          ]),

          const SizedBox(height: 8),
          Text(
            _count == 0 ? AppStrings.fillerJarEmpty : _getMessage(),
            style: const TextStyle(fontSize: 14, color: Colors.black45),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // The jar
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _fillAnim,
                builder: (_, __) => CustomPaint(
                  size: const Size(200, 280),
                  painter: _JarPainter(
                    fillLevel: _fillLevel * _fillAnim.value,
                    count:     _count,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Filler word chips
          const Text('Detected filler words:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: AppStrings.fillerWords.map((w) => Chip(
              label: Text('"$w"', style: const TextStyle(fontSize: 12)),
              backgroundColor: const Color(0xFFF0F0F0),
              side: BorderSide.none,
            )).toList(),
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text(AppStrings.fillerJarReset),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _addFiller,
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('Add Filler'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  String _getMessage() {
    if (_count < 5)  return 'Good awareness — keep going!';
    if (_count < 10) return 'Getting there — try pausing instead of "um".';
    if (_count < 15) return 'Practice pausing before key phrases.';
    return 'Jar is almost full! Focus on reducing filler words.';
  }
}

// ── Jar Painter ───────────────────────────────────────────────────────────────
class _JarPainter extends CustomPainter {
  final double fillLevel;
  final int count;
  final _rand = Random(42); // fixed seed so pebbles don't jump around

  _JarPainter({required this.fillLevel, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Jar body path
    final jarPath = Path()
      ..moveTo(w * 0.15, h * 0.12)
      ..lineTo(w * 0.1, h * 0.95)
      ..quadraticBezierTo(w * 0.1, h, w * 0.2, h)
      ..lineTo(w * 0.8, h)
      ..quadraticBezierTo(w * 0.9, h, w * 0.9, h * 0.95)
      ..lineTo(w * 0.85, h * 0.12)
      ..close();

    // Fill
    if (fillLevel > 0) {
      final fillY   = h - (h * 0.85 * fillLevel);
      final fillPath = Path()
        ..moveTo(w * 0.1, fillY)
        ..lineTo(w * 0.1, h * 0.95)
        ..quadraticBezierTo(w * 0.1, h, w * 0.2, h)
        ..lineTo(w * 0.8, h)
        ..quadraticBezierTo(w * 0.9, h, w * 0.9, h * 0.95)
        ..lineTo(w * 0.9, fillY)
        ..close();

      canvas.drawPath(fillPath, Paint()
        ..color = const Color(0xFFF5F5F5)
        ..style = PaintingStyle.fill);

      // Draw pebbles
      final pebbleCount = (count * fillLevel).round().clamp(0, 40);
      final pebblePaint = Paint()..style = PaintingStyle.fill;
      final colors = [
        const Color(0xFFCCCCCC),
        const Color(0xFFBBBBBB),
        const Color(0xFFAAAAAA),
        const Color(0xFF999999),
      ];

      for (int i = 0; i < pebbleCount; i++) {
        final px = w * 0.15 + _rand.nextDouble() * w * 0.7;
        final py = fillY + _rand.nextDouble() * (h - fillY - 10);
        final pr = 6.0 + _rand.nextDouble() * 8;

        if (py + pr < h && px - pr > w * 0.1 && px + pr < w * 0.9) {
          pebblePaint.color = colors[i % colors.length];
          canvas.drawCircle(Offset(px, py), pr, pebblePaint);
        }
      }
    }

    // Jar outline
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(jarPath, outlinePaint);

    // Jar neck
    final neckPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final neckPath = Path()
      ..moveTo(w * 0.25, h * 0.12)
      ..lineTo(w * 0.2, h * 0.0)
      ..lineTo(w * 0.8, h * 0.0)
      ..lineTo(w * 0.75, h * 0.12);
    canvas.drawPath(neckPath, neckPaint);
  }

  @override
  bool shouldRepaint(_JarPainter old) =>
      old.fillLevel != fillLevel || old.count != count;
}
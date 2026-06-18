import 'dart:math';
import 'package:flutter/material.dart';

// ── Bubble Data Model ─────────────────────────────────────────────────────────
class BubbleData {
  final String id;
  final String text;
  bool dismissed;

  BubbleData({required this.id, required this.text, this.dismissed = false});

  // Template bubbles shown when PDF has no extractable text
  static List<BubbleData> templates() => [
        BubbleData(id: 't1', text: 'Introduction'),
        BubbleData(id: 't2', text: 'Core Argument'),
        BubbleData(id: 't3', text: 'Supporting Evidence'),
        BubbleData(id: 't4', text: 'Counterpoint'),
        BubbleData(id: 't5', text: 'Conclusion'),
      ];

  // Build bubbles from talking point strings
  static List<BubbleData> fromPoints(List<String> points) {
    if (points.isEmpty) return templates();
    return points
        .take(5)
        .toList()
        .asMap()
        .entries
        .map((e) => BubbleData(
              id: 'p${e.key}',
              text: e.value.length > 24
                  ? '${e.value.substring(0, 22)}...'
                  : e.value,
            ))
        .toList();
  }
}

// ── Single Animated Bubble ────────────────────────────────────────────────────
class ConceptBubble extends StatefulWidget {
  final BubbleData data;
  final VoidCallback onDismiss;
  final double startX;
  final double startY;

  const ConceptBubble({
    super.key,
    required this.data,
    required this.onDismiss,
    required this.startX,
    required this.startY,
  });

  @override
  State<ConceptBubble> createState() => _ConceptBubbleState();
}

class _ConceptBubbleState extends State<ConceptBubble>
    with TickerProviderStateMixin {
  late AnimationController _moveCtrl;
  late Animation<Offset> _moveAnim;
  late AnimationController _popCtrl;
  late Animation<double> _scaleAnim;

  bool _popping = false;
  final _rand = Random();
  double _dx = 0;
  double _dy = 0;

  @override
  void initState() {
    super.initState();

    // Slow drift animation — loops back and forth
    _moveCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000 + _rand.nextInt(2000)),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _reverseDirection();
          _moveCtrl.forward(from: 0);
        }
      });

    _dx = (_rand.nextDouble() - 0.5) * 40;
    _dy = (_rand.nextDouble() - 0.5) * 20;

    _moveAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(_dx, _dy),
    ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOut));

    _moveCtrl.forward();

    // Pop scale animation
    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _popCtrl, curve: Curves.easeOut));

    _popCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDismiss();
    });
  }

  void _reverseDirection() {
    _dx = -_dx;
    _dy = -_dy;
    _moveAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(_dx, _dy),
    ).animate(CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOut));
  }

  void _pop() {
    if (_popping) return;
    setState(() => _popping = true);
    _moveCtrl.stop();
    _popCtrl.forward();
  }

  @override
  void dispose() {
    _moveCtrl.dispose();
    _popCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.dismissed) return const SizedBox.shrink();

    return Positioned(
      left: widget.startX,
      top: widget.startY,
      child: AnimatedBuilder(
        animation: _popping ? _popCtrl : _moveCtrl,
        builder: (context, _) => Transform.translate(
          // FIX 1: was (, _)
          offset: _popping ? Offset.zero : _moveAnim.value,
          child: ScaleTransition(
            scale: _popping ? _scaleAnim : const AlwaysStoppedAnimation(1.0),
            child: GestureDetector(
              onTap: _pop,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8), // FIX 2: was 😎
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(220),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      widget.data.text,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bubble Overlay (used in Practice Screen Stack) ────────────────────────────
class ConceptBubbleOverlay extends StatefulWidget {
  final List<BubbleData> bubbles;
  const ConceptBubbleOverlay({super.key, required this.bubbles});

  @override
  State<ConceptBubbleOverlay> createState() => _ConceptBubbleOverlayState();
}

class _ConceptBubbleOverlayState extends State<ConceptBubbleOverlay> {
  final _rand = Random();
  late List<BubbleData> _active;

  @override
  void initState() {
    super.initState();
    _active = List.from(widget.bubbles);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return IgnorePointer(
      ignoring: false,
      child: SizedBox.expand(
        child: Stack(
          children: _active.asMap().entries.map((entry) {
            final i = entry.key;
            final bubble = entry.value;
            if (bubble.dismissed) return const SizedBox.shrink();

            final startX =
                30.0 + (i % 3) * (w * 0.28) + _rand.nextDouble() * 30;
            final startY = 80.0 + (i ~/ 3) * 70.0 + _rand.nextDouble() * 20;

            return ConceptBubble(
              key: ValueKey(bubble.id),
              data: bubble,
              startX: startX.clamp(20, w - 160),
              startY: startY.clamp(60, h * 0.5),
              onDismiss: () => setState(() => bubble.dismissed = true),
            );
          }).toList(),
        ),
      ),
    );
  }
}

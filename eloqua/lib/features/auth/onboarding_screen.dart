import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/strings.dart';
import '../../core/services/haptic_service.dart';
import 'register_screen.dart';
import '../../core/theme/theme_manager_ext.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late List<_OBData> _remainingPages;

  @override
  void initState() {
    super.initState();
    _remainingPages = List.from(_pages);
  }

  void _goToRegister() => Navigator.pushReplacementNamed(context, '/register');

  void _removeCurrentCard() {
    if (_remainingPages.isEmpty) return;
    HapticService.instance.light();
    setState(() {
      _remainingPages.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.isParadise;
    final currPageNum = _pages.length - _remainingPages.length;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR & SKIP BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ELOQUA',
                      style: tt.labelSmall?.copyWith(
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w800,
                          color: cs.primary)),
                  if (_remainingPages.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        HapticService.instance.light();
                        _goToRegister();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          AppStrings.obSkip,
                          style: tt.labelSmall?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // CARD STACK AREA
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _remainingPages.isNotEmpty
                      ? Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            for (int i = _remainingPages.length - 1;
                                i >= 1;
                                i--)
                              AnimatedPositioned(
                                key: ValueKey('bg_${_remainingPages[i].title}'),
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeOutBack,
                                top: i * 12.0,
                                left: i * 8.0,
                                right: -(i * 8.0),
                                bottom: -(i * 12.0),
                                child: Transform.scale(
                                  scale: 1 - (i * 0.05),
                                  child: Opacity(
                                    opacity: (0.4 / i).clamp(0.0, 1.0),
                                    child: _PageCardContent(
                                      page: _remainingPages[i],
                                      isBackground: true,
                                      isParadise: isParadise,
                                    ),
                                  ),
                                ),
                              ),
                            _SwipeablePageCard(
                              key: ValueKey(_remainingPages[0].title),
                              page: _remainingPages[0],
                              onSwipe: _removeCurrentCard,
                              isParadise: isParadise,
                            ),
                          ],
                        )
                      : _buildCompletionScreen(context, cs, tt),
                ),
              ),
            ),

            // DOTS INDICATOR
            if (_remainingPages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    final active = i == currPageNum;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? cs.primary : cs.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(
      BuildContext context, ColorScheme cs, TextTheme tt) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: cs.primary.withOpacity(0.1)),
            child: Icon(Icons.check_rounded, size: 50, color: cs.primary),
          ),
        ),
        const SizedBox(height: 32),
        _buildSlideText('All Done!', tt.headlineMedium, cs.onSurface, 800),
        const SizedBox(height: 12),
        _buildSlideText("You're ready to get started", tt.bodyMedium,
            cs.onSurfaceVariant, 1000),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () {
            HapticService.instance.medium();
            _goToRegister();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: cs.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.obGetStarted,
                    style: tt.labelLarge?.copyWith(
                        color: cs.onPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded,
                    color: cs.onPrimary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlideText(
      String text, TextStyle? style, Color color, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), child: child),
      ),
      child: Text(text,
          style: style?.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }

  static const _pages = [
    _OBData(
      icon: Icons.graphic_eq_rounded,
      title: AppStrings.ob1Title,
      body: AppStrings.ob1Body,
      features: [
        _Feature(
            icon: Icons.bolt_rounded,
            title: 'AI Feedback',
            desc: 'Real-time tone analysis.')
      ],
    ),
    _OBData(
      icon: Icons.tune_rounded,
      title: AppStrings.ob2Title,
      body: AppStrings.ob2Body,
      features: [
        _Feature(
            icon: Icons.speed_rounded,
            title: 'Pacing Coach',
            desc: 'Identify speech habits.')
      ],
    ),
    _OBData(
      icon: Icons.emoji_events_rounded,
      title: AppStrings.ob3Title,
      body: AppStrings.ob3Body,
      features: [
        _Feature(
            icon: Icons.mic_external_on_rounded,
            title: 'Presence',
            desc: 'Build master confidence.')
      ],
    ),
  ];
}

class _SwipeablePageCard extends StatefulWidget {
  final _OBData page;
  final VoidCallback onSwipe;
  final bool isParadise;
  const _SwipeablePageCard(
      {super.key,
      required this.page,
      required this.onSwipe,
      required this.isParadise});

  @override
  State<_SwipeablePageCard> createState() => _SwipeablePageCardState();
}

class _SwipeablePageCardState extends State<_SwipeablePageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) => setState(() => _offset += d.delta),
      onPanEnd: (d) {
        if (_offset.dx.abs() > 120 ||
            d.velocity.pixelsPerSecond.dx.abs() > 800) {
          _animateOut(_offset.dx > 0 ? 1.0 : -1.0);
        } else {
          _resetPosition();
        }
      },
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: _offset.dx / 1200,
          child: _PageCardContent(
              page: widget.page,
              isBackground: false,
              isParadise: widget.isParadise),
        ),
      ),
    );
  }

  void _animateOut(double dir) {
    final start = _offset;
    final end = Offset(dir * 1000, _offset.dy);
    _controller.forward(from: 0).then((_) => widget.onSwipe());
    _controller.addListener(() {
      if (mounted)
        setState(() => _offset = Offset.lerp(
            start, end, Curves.easeIn.transform(_controller.value))!);
    });
  }

  void _resetPosition() {
    final start = _offset;
    _controller.forward(from: 0);
    _controller.addListener(() {
      if (mounted)
        setState(() => _offset = Offset.lerp(start, Offset.zero,
            Curves.elasticOut.transform(_controller.value))!);
    });
  }
}

class _PageCardContent extends StatelessWidget {
  final _OBData page;
  final bool isBackground;
  final bool isParadise;
  const _PageCardContent(
      {required this.page,
      required this.isBackground,
      required this.isParadise});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: cs.shadow.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                // FIX: Replaced LinearGradient with a clean solid color
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(page.icon, size: 70, color: cs.primary),
            ),
            const SizedBox(height: 24),
            Text(
              page.title,
              style: isParadise
                  ? GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface)
                  : tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900, color: cs.onSurface),
            ),
            const SizedBox(height: 10),
            Text(page.body,
                style: tt.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant, height: 1.5)),
            if (!isBackground && page.features != null) ...[
              const SizedBox(height: 20),
              ...page.features!.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(f.icon, size: 18, color: cs.primary),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(f.title,
                                style: tt.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _OBData {
  final IconData icon;
  final String title;
  final String body;
  final List<_Feature>? features;
  const _OBData(
      {required this.icon,
      required this.title,
      required this.body,
      this.features});
}

class _Feature {
  final IconData icon;
  final String title;
  final String desc;
  const _Feature({required this.icon, required this.title, required this.desc});
}

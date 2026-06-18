import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/session_service.dart';
import '../../core/services/speech_evaluation_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/theme/theme_manager_ext.dart';

// ── Paradise color constants ──────────────────────────────────────────────────
const _pFuchsia = Color(0xFFE8407A);
const _pOrange = Color(0xFFD4561E);
const _pGreen = Color(0xFF2E9E56);
const _pTurquoise = Color(0xFF3AAAB8);
const _pYellow = Color(0xFFFAE640);
const _pCream = Color(0xFFFFF5E0);
const _pBrown = Color(0xFF2C1A0E);
const _pOrchid = Color(0xFF9B4DB5);
const _pWhite = Color(0xFFFFFFFF);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _ringController;
  late final AnimationController _pulseController;
  late final Animation<double> _ringAnim;
  late final Animation<double> _pulseAnim;

  late final AnimationController _entrance;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ringController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _ringAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: _ringController, curve: Curves.linear));
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _entrance = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();
    _anims = List.generate(
      10,
      (i) => CurvedAnimation(
        parent: _entrance,
        curve: Interval(i * 0.07, (i * 0.07 + 0.55).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    _pulseController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  Widget _fade(int i, Widget child) => AnimatedBuilder(
        animation: _anims[i],
        child: child,
        builder: (_, w) => Opacity(
          opacity: _anims[i].value,
          child: Transform.translate(
              offset: Offset(0, 20 * (1 - _anims[i].value)), child: w),
        ),
      );

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'SYS_MORNING';
    if (h < 17) return 'SYS_AFTERNOON';
    return 'SYS_EVENING';
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final auth = context.watch<AuthService>();
    final session = context.watch<SessionService>();
    final eval = context.watch<SpeechEvaluationService>();

    final name = auth.currentUserName ?? 'Learner';
    final avg = session.averageScore;
    final streak = session.currentStreak;
    final total = session.totalSessions;
    final scores = session.recentScores;
    final activity = session.weeklyActivity;
    final lastEval = eval.lastResult;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _fade(
                  0,
                  _TopBar(
                    onNotif: () => Navigator.pushNamed(context, '/social'),
                  )),
            ),
            SliverToBoxAdapter(
              child: _fade(
                  1,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: _GreetingHero(
                      name: name,
                      avg: avg,
                      onContinue: () =>
                          Navigator.pushNamed(context, '/practice'),
                    ),
                  )),
            ),
            SliverToBoxAdapter(
              child: _fade(
                  2,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _DailyMasteryRow(
                        avg: avg, streak: streak, total: total),
                  )),
            ),
            SliverToBoxAdapter(
              child: _fade(
                  3,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _EngagementPulse(scores: scores, activity: activity),
                  )),
            ),
            SliverToBoxAdapter(
              child: _fade(
                  4,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('Practice'),
                        const SizedBox(height: 14),
                        _PracticeRow(
                          onPrep: () => Navigator.pushNamed(context, '/prep'),
                          onBlitz: () =>
                              Navigator.pushNamed(context, '/spontaneous'),
                          onChat: () => Navigator.pushNamed(context, '/chat'),
                        ),
                      ],
                    ),
                  )),
            ),
            // RESTORED PREMIUM FOLDER DESIGN
            SliverToBoxAdapter(
              child: _fade(
                  5,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: _HistoryFolder(
                      onViewAll: () => Navigator.pushNamed(context, '/history'),
                    ),
                  )),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      floatingActionButton: _MicFab(
        onTap: () => Navigator.pushNamed(context, '/practice'),
      ),
    );
  }
}

// ── GLOBAL THEMED COMPONENTS ─────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onNotif;
  const _TopBar({required this.onNotif});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: BoxDecoration(
        color: cs.primary,
        boxShadow: [
          BoxShadow(
              color: cs.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: cs.onPrimary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.primaryContainer, width: 1.5),
          ),
          child: Image.asset(
            'assets/images/logo.png',
            width: 20,
            height: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text('ELOQUA',
            style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onPrimary,
                letterSpacing: 3.0)),
        const Spacer(),
        // FIX: Added InkWell for the notification icon
        Container(
          decoration: BoxDecoration(
            color: cs.onPrimary.withOpacity(0.15),
            shape: BoxShape.circle,
            border:
                Border.all(color: cs.onPrimary.withOpacity(0.4), width: 1.0),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                HapticService.instance.light();
                onNotif();
              },
              child: SizedBox(
                width: 38,
                height: 38,
                child: Icon(Icons.notifications_none_rounded,
                    size: 18, color: cs.onPrimary),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _GreetingHero extends StatelessWidget {
  final String name;
  final double avg;
  final VoidCallback onContinue;
  const _GreetingHero(
      {required this.name, required this.avg, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final progress = avg > 0 ? (avg / 100).clamp(0.0, 1.0) : 0.0;
    final firstName = name.split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, $firstName',
          style: tt.displayLarge?.copyWith(
            color: cs.primary,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your journey is flourishing ✦',
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.primary, width: 2.5),
            boxShadow: [
              BoxShadow(
                  color: cs.primary.withOpacity(0.2),
                  blurRadius: 28,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: cs.onPrimaryContainer,
                          borderRadius: BorderRadius.circular(100)),
                      child: Text('DAILY INSPIRATION',
                          style: tt.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.primaryContainer,
                              letterSpacing: 2.0)),
                    ),
                    const SizedBox(height: 14),
                    Text('"Language is the\nsoul of the place."',
                        style: tt.titleLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: cs.onPrimaryContainer,
                            height: 1.35)),
                    const SizedBox(height: 8),
                    Text('— Eloqua Collective',
                        style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onPrimaryContainer.withOpacity(0.75))),
                    const SizedBox(height: 20),
                    // FIX: Replaced GestureDetector with Material & InkWell for "START PRACTICE"
                    Container(
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                              color: cs.shadow.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: () {
                            HapticService.instance.medium();
                            onContinue();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 11),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('START PRACTICE',
                                  style: tt.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onPrimary,
                                      letterSpacing: 2.0)),
                              const SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded,
                                  color: cs.onPrimary, size: 14),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _ProgressRing(
                  progress: progress, color: cs.onPrimaryContainer, size: 76),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;
  const _ProgressRing(
      {required this.progress, required this.color, required this.size});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(progress: progress, color: color)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(progress * 100).round()}%',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Georgia',
                        color: color)),
                Text('mastery',
                    style: TextStyle(
                        fontSize: 9,
                        color: color.withOpacity(0.6),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      );
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 5;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi,
        false,
        Paint()
          ..color = color.withOpacity(0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);
    canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _DailyMasteryRow extends StatelessWidget {
  final double avg;
  final int streak, total;
  const _DailyMasteryRow(
      {required this.avg, required this.streak, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Daily Mastery'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant, width: 2.0),
                boxShadow: [
                  BoxShadow(
                      color: cs.shadow.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sessions',
                      style: tt.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 2.5)),
                  const SizedBox(height: 4),
                  Text('$total',
                      style: tt.displayMedium
                          ?.copyWith(color: cs.primary, height: 1.0)),
                  const SizedBox(height: 12),
                  Row(children: [
                    _MiniStat(
                        value: '${avg.round()}%',
                        label: 'Accuracy',
                        color: cs.primary),
                    const SizedBox(width: 16),
                    _MiniStat(
                        value: '$streak',
                        label: 'Day streak',
                        color: cs.secondary),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.primaryContainer, width: 2.0),
                boxShadow: [
                  BoxShadow(
                      color: cs.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      color: cs.onPrimary, size: 22),
                  const SizedBox(height: 10),
                  Text('$streak',
                      style: tt.displayMedium
                          ?.copyWith(color: cs.onPrimary, height: 1.0)),
                  const SizedBox(height: 4),
                  Text('Day\nStreak',
                      style: tt.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: cs.onPrimary.withOpacity(0.85),
                          height: 1.3)),
                ],
              ),
            ),
          ),
        ]),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _MiniStat(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = context.tt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800, color: color, letterSpacing: 1.0)),
        Text(label,
            style: tt.labelSmall?.copyWith(
                color: context.cs.onSurfaceVariant, letterSpacing: 1.5)),
      ],
    );
  }
}

class _EngagementPulse extends StatelessWidget {
  final List<int> scores;
  final Map<int, int> activity;
  const _EngagementPulse({required this.scores, required this.activity});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final displayScores =
        scores.isNotEmpty ? scores : [60, 72, 68, 80, 75, 88, 92];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Engagement Pulse'),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant, width: 2.0),
            boxShadow: [
              BoxShadow(
                  color: cs.shadow.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: cs.primary, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('This Week',
                    style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: 1.5)),
                const SizedBox(width: 12),
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withOpacity(0.3),
                        shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Last Week',
                    style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant.withOpacity(0.7),
                        letterSpacing: 1.5)),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                  height: 80,
                  child: CustomPaint(
                      size: const Size(double.infinity, 80),
                      painter: _LinePainter(
                          scores: displayScores, color: cs.primary))),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map((d) => Text(d,
                        style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 1.0)))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<int> scores;
  final Color color;
  const _LinePainter({required this.scores, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.length < 2) return;
    final minS = scores.reduce(math.min).toDouble();
    final maxS = scores.reduce(math.max).toDouble();
    final range = (maxS - minS).clamp(10.0, 100.0);
    final pts = scores.asMap().entries.map((e) {
      final x = e.key / (scores.length - 1) * size.width;
      final y =
          size.height - ((e.value - minS) / range) * (size.height - 12) - 6;
      return Offset(x, y);
    }).toList();

    final fill = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) fill.lineTo(p.dx, p.dy);
    fill.lineTo(pts.last.dx, size.height);
    fill.close();
    canvas.drawPath(fill, Paint()..color = color.withOpacity(0.08));

    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final c1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final c2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      line.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round);

    for (int i = 0; i < pts.length; i++) {
      if (i == pts.length - 1) {
        canvas.drawCircle(pts[i], 5, Paint()..color = const Color(0xFFFFFFFF));
        canvas.drawCircle(
            pts[i],
            5,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
      } else {
        canvas.drawCircle(pts[i], 2.5, Paint()..color = color.withOpacity(0.4));
      }
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => false;
}

class _PracticeRow extends StatelessWidget {
  final VoidCallback onPrep, onBlitz, onChat;
  const _PracticeRow(
      {required this.onPrep, required this.onBlitz, required this.onChat});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Row(children: [
      Expanded(
          child: _PracticeChip(
              icon: Icons.description_outlined,
              label: 'Prep',
              color: cs.primary,
              onTap: onPrep)),
      const SizedBox(width: 10),
      Expanded(
          child: _PracticeChip(
              icon: Icons.bolt_rounded,
              label: 'Blitz',
              color: cs.tertiary,
              onTap: onBlitz)),
      const SizedBox(width: 10),
      Expanded(
          child: _PracticeChip(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'AI Chat',
              color: cs.secondary,
              onTap: onChat)),
    ]);
  }
}

class _PracticeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PracticeChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    // FIX: Replaced GestureDetector with Material & InkWell for "Prep/Blitz/Chat" chips
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.5), width: 2.0),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticService.instance.medium();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: color.withOpacity(0.3), width: 1.5),
                    ),
                    child: Icon(icon, color: color, size: 20)),
                const SizedBox(height: 10),
                Text(label,
                    style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── RESTORED CLEAN HISTORY FOLDER ─────────────────────────────────────────────
class _HistoryFolder extends StatelessWidget {
  final VoidCallback onViewAll;
  const _HistoryFolder({required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    // FIX: Replaced GestureDetector with Material & InkWell for "History Folder"
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.primaryContainer, width: 2.5),
        boxShadow: [
          BoxShadow(
              color: cs.shadow.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticService.instance.medium();
            onViewAll();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: cs.primary.withOpacity(0.12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_outlined, color: cs.primary, size: 32),
                      const SizedBox(width: 14),
                      Icon(Icons.history_rounded,
                          size: 28, color: cs.primary.withOpacity(0.6)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            cs.surfaceContainerLow.withOpacity(0),
                            cs.surfaceContainerLow
                          ]),
                    ),
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Session History',
                        style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            color: cs.primary,
                            height: 1.25)),
                    const SizedBox(height: 8),
                    Text(
                        'Access all your practice sessions. Review what you said, spot filler words, and track your progress over time.',
                        style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            color: cs.onSurfaceVariant,
                            height: 1.5)),
                    const SizedBox(height: 16),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('VIEW FULL HISTORY',
                          style: tt.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                              letterSpacing: 2.0)),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded,
                          color: cs.primary, size: 16),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SECTION LABEL (Properly toggling elements based on theme) ─────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;

    if (isParadise) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                const BoxDecoration(color: _pFuchsia, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: _pBrown,
                  letterSpacing: 0.3,
                  height: 1.2)),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: List.generate(
                  8,
                  (i) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Container(
                              height: 1.5,
                              color: i.isEven
                                  ? _pFuchsia.withOpacity(0.4)
                                  : _pOrange.withOpacity(0.25)),
                        ),
                      )),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.spa_rounded, color: _pGreen, size: 12),
        ],
      );
    }

    // Default theme: Clean Georgia text and dashed lines, but NO dot/flower
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: cs.onSurface,
                letterSpacing: 0.3,
                height: 1.2)),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: List.generate(
                8,
                (i) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Container(
                            height: 1.5,
                            color: i.isEven
                                ? cs.primary.withOpacity(0.4)
                                : cs.primaryContainer.withOpacity(0.5)),
                      ),
                    )),
          ),
        ),
      ],
    );
  }
}

class _MicFab extends StatelessWidget {
  final VoidCallback onTap;
  const _MicFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    // FIX: Replaced GestureDetector with Material & InkWell for FAB
    return Container(
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary, width: 2.5),
        boxShadow: [
          BoxShadow(
              color: cs.primaryContainer.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: cs.primary.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticService.instance.medium();
            onTap();
          },
          child: SizedBox(
            width: 60,
            height: 60,
            child: Icon(Icons.mic_none_rounded,
                color: cs.onPrimaryContainer, size: 28),
          ),
        ),
      ),
    );
  }
}

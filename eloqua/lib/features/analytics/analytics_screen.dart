import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/constants/strings.dart';
import '../../core/services/session_service.dart';
import '../../core/config/app_config.dart';
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

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const _mockScores = [58, 65, 72, 68, 74, 80, 77];
  static const _mockDims = {
    'Clarity': 75,
    'Pacing': 68,
    'Grammar': 80,
    'Confidence': 70
  };

  static const _mockMilestones = [
    ('30 Day Streak', '3 months ago', Icons.local_fire_department_rounded),
    ('Polyglot Mode', '2 weeks ago', Icons.translate_rounded),
    ('Eloquent Speaker', 'Last week', Icons.mic_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SessionService>();
    final hasData = sessions.totalSessions > 0;

    final scores = hasData ? sessions.recentScores : _mockScores;
    final dims = hasData
        ? sessions.dimensionAverages.map(
            (k, v) => MapEntry(k[0].toUpperCase() + k.substring(1), v.round()))
        : _mockDims;

    final best = hasData ? sessions.bestScore : 80;
    final avg = hasData ? sessions.averageScore.round() : 74;
    final total = hasData ? sessions.totalSessions : 7;

    final totalSecs = hasData
        ? sessions.sessions.fold<int>(0, (s, e) => s + e.durationSeconds)
        : 0;
    final totalTimeStr =
        totalSecs >= 3600 ? '${(totalSecs ~/ 3600)}h' : '${(totalSecs ~/ 60)}m';

    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: _TopBar(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),

                    // ── Header ────────────────────────────────────────────────
                    const _SectionLabel('Performance Overview'),
                    const SizedBox(height: 12),
                    Text(
                      'Your Learning\nPath',
                      style: isParadise
                          ? GoogleFonts.playfairDisplay(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: _pBrown,
                              height: 1.1)
                          : tt.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                              height: 1.1),
                    ),

                    const SizedBox(height: 24),

                    if (!hasData && AppConfig.showMockData) const _DemoBanner(),

                    const SizedBox(height: 4),

                    // ── Chart ─────────────────────────────────────────────────
                    _DailyProgressBar(scores: scores),

                    const SizedBox(height: 20),

                    // ── Stat cards ────────────────────────────────────────────
                    _StatCardsRow(
                      total: total,
                      timeStr: totalTimeStr,
                      avg: avg,
                    ),

                    const SizedBox(height: 20),

                    // ── Peer rating card ──────────────────────────────────────
                    _PeerRatingCard(best: best),

                    const SizedBox(height: 28),
                    Divider(
                        color: isParadise
                            ? _pOrange.withOpacity(0.2)
                            : cs.outline.withOpacity(0.12),
                        thickness: 0.5),
                    const SizedBox(height: 28),

                    // ── Skill breakdown ───────────────────────────────────────
                    const _SectionLabel('Skill Analytics'),
                    const SizedBox(height: 12),
                    Text(
                      'Dimension breakdown',
                      style: isParadise
                          ? GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _pBrown)
                          : tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: cs.onSurface),
                    ),
                    const SizedBox(height: 16),
                    _BreakdownCard(dims: dims),

                    const SizedBox(height: 24),

                    const SizedBox(height: 28),
                    Divider(
                        color: isParadise
                            ? _pOrange.withOpacity(0.2)
                            : cs.outline.withOpacity(0.12),
                        thickness: 0.5),

                    // ── Tip Card ──────────────────────────────────────────────
                    _TipCard(dims: dims),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── GLOBAL THEMED COMPONENTS ─────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

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
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        Text('ANALYTICS',
            style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onPrimary,
                letterSpacing: 3.0)),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.onPrimary.withOpacity(0.15),
            shape: BoxShape.circle,
            border:
                Border.all(color: cs.onPrimary.withOpacity(0.4), width: 1.0),
          ),
          child: Icon(Icons.notifications_none_rounded,
              size: 18, color: cs.onPrimary),
        ),
      ]),
    );
  }
}

// ── SECTION LABEL (Aligned uniformly with home_screen.dart) ───────────────────
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

    // Default theme: Clean text and dashed lines, NO dot/flower
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

class _StatCardsRow extends StatelessWidget {
  final int total, avg;
  final String timeStr;

  const _StatCardsRow({
    required this.total,
    required this.timeStr,
    required this.avg,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;

    final bigCardColor = isParadise ? _pTurquoise : cs.primary;
    final bigCardOnColor = isParadise ? _pWhite : cs.onPrimary;
    final smallCardColor =
        isParadise ? _pCream : cs.surfaceVariant.withOpacity(0.5);
    final accentColor = isParadise ? _pFuchsia : cs.primary;

    return Row(children: [
      Expanded(
        flex: 3,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bigCardColor,
            borderRadius: BorderRadius.circular(20),
            border: isParadise ? Border.all(color: _pOrange, width: 2.0) : null,
            boxShadow: isParadise
                ? [
                    BoxShadow(
                        color: _pTurquoise.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ]
                : [
                    BoxShadow(
                        color: bigCardColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8))
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: isParadise
                        ? _pOrange
                        : bigCardOnColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10)),
                child:
                    Icon(Icons.school_rounded, color: bigCardOnColor, size: 16),
              ),
              const SizedBox(height: 14),
              Text('Sessions\nCompleted',
                  style: isParadise
                      ? GoogleFonts.barlowCondensed(
                          color: _pWhite.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          height: 1.3)
                      : tt.labelSmall?.copyWith(
                          color: bigCardOnColor.withOpacity(0.65),
                          height: 1.3)),
              const SizedBox(height: 6),
              Text(
                '$total',
                style: isParadise
                    ? GoogleFonts.oswald(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: bigCardOnColor,
                        height: 1)
                    : tt.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: bigCardOnColor,
                        height: 1),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: smallCardColor,
              borderRadius: BorderRadius.circular(20),
              border: isParadise
                  ? Border.all(color: _pOrange.withOpacity(0.5))
                  : Border.all(color: cs.outline.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hours\nPracticed',
                    style: isParadise
                        ? GoogleFonts.barlowCondensed(
                            color: _pBrown.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            height: 1.3)
                        : tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant, height: 1.3)),
                const SizedBox(height: 8),
                Text(
                  timeStr.isEmpty ? '0m' : timeStr,
                  style: isParadise
                      ? GoogleFonts.oswald(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _pBrown,
                          height: 1)
                      : tt.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          height: 1),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 4,
                    backgroundColor: isParadise
                        ? _pOrange.withOpacity(0.2)
                        : cs.outline.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(accentColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: smallCardColor,
              borderRadius: BorderRadius.circular(20),
              border: isParadise
                  ? Border.all(color: _pOrange.withOpacity(0.5))
                  : Border.all(color: cs.outline.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accuracy',
                    style: isParadise
                        ? GoogleFonts.barlowCondensed(
                            color: _pBrown.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0)
                        : tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(
                  '$avg%',
                  style: isParadise
                      ? GoogleFonts.oswald(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _pGreen,
                          height: 1)
                      : tt.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                          height: 1),
                ),
              ],
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _PeerRatingCard extends StatelessWidget {
  final int best;

  const _PeerRatingCard({required this.best});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isParadise ? _pYellow : cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isParadise ? _pOrange : cs.outline.withOpacity(0.1),
          width: isParadise ? 2.0 : 1.0,
        ),
        boxShadow: isParadise
            ? [
                BoxShadow(
                    color: _pOrange.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 5))
              ]
            : [
                BoxShadow(
                    color: cs.shadow.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOP PEER RATING',
                  style: isParadise
                      ? GoogleFonts.barlowCondensed(
                          color: _pBrown.withOpacity(0.8),
                          letterSpacing: 1.5,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)
                      : tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.1,
                          fontSize: 10)),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                      color: isParadise ? _pFuchsia : cs.tertiary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '4.5 / 5.0 Stars',
                style: isParadise
                    ? GoogleFonts.oswald(
                        color: _pBrown,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)
                    : tt.labelMedium?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: best / 100,
                  strokeWidth: 6,
                  backgroundColor: isParadise
                      ? _pBrown.withOpacity(0.1)
                      : cs.outline.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation(
                      isParadise ? _pFuchsia : cs.primary),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$best',
                      style: isParadise
                          ? GoogleFonts.oswald(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: _pBrown,
                              height: 1)
                          : tt.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              height: 1)),
                  const SizedBox(height: 2),
                  Text('score',
                      style: isParadise
                          ? GoogleFonts.nunito(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: _pBrown.withOpacity(0.7))
                          : tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class _DailyProgressBar extends StatelessWidget {
  final List<int> scores;

  const _DailyProgressBar({required this.scores});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;

    final lineColor = isParadise ? _pOrange : cs.primary;
    final bgColor = isParadise ? _pCream : cs.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('DAILY PROGRESS',
              style: isParadise
                  ? GoogleFonts.barlowCondensed(
                      color: _pBrown.withOpacity(0.8),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      fontSize: 11)
                  : tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant, letterSpacing: 1.2)),
          const Spacer(),
          Text('${scores.length} days',
              style: isParadise
                  ? GoogleFonts.nunito(
                      color: _pBrown.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                      fontSize: 12)
                  : tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(4, 16, 8, 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: isParadise
                ? Border.all(color: _pOrange.withOpacity(0.3), width: 1.5)
                : Border.all(color: cs.outline.withOpacity(0.1), width: 1.0),
            boxShadow: isParadise
                ? [
                    BoxShadow(
                        color: _pBrown.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : [
                    BoxShadow(
                        color: cs.shadow.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
          ),
          child: SizedBox(
            height: 140,
            child: LineChart(LineChartData(
              minY: 0,
              maxY: 100,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: isParadise
                      ? _pBrown.withOpacity(0.1)
                      : cs.outline.withOpacity(0.15),
                  strokeWidth: 0.5,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: true,
                  interval: 25,
                  reservedSize: 32,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}',
                    style: TextStyle(
                        fontSize: 9,
                        color: isParadise
                            ? _pBrown.withOpacity(0.7)
                            : cs.onSurfaceVariant),
                  ),
                )),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= scores.length) return const Text('');
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('S${i + 1}',
                          style: TextStyle(
                              fontSize: 8,
                              color: isParadise
                                  ? _pBrown.withOpacity(0.7)
                                  : cs.onSurfaceVariant)),
                    );
                  },
                )),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: scores
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                      .toList(),
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: lineColor,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    getDotPainter: (_, __, ___, i) => FlDotCirclePainter(
                      radius: i == scores.length - 1 ? 4 : 2.5,
                      color: lineColor,
                      strokeWidth: i == scores.length - 1 ? 2 : 0,
                      strokeColor: bgColor,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        lineColor.withOpacity(isParadise ? 0.2 : 0.08),
                        lineColor.withOpacity(0.0)
                      ],
                    ),
                  ),
                ),
              ],
            )),
          ),
        ),
      ],
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final Map<String, int> dims;

  const _BreakdownCard({required this.dims});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;

    final entries = dims.entries.toList();
    final defaultColors = isParadise
        ? [_pFuchsia, _pTurquoise, _pOrange, _pGreen]
        : [cs.primary, cs.secondary, cs.tertiary, cs.primaryContainer];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isParadise ? _pWhite : cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: isParadise
            ? Border.all(color: _pTurquoise.withOpacity(0.5), width: 1.5)
            : Border.all(color: cs.outline.withOpacity(0.1), width: 1.0),
        boxShadow: isParadise
            ? [
                BoxShadow(
                    color: _pTurquoise.withOpacity(0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 5))
              ]
            : [
                BoxShadow(
                    color: cs.shadow.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final color = defaultColors[e.key % defaultColors.length];
          final score = e.value.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(e.value.key,
                      style: isParadise
                          ? GoogleFonts.oswald(
                              fontWeight: FontWeight.w600,
                              color: _pBrown,
                              fontSize: 14,
                              letterSpacing: 0.5)
                          : tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('$score%',
                      style: isParadise
                          ? GoogleFonts.oswald(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)
                          : tt.titleMedium?.copyWith(
                              color: color, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: isParadise
                        ? color.withOpacity(0.15)
                        : cs.outline.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final Map<String, int> dims;

  const _TipCard({required this.dims});

  static const _patterns = {
    'Clarity':
        'You score highest on Clarity on Fridays (81%). Your best sessions happen when you practice in the morning.',
    'Pacing':
        'Your Pacing dips after 4 sessions in a row. Consider a 10-minute break to reset your rhythm.',
    'Grammar':
        'Grammar improves 12% after you review notes before speaking. Writing helps your accuracy.',
    'Confidence':
        "You're most confident on days after completing a milestone. Success builds momentum.",
  };

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;
    final weakest = dims.entries.reduce((a, b) => a.value < b.value ? a : b);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isParadise ? _pOrange : cs.primary,
        borderRadius: BorderRadius.circular(24),
        border: isParadise ? Border.all(color: _pFuchsia, width: 2.0) : null,
        boxShadow: isParadise
            ? [
                BoxShadow(
                    color: _pFuchsia.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10))
              ]
            : [
                BoxShadow(
                    color: cs.primary.withOpacity(0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 10))
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PATTERN RECOGNITION',
              style: isParadise
                  ? GoogleFonts.barlowCondensed(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _pYellow,
                      letterSpacing: 2.0)
                  : tt.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onPrimary.withOpacity(0.8),
                      letterSpacing: 2.0)),
          const SizedBox(height: 12),
          Text(weakest.key,
              style: isParadise
                  ? GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: _pWhite)
                  : tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: cs.onPrimary)),
          const SizedBox(height: 4),
          Text('${weakest.value} / 100 — Room to grow',
              style: isParadise
                  ? GoogleFonts.nunito(
                      fontSize: 13, color: _pCream, fontStyle: FontStyle.italic)
                  : tt.bodySmall
                      ?.copyWith(color: cs.onPrimary.withOpacity(0.8))),
          const SizedBox(height: 20),
          Divider(
              color: isParadise
                  ? _pYellow.withOpacity(0.3)
                  : cs.onPrimary.withOpacity(0.15),
              thickness: 0.5),
          const SizedBox(height: 20),
          Text(_patterns[weakest.key] ?? '',
              style: isParadise
                  ? GoogleFonts.nunito(
                      fontSize: 15,
                      color: _pWhite,
                      height: 1.6,
                      fontWeight: FontWeight.w600)
                  : tt.bodyMedium?.copyWith(
                      color: cs.onPrimary.withOpacity(0.9), height: 1.65)),
        ],
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isParadise
            ? _pYellow.withOpacity(0.2)
            : cs.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isParadise
                ? _pOrange.withOpacity(0.3)
                : cs.primary.withOpacity(0.15),
            width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
              color: isParadise ? _pOrange : cs.primary,
              shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Demo data — complete a session to see live analytics.',
            style: isParadise
                ? GoogleFonts.nunito(
                    fontSize: 12, color: _pBrown, fontWeight: FontWeight.w600)
                : tt.labelSmall?.copyWith(color: cs.primary),
          ),
        ),
      ]),
    );
  }
}

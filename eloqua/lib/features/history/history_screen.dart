import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/strings.dart';
import '../../core/services/session_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/config/app_config.dart';
import 'session_detail_screen.dart';
import '../../core/theme/theme_manager_ext.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _currentFilter = 'All'; // 'All', 'Spontaneous', 'Preparation'

  String _calculateTotalTime(SessionService service) {
    final sessionsToCalculate = service.sessions;

    final totalSeconds = sessionsToCalculate.fold<int>(
        0, (sum, session) => sum + session.durationSeconds);

    final double hours = totalSeconds / 3600.0;
    return hours >= 1.0
        ? '${hours.toStringAsFixed(1)} hrs'
        : '${(totalSeconds / 60).toStringAsFixed(1)} min';
  }

  void _showFilterSheet() {
    HapticService.instance.light();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter History',
                style: context.tt.titleLarge?.copyWith(
                    fontFamily: context.isParadise ? 'Georgia' : null,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _FilterOption(
              label: 'All Sessions',
              isSelected: _currentFilter == 'All',
              onTap: () {
                setState(() => _currentFilter = 'All');
                Navigator.pop(ctx);
              },
            ),
            _FilterOption(
              label: 'Spontaneous Mode',
              isSelected: _currentFilter == 'Spontaneous',
              onTap: () {
                setState(() => _currentFilter = 'Spontaneous');
                Navigator.pop(ctx);
              },
            ),
            _FilterOption(
              label: 'Preparation Mode',
              isSelected: _currentFilter == 'Preparation',
              onTap: () {
                setState(() => _currentFilter = 'Preparation');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, SessionService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear History',
            style: TextStyle(
                fontFamily: context.isParadise ? 'Georgia' : null,
                fontWeight: FontWeight.w700)),
        content: const Text(
            'Delete all session history? This cannot be undone.',
            style: TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              service.clearAll(AuthService.instance.userId!);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.cs.error,
              foregroundColor: context.cs.onError,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SessionService>();
    final allSessions = service.sessions;

    // ── Apply the active filter ──
    final displayedSessions = allSessions.where((s) {
      if (_currentFilter == 'All') return true;
      if (_currentFilter == 'Spontaneous') return s.mode == 'spontaneous';
      if (_currentFilter == 'Preparation') return s.mode == 'preparation';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: context.cs.surface,
      appBar: AppBar(
        backgroundColor: context.cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () {
            HapticService.instance.light();
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_rounded,
              color: context.cs.onSurface, size: 20),
        ),
        title: Text(
          AppStrings.historyTitle,
          style: context.tt.titleLarge?.copyWith(
            fontFamily: context.isParadise ? 'Georgia' : null,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.cs.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.notifications_outlined,
                color: context.cs.onSurface, size: 18),
          ),
        ],
      ),
      body: allSessions.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.history,
                  size: 48, color: context.cs.primary.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text(AppStrings.historyEmpty,
                  style: context.tt.bodyMedium
                      ?.copyWith(color: context.cs.onSurfaceVariant)),
            ]))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Journey Hero
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _JourneyHero(
                    service: service,
                    timeDisplay: _calculateTotalTime(service),
                  ),
                )),

                // ── Filter row
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _FilterChip(
                      label:
                          _currentFilter == 'All' ? 'Filter' : _currentFilter,
                      icon: Icons.tune_rounded,
                      onTap: _showFilterSheet,
                      filled: _currentFilter != 'All',
                    ),
                  ),
                )),

                // ── Recent sessions header
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Row(children: [
                    Text('Recent Activities',
                        style: context.tt.titleMedium?.copyWith(
                          fontFamily: context.isParadise ? 'Georgia' : null,
                          fontWeight: FontWeight.w700,
                        )),
                    const Spacer(),
                    if (service.sessions.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showClearDialog(context, service),
                        child: Text('Clear',
                            style: context.tt.labelSmall
                                ?.copyWith(color: context.cs.error)),
                      ),
                  ]),
                )),

                // ── Session cards
                if (displayedSessions.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text('No sessions match this filter.',
                            style:
                                TextStyle(color: context.cs.onSurfaceVariant)),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SessionCard(session: displayedSessions[i]),
                      ),
                      childCount: displayedSessions.length,
                    )),
                  ),
              ],
            ),
    );
  }
}

// ── Filter Option Item (For Bottom Sheet) ─────────────────────────────────────
class _FilterOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(label,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (context.isParadise
                      ? const Color(0xFFE8407A)
                      : context.cs.primary)
                  : context.cs.onSurface)),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded,
              color: context.isParadise
                  ? const Color(0xFFE8407A)
                  : context.cs.primary)
          : null,
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _FilterChip(
      {required this.label,
      required this.icon,
      this.filled = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        context.isParadise ? const Color(0xFFE8407A) : context.cs.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? primaryColor : context.cs.surfaceVariant,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 14,
              color:
                  filled ? context.cs.onPrimary : context.cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    filled ? context.cs.onPrimary : context.cs.onSurfaceVariant,
              )),
        ]),
      ),
    );
  }
}

// ── Journey Hero ──────────────────────────────────────────────────────────────
class _JourneyHero extends StatelessWidget {
  final SessionService service;
  final String timeDisplay;

  const _JourneyHero({required this.service, required this.timeDisplay});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Session History',
          style: context.tt.headlineLarge?.copyWith(
            fontFamily: context.isParadise ? 'Georgia' : null,
            fontWeight: FontWeight.w700,
          )),
      const SizedBox(height: 4),
      Text(
          'Your progress through mastery, documented\nthrough every session and exercise.',
          style: context.tt.bodySmall
              ?.copyWith(color: context.cs.onSurfaceVariant, height: 1.5)),
      const SizedBox(height: 20),

      // Stats row — Total Time / Average Score / Streak
      Row(children: [
        Expanded(
            child: _StatCard(
          label: 'TOTAL TIME',
          value: timeDisplay,
          icon: Icons.access_time_rounded,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
          label: 'AVG SCORE',
          value: '${service.averageScore.round()}%',
          icon: Icons.show_chart_rounded,
          accent: true,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
          label: 'STREAK',
          value: '${service.currentStreak} Days',
          icon: Icons.local_fire_department_rounded,
        )),
      ]),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool accent;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      this.accent = false});

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
        context.isParadise ? const Color(0xFFE8407A) : context.cs.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent ? accentColor : context.cs.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon,
            size: 16, color: accent ? context.cs.onPrimary : accentColor),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
              fontFamily: context.isParadise ? 'Georgia' : null,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: accent ? context.cs.onPrimary : context.cs.onSurface,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: accent
                  ? context.cs.onPrimary.withOpacity(0.8)
                  : context.cs.onSurfaceVariant,
            )),
      ]),
    );
  }
}

// ── Session Card ──────────────────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final SessionData session;
  const _SessionCard({required this.session});

  Color _scoreColor(int s, ColorScheme cs, bool isParadise) {
    if (s >= 80)
      return isParadise ? const Color(0xFF2E9E56) : const Color(0xFF2D5428);
    if (s >= 60)
      return isParadise ? const Color(0xFFD4561E) : const Color(0xFFF57C00);
    return isParadise ? const Color(0xFFE8407A) : cs.error;
  }

  String _formattedDuration(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inHours < 4) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  IconData _modeIcon(String mode) =>
      mode == 'preparation' ? Icons.description_outlined : Icons.bolt_rounded;

  @override
  Widget build(BuildContext context) {
    final scoreColor =
        _scoreColor(session.overallScore, context.cs, context.isParadise);
    final primaryColor =
        context.isParadise ? const Color(0xFFE8407A) : context.cs.primary;

    return Container(
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.cs.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
              color: context.cs.shadow.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  SessionDetailScreen(session: session),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
                child: child,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_modeIcon(session.mode),
                      color: primaryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(session.topic,
                          style: context.tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(session.persona,
                          style: context.tt.labelSmall
                              ?.copyWith(color: context.cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ])),
                const SizedBox(width: 8),
                // Score badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('${session.overallScore}/100',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                      )),
                ),
              ]),

              const SizedBox(height: 16),
              Divider(color: context.cs.outline.withOpacity(0.1), height: 1),
              const SizedBox(height: 14),

              // Meta row
              Row(children: [
                _Tag(label: _formattedDuration(session.durationSeconds)),
                const SizedBox(width: 6),
                _Tag(label: '${session.fillerCount} fillers'),
                const SizedBox(width: 6),
                _Tag(label: _formatDate(session.date)),
                const Spacer(),
                Text(
                    session.overallScore >= 80
                        ? 'Expert'
                        : session.overallScore >= 70
                            ? 'Great'
                            : 'Keep Going',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: scoreColor)),
              ]),

              const SizedBox(height: 14),

              // Score bars
              Row(children: [
                _MiniBar(
                    label: 'Clarity',
                    score: session.clarity,
                    primaryColor: primaryColor),
                const SizedBox(width: 8),
                _MiniBar(
                    label: 'Pacing',
                    score: session.pacing,
                    primaryColor: primaryColor),
                const SizedBox(width: 8),
                _MiniBar(
                    label: 'Grammar',
                    score: session.grammar,
                    primaryColor: primaryColor),
                const SizedBox(width: 8),
                _MiniBar(
                    label: 'Conf.',
                    score: session.confidence,
                    primaryColor: primaryColor),
                const SizedBox(width: 8),
                _MiniBar(
                    // ← add
                    label: 'Relev.',
                    score: session.relevance,
                    primaryColor: primaryColor),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: context.cs.surfaceVariant,
          borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              color: context.cs.onSurfaceVariant,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final int score;
  final Color primaryColor;

  const _MiniBar(
      {required this.label, required this.score, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              fontSize: 9,
              color: context.cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3)),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: LinearProgressIndicator(
          value: score / 100,
          minHeight: 4,
          backgroundColor: context.cs.outline.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation(primaryColor),
        ),
      ),
    ]));
  }
}

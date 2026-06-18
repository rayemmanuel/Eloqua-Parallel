import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/models/vibe_persona.dart';
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

// ── _CircuitPlayer ─────────────────────────────────────────────────────────────
class _CircuitPlayer {
  final String userId;
  final String displayName;
  final int jarLevel;
  final int avgScore;
  final int sessions;
  final VibePersona persona;
  final bool isMe;

  const _CircuitPlayer({
    required this.userId,
    required this.displayName,
    required this.jarLevel,
    required this.avgScore,
    required this.sessions,
    required this.persona,
    this.isMe = false,
  });

  factory _CircuitPlayer.fromEntry(LeaderboardEntry e) => _CircuitPlayer(
        userId: e.userId,
        displayName: e.name,
        jarLevel: e.jarLevel,
        avgScore: e.avgScore.round(),
        sessions: e.sessions,
        persona: VibePersona.fromScores(
          clarity: e.avgScore.round(),
          pacing: e.avgScore.round() - 5,
          grammar: e.avgScore.round() + 3,
          confidence: e.avgScore.round() - 8,
        ),
        isMe: e.isMe,
      );
}

// ── CircuitLeaderboardScreen ───────────────────────────────────────────────────
class CircuitLeaderboardScreen extends StatefulWidget {
  const CircuitLeaderboardScreen({super.key});

  @override
  State<CircuitLeaderboardScreen> createState() =>
      _CircuitLeaderboardScreenState();
}

class _CircuitLeaderboardScreenState extends State<CircuitLeaderboardScreen> {
  List<_CircuitPlayer> _board = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = context.read<AuthService>().token;
    if (token == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Not logged in.';
        });
      }
      return;
    }

    final result = await ApiService.instance.getLeaderboard(token);

    if (!mounted) return;

    if (result.success && result.data != null) {
      setState(() {
        _board = result.data!.map(_CircuitPlayer.fromEntry).toList();
        _loading = false;
      });
    } else {
      setState(() {
        _error = result.error ?? 'Failed to load leaderboard.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.isParadise;

    return Scaffold(
      backgroundColor: isParadise ? _pCream : cs.surface,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(children: [
            _TopBar(
              isParadise: isParadise,
              onBack: () => Navigator.pop(context),
              trailing: GestureDetector(
                onTap: () {
                  HapticService.instance.light();
                  _fetchLeaderboard();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isParadise
                        ? _pYellow.withOpacity(0.9)
                        : cs.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isParadise
                          ? _pBrown.withOpacity(0.2)
                          : cs.onPrimary.withOpacity(0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Row(children: [
                    Icon(Icons.sync_rounded,
                        size: 14, color: isParadise ? _pBrown : cs.onPrimary),
                    const SizedBox(width: 6),
                    Text('Sync',
                        style: isParadise
                            ? GoogleFonts.nunito(
                                fontSize: 12,
                                color: _pBrown,
                                fontWeight: FontWeight.w800)
                            : TextStyle(
                                fontSize: 12,
                                color: cs.onPrimary,
                                fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),

            // Tab Bar
            Container(
              color: isParadise ? _pCream : cs.surface,
              child: TabBar(
                indicatorColor: isParadise ? _pFuchsia : cs.primary,
                indicatorWeight: 3.0,
                labelColor: isParadise ? _pFuchsia : cs.primary,
                unselectedLabelColor:
                    isParadise ? _pBrown.withOpacity(0.4) : cs.onSurfaceVariant,
                labelStyle: isParadise
                    ? GoogleFonts.oswald(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0)
                    : tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'CIRCUIT'),
                  Tab(text: 'RANKINGS'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCircuitView(context),
                  _buildRankingsView(context),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Tab 1: Circuit View (Bento Boxes) ───────────────────────────────────────
  Widget _buildCircuitView(BuildContext context) {
    final cs = context.cs;
    final isParadise = context.isParadise;

    if (_loading) {
      return Center(
          child: CircularProgressIndicator(
              color: isParadise ? _pFuchsia : cs.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 48,
                color: isParadise
                    ? _pFuchsia.withOpacity(0.5)
                    : cs.error.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(
                    color: isParadise ? _pBrown : cs.onSurfaceVariant,
                    fontSize: 14)),
          ],
        ),
      );
    }

    if (_board.isEmpty) {
      return Center(
        child: Text('No players yet. Complete a session to appear here!',
            style: TextStyle(
                color:
                    isParadise ? _pBrown.withOpacity(0.5) : cs.onSurfaceVariant,
                fontSize: 14),
            textAlign: TextAlign.center),
      );
    }

    final top3 = _board.take(3).toList();
    final rest = _board.skip(3).toList();

    return RefreshIndicator(
      color: isParadise ? _pFuchsia : cs.primary,
      backgroundColor: isParadise ? _pWhite : cs.surface,
      onRefresh: _fetchLeaderboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Bento Top 3 ─────────────────────────────────────────────────────
          if (top3.isNotEmpty) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 12,
                child: _BentoBlock(
                  player: top3[0],
                  rank: 1,
                  height: 260,
                  showScore: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 11,
                child: Column(children: [
                  if (top3.length > 1)
                    _BentoBlock(
                      player: top3[1],
                      rank: 2,
                      height: 124,
                    ),
                  if (top3.length > 1) const SizedBox(height: 12),
                  if (top3.length > 2)
                    _BentoBlock(
                      player: top3[2],
                      rank: 3,
                      height: 124,
                    ),
                ]),
              ),
            ]),
            const SizedBox(height: 32),
          ],

          // ── Full Rankings (Circuit Style) ───────────────────────────────────
          if (rest.isNotEmpty) ...[
            Text('FULL CIRCUIT',
                style: isParadise
                    ? GoogleFonts.barlowCondensed(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _pBrown.withOpacity(0.6),
                        letterSpacing: 1.5)
                    : context.tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...rest.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CircuitListRow(
                    player: e.value,
                    rank: e.key + 4,
                  ),
                )),
          ],
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  // ── Tab 2: Top 10 Rankings View ─────────────────────────────────────────────
  Widget _buildRankingsView(BuildContext context) {
    final cs = context.cs;
    final isParadise = context.isParadise;

    if (_loading) {
      return Center(
          child: CircularProgressIndicator(
              color: isParadise ? _pFuchsia : cs.primary));
    }

    if (_error != null) {
      return Center(
          child: Text(_error!,
              style: TextStyle(
                  color: isParadise ? _pBrown : cs.onSurfaceVariant)));
    }

    if (_board.isEmpty) {
      return Center(
        child: Text('No players yet.',
            style: TextStyle(
                color: isParadise
                    ? _pBrown.withOpacity(0.5)
                    : cs.onSurfaceVariant)),
      );
    }

    // Cater to exactly 10 spots
    final top10 = _board.take(10).toList();

    return RefreshIndicator(
      color: isParadise ? _pFuchsia : cs.primary,
      backgroundColor: isParadise ? _pWhite : cs.surface,
      onRefresh: _fetchLeaderboard,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: top10.length,
        itemBuilder: (context, index) {
          final player = top10[index];
          return _RankingRow(player: player, rank: index + 1);
        },
      ),
    );
  }
}

// ── GLOBAL THEMED COMPONENTS ─────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool isParadise;
  final VoidCallback onBack;
  final Widget? trailing;

  const _TopBar(
      {required this.isParadise, required this.onBack, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: isParadise ? _pFuchsia : cs.primary,
        boxShadow: [
          BoxShadow(
              color: cs.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () {
            HapticService.instance.light();
            onBack();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isParadise ? _pOrange : cs.onPrimary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isParadise ? _pYellow : cs.onPrimary.withOpacity(0.4),
                width: isParadise ? 2.0 : 1.0,
              ),
              boxShadow: isParadise
                  ? [
                      BoxShadow(
                          color: _pOrange.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]
                  : null,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isParadise ? _pYellow : cs.onPrimary,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: isParadise
              ? Text(
                  'LEADERBOARD',
                  style: GoogleFonts.oswald(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _pWhite,
                    letterSpacing: 3.0,
                  ),
                )
              : Text(
                  'LEADERBOARD',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onPrimary,
                    letterSpacing: 2.0,
                  ),
                ),
        ),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

// ── _BentoBlock ────────────────────────────────────────────────────────────────
class _BentoBlock extends StatelessWidget {
  final _CircuitPlayer player;
  final int rank;
  final double height;
  final bool showScore;

  const _BentoBlock({
    required this.player,
    required this.rank,
    required this.height,
    this.showScore = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.isParadise;

    Color bgColor;
    Color textColor;
    Color subTextColor;
    Color progressBg;
    Color progressValue;

    if (isParadise) {
      bgColor = rank == 1 ? _pYellow : (rank == 2 ? _pTurquoise : _pOrange);
      textColor = rank == 1 ? _pBrown : _pWhite;
      subTextColor = textColor.withOpacity(0.7);
      progressBg = textColor.withOpacity(0.15);
      progressValue = textColor;
    } else {
      bgColor =
          rank == 1 ? cs.primary : (rank == 2 ? cs.secondary : cs.tertiary);
      textColor = rank == 1
          ? cs.onPrimary
          : (rank == 2 ? cs.onSecondary : cs.onTertiary);
      subTextColor = textColor.withOpacity(0.8);
      progressBg = textColor.withOpacity(0.2);
      progressValue = textColor;
    }

    final isFirst = rank == 1;

    return Container(
      height: height,
      padding: EdgeInsets.all(isFirst ? 18 : 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: player.isMe
            ? Border.all(
                color: isParadise ? _pFuchsia : cs.onSurface, width: 3.0)
            : null,
        boxShadow: isParadise
            ? [
                BoxShadow(
                    color: bgColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8))
              ]
            : [
                BoxShadow(
                    color: cs.shadow.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6))
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('#$rank',
                  style: TextStyle(
                      color: textColor,
                      fontFamily: isParadise ? null : 'Georgia',
                      fontSize: isFirst ? 14 : 12,
                      fontWeight: FontWeight.w800)),
            ),
            if (player.isMe) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isParadise ? _pFuchsia : cs.onSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('You',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isParadise ? _pWhite : cs.surface)),
              ),
            ],
            const Spacer(),
            if (isFirst)
              Icon(Icons.workspace_premium_rounded, color: textColor, size: 28),
          ]),

          const Spacer(),

          // Much smaller text to fit inside the Bento boxes
          Text(
            player.displayName,
            style: isParadise
                ? GoogleFonts.oswald(
                    fontSize: isFirst ? 20 : 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.1)
                : tt.titleMedium?.copyWith(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    fontSize: isFirst ? 18 : 15,
                    height: 1.1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(children: [
            Icon(player.persona.icon,
                size: isFirst ? 14 : 12, color: subTextColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(player.persona.title,
                  style: isParadise
                      ? GoogleFonts.nunito(
                          fontSize: isFirst ? 12 : 11,
                          color: subTextColor,
                          fontWeight: FontWeight.w700)
                      : tt.labelSmall?.copyWith(
                          color: subTextColor, fontSize: isFirst ? 11 : 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),

          const SizedBox(height: 10),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Jar Level',
                style: TextStyle(
                    fontSize: isFirst ? 11 : 9,
                    fontWeight: FontWeight.w700,
                    color: subTextColor,
                    letterSpacing: 0.5)),
            Text('${player.jarLevel}',
                style: TextStyle(
                    fontSize: isFirst ? 12 : 10,
                    fontWeight: FontWeight.w800,
                    color: textColor)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (player.jarLevel / 100).clamp(0.0, 1.0),
              color: progressValue,
              backgroundColor: progressBg,
              minHeight: isFirst ? 8 : 5,
            ),
          ),

          if (showScore) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Avg Score',
                    style: isParadise
                        ? GoogleFonts.barlowCondensed(
                            fontSize: 14,
                            color: subTextColor,
                            fontWeight: FontWeight.w700)
                        : tt.labelMedium?.copyWith(color: subTextColor)),
                Text('${player.avgScore}',
                    style: isParadise
                        ? GoogleFonts.oswald(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            height: 1)
                        : TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            height: 1)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── _CircuitListRow ───────────────────────────────────────────────────────────
class _CircuitListRow extends StatelessWidget {
  final _CircuitPlayer player;
  final int rank;

  const _CircuitListRow({
    required this.player,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isParadise = context.isParadise;

    final bgColor = player.isMe
        ? (isParadise ? _pYellow.withOpacity(0.2) : cs.primaryContainer)
        : (isParadise ? _pWhite : cs.surface);

    final borderColor = player.isMe
        ? (isParadise ? _pYellow : cs.primary)
        : (isParadise
            ? _pOrange.withOpacity(0.3)
            : cs.outline.withOpacity(0.1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: player.isMe ? 2.0 : 1.0),
        boxShadow: isParadise && !player.isMe
            ? [
                BoxShadow(
                    color: _pOrange.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Row(children: [
        SizedBox(
          width: 36,
          child: Text(
            '#$rank',
            style: isParadise
                ? GoogleFonts.barlowCondensed(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: player.isMe ? _pBrown : _pBrown.withOpacity(0.5))
                : TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: player.isMe
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                  ),
          ),
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: isParadise
              ? _pTurquoise.withOpacity(0.15)
              : cs.secondaryContainer,
          child: Icon(player.persona.icon,
              size: 20,
              color: isParadise ? _pTurquoise : cs.onSecondaryContainer),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isParadise
                    ? GoogleFonts.oswald(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _pBrown,
                        letterSpacing: 0.5)
                    : TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                            player.isMe ? cs.onPrimaryContainer : cs.onSurface),
              ),
              const SizedBox(height: 2),
              Text(
                'Lvl ${player.jarLevel} · ${player.persona.title}',
                style: isParadise
                    ? GoogleFonts.nunito(
                        fontSize: 12,
                        color: _pBrown.withOpacity(0.6),
                        fontWeight: FontWeight.w600)
                    : TextStyle(
                        fontSize: 11,
                        color: player.isMe
                            ? cs.onPrimaryContainer.withOpacity(0.8)
                            : cs.onSurfaceVariant,
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${player.avgScore}',
          style: isParadise
              ? GoogleFonts.oswald(
                  fontSize: 22, fontWeight: FontWeight.w700, color: _pFuchsia)
              : TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: player.isMe ? cs.primary : cs.onSurface),
        ),
      ]),
    );
  }
}

// ── _RankingRow (For Top 10 simple list) ──────────────────────────────────────
class _RankingRow extends StatelessWidget {
  final _CircuitPlayer player;
  final int rank;

  const _RankingRow({required this.player, required this.rank});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isParadise = context.isParadise;

    final bgColor = player.isMe
        ? (isParadise ? _pYellow.withOpacity(0.2) : cs.primaryContainer)
        : (isParadise ? _pWhite : cs.surface);

    final borderColor = player.isMe
        ? (isParadise ? _pYellow : cs.primary)
        : (isParadise
            ? _pOrange.withOpacity(0.3)
            : cs.outline.withOpacity(0.1));

    Color rankColor;
    if (isParadise) {
      rankColor = rank == 1
          ? _pYellow
          : (rank == 2
              ? _pTurquoise
              : (rank == 3 ? _pOrange : _pBrown.withOpacity(0.5)));
    } else {
      rankColor = rank == 1
          ? cs.primary
          : (rank == 2
              ? cs.secondary
              : (rank == 3 ? cs.tertiary : cs.onSurfaceVariant));
    }

    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: borderColor, width: player.isMe ? 2.0 : 1.0),
          boxShadow: isParadise && !player.isMe
              ? [
                  BoxShadow(
                      color: _pOrange.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Row(children: [
          SizedBox(
            width: 40,
            child: Text('#$rank',
                style: isParadise
                    ? GoogleFonts.oswald(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: rankColor)
                    : TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: rankColor)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isParadise
                  ? GoogleFonts.oswald(
                      fontSize: 16, fontWeight: FontWeight.w600, color: _pBrown)
                  : TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color:
                          player.isMe ? cs.onPrimaryContainer : cs.onSurface),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${player.avgScore}',
            style: isParadise
                ? GoogleFonts.oswald(
                    fontSize: 22, fontWeight: FontWeight.w700, color: _pFuchsia)
                : TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: player.isMe ? cs.primary : cs.onSurface),
          ),
        ]));
  }
}

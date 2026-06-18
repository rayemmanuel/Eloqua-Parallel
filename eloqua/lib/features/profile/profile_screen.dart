import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/theme_manager.dart';
import '../../core/theme/theme_manager_ext.dart';
import '../../core/constants/strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/session_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/api_service.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';

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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _editing = false;
  late TextEditingController _nameCtrl;
  late AnimationController _ctrl;
  late List<Animation<double>> _anims;

  // ── State Variables for Real Ranking ──
  int? _myRank;
  int? _myJarLevel;
  bool _rankLoading = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: context.read<AuthService>().currentUserName,
    );
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _anims = List.generate(5, (i) {
      final s = i * 0.1;
      return CurvedAnimation(
          parent: _ctrl,
          curve: Interval(s, (s + 0.5).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic));
    });

    _fetchRank();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  // ── API Fetch Logic ──
  Future<void> _fetchRank() async {
    final token = context.read<AuthService>().token;
    if (token == null) {
      if (mounted) setState(() => _rankLoading = false);
      return;
    }

    final result = await ApiService.instance.getLeaderboard(token);

    if (!mounted) return;

    if (result.success && result.data != null) {
      final myIndex = result.data!.indexWhere((e) => e.isMe);

      setState(() {
        if (myIndex != -1) {
          _myRank = myIndex + 1; // +1 because index is 0-based
          _myJarLevel = result.data![myIndex].jarLevel;
        }
        _rankLoading = false;
      });
    } else {
      setState(() => _rankLoading = false);
    }
  }

  Widget _fade(Animation<double> a, Widget child) => AnimatedBuilder(
        animation: a,
        builder: (_, c) => Opacity(
          opacity: a.value.clamp(0.0, 1.0),
          child: Transform.translate(
              offset: Offset(0, 16 * (1 - a.value)), child: c),
        ),
        child: child,
      );

  Future<void> _save() async {
    final result = await context.read<AuthService>().updateName(_nameCtrl.text);
    if (!mounted) return;
    setState(() => _editing = false);
    HapticService.instance.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.success
            ? 'Profile updated.'
            : result.errorMessage ?? 'Update failed.'),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;

    final result =
        await context.read<AuthService>().uploadProfilePhoto(File(picked.path));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.success
            ? 'Photo updated.'
            : result.errorMessage ?? 'Upload failed.'),
      ),
    );
  }

  Future<void> _logout() async {
    final cs = context.cs;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: const Text(AppStrings.profileLogout),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<AuthService>().logout();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watch<ThemeManager>().isParadise;
    final auth = context.watch<AuthService>();
    final session = context.watch<SessionService>();

    final name = auth.currentUserName ?? 'Learner';
    final email = auth.currentUserEmail ?? '';
    final total = session.totalSessions;
    final streak = session.currentStreak;
    final best = session.bestScore;
    final avg = session.averageScore;

    final levelLabel = avg >= 80
        ? 'Expert Speaker'
        : avg >= 60
            ? 'Intermediate'
            : 'Beginner';

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
                    _fade(
                      _anims[0],
                      Row(children: [
                        Text(
                          'Profile',
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
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            if (_editing) {
                              _save();
                            } else {
                              setState(() => _editing = true);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _editing ? cs.primary : cs.surfaceVariant,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              _editing
                                  ? AppStrings.profileSave
                                  : AppStrings.profileEdit,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _editing
                                    ? cs.onPrimary
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    _fade(
                      _anims[1],
                      _HeroCard(
                        name: name,
                        email: email,
                        levelLabel: levelLabel,
                        editing: _editing,
                        nameCtrl: _nameCtrl,
                        photoBytes: auth.profilePhotoBytes,
                        onPickPhoto: _pickPhoto,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _fade(
                      _anims[2],
                      Row(children: [
                        Expanded(
                            child: _ProfileStat(
                          label: AppStrings.profileStreak,
                          value: '$streak',
                          icon: Icons.local_fire_department_rounded,
                          color: cs.surfaceVariant,
                          accent: cs.primary,
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _ProfileStat(
                          label: 'Accuracy',
                          value: '${avg.round()}%',
                          icon: Icons.check_circle_outline,
                          color: cs.surfaceVariant,
                          accent: cs.primary,
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _ProfileStat(
                          label: AppStrings.profileBest,
                          value: '$best',
                          icon: Icons.emoji_events_rounded,
                          color: cs.surfaceVariant,
                          accent: cs.primary,
                        )),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: cs.outlineVariant, thickness: 0.5),
                    const SizedBox(height: 24),
                    _fade(
                      _anims[3],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel('Personalization & History'),
                          const SizedBox(height: 16),
                          _MenuItem(
                            icon: Icons.history_rounded,
                            label: AppStrings.profileHistory,
                            subtitle: 'Review past session records',
                            iconColor: cs.onSurfaceVariant,
                            iconFill: cs.surfaceVariant,
                            onTap: () =>
                                Navigator.pushNamed(context, '/history'),
                          ),
                          const SizedBox(height: 8),
                          _MenuItem(
                            icon: Icons.settings_outlined,
                            label: AppStrings.profileSettings,
                            subtitle: 'Preferences, notifications & appearance',
                            iconColor: cs.onSurfaceVariant,
                            iconFill: cs.surfaceVariant,
                            onTap: () =>
                                Navigator.pushNamed(context, '/settings'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: cs.outlineVariant, thickness: 0.5),
                    const SizedBox(height: 24),
                    _fade(
                        _anims[3],
                        _RankingCard(
                          rank: _myRank,
                          jarLevel: _myJarLevel,
                          totalSessions: total,
                          isLoading: _rankLoading,
                        )),
                    const SizedBox(height: 24),
                    Divider(color: cs.outlineVariant, thickness: 0.5),
                    const SizedBox(height: 24),
                    _fade(
                      _anims[4],
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.errorContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: cs.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: cs.errorContainer,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                Icons.logout_rounded,
                                color: cs.error,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(AppStrings.profileLogout,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: cs.error,
                                )),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: cs.error,
                            ),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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
  const _TopBar({super.key});

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
        Text('PROFILE',
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
          child:
              Icon(Icons.person_outline_rounded, size: 18, color: cs.onPrimary),
        ),
      ]),
    );
  }
}

// ── SECTION LABEL (Aligned uniformly with home & analytics screens) ───────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watch<ThemeManager>().isParadise;

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

class _HeroCard extends StatelessWidget {
  final String name, email, levelLabel;
  final bool editing;
  final TextEditingController nameCtrl;
  final dynamic photoBytes;
  final VoidCallback onPickPhoto;

  const _HeroCard({
    required this.name,
    required this.email,
    required this.levelLabel,
    required this.editing,
    required this.nameCtrl,
    this.photoBytes,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isParadise = context.watch<ThemeManager>().isParadise;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onPickPhoto,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: cs.onPrimaryContainer.withOpacity(0.25),
                      width: 2,
                    ),
                    image: photoBytes != null
                        ? DecorationImage(
                            image: MemoryImage(photoBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: photoBytes == null
                      ? Center(
                          child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: isParadise
                              ? GoogleFonts.oswald(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onPrimaryContainer,
                                )
                              : TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onPrimaryContainer,
                                ),
                        ))
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.outlineVariant, width: 1),
                  ),
                  child: Icon(Icons.camera_alt_rounded,
                      size: 12, color: cs.onSurface),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                editing
                    ? TextField(
                        controller: nameCtrl,
                        style: isParadise
                            ? GoogleFonts.oswald(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: cs.onPrimaryContainer,
                              )
                            : TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: cs.onPrimaryContainer,
                              ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cs.surface.withOpacity(0.2),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Your name',
                          hintStyle: TextStyle(
                            color: cs.onPrimaryContainer.withOpacity(0.4),
                          ),
                        ),
                      )
                    : Text(name,
                        style: isParadise
                            ? GoogleFonts.oswald(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: cs.onPrimaryContainer,
                              )
                            : TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: cs.onPrimaryContainer,
                              )),
                const SizedBox(height: 4),
                Text(email,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onPrimaryContainer.withOpacity(0.65),
                    )),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: cs.surface.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.star_rounded,
                      color: cs.onPrimaryContainer,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(levelLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onPrimaryContainer,
                        )),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, accent;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isParadise = context.watch<ThemeManager>().isParadise;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: accent, size: 16),
        ),
        const SizedBox(height: 10),
        Text(value,
            style: isParadise
                ? GoogleFonts.oswald(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    height: 1.0,
                  )
                : TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    height: 1.0,
                  )),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(
              fontSize: 10,
              color: accent.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            )),
      ]),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color iconFill, iconColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconFill,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.outline.withOpacity(0.12),
          ),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconFill,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style:
                        tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    )),
              ])),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: cs.onSurfaceVariant,
          ),
        ]),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final int? rank;
  final int? jarLevel;
  final int totalSessions;
  final bool isLoading;

  const _RankingCard({
    required this.rank,
    required this.jarLevel,
    required this.totalSessions,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isParadise = context.watch<ThemeManager>().isParadise;
    final bgColor = cs.onSurface;

    final int calculatedXp = totalSessions * 50;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('GLOBAL RANKING',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.white54,
              )),
          const SizedBox(height: 4),
          Text(isLoading ? '...' : (rank != null ? '#$rank' : 'Unranked'),
              style: isParadise
                  ? GoogleFonts.oswald(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: cs.surface,
                      height: 1,
                    )
                  : TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: cs.surface,
                      height: 1,
                    )),
          Text(isLoading ? 'Loading...' : 'Jar Level ${jarLevel ?? 0}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white60,
              )),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text('POINTS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.white54,
              )),
          const SizedBox(height: 4),
          Text(isLoading ? '...' : '$calculatedXp XP',
              style: isParadise
                  ? GoogleFonts.oswald(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: cs.surface,
                    )
                  : TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: cs.surface,
                    )),
          const Text(
            'Keep practicing to rank up!',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white38,
            ),
          ),
        ]),
      ]),
    );
  }
}

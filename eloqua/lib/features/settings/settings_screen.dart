import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/strings.dart';
import '../../core/config/app_config.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/theme/theme_factory.dart';
import '../../core/theme/theme_manager_ext.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _haptics = AppConfig.enableHaptics;
  bool _gaze = true;
  bool _gestures = true;
  bool _posture = AppConfig.enableCamera;
  bool _tts = AppConfig.enableTts;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final mgr = context.watchThemeManager;
    final isParadise = mgr.currentSlot == ThemeSlot.paradise;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: isParadise ? cs.primary : cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () {
            HapticService.instance.light();
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: isParadise ? cs.onPrimary : cs.onSurface,
            size: 20,
          ),
        ),
        title: isParadise
            ? Text(
                'SETTINGS',
                style: GoogleFonts.oswald(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: cs.onPrimary,
                  letterSpacing: 3.5,
                ),
              )
            : Text('Settings', style: tt.titleLarge),
        // Paradise: floral row in AppBar trailing
        actions: isParadise
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.spa_rounded,
                          color: cs.onPrimary.withOpacity(0.7), size: 16),
                      const SizedBox(width: 4),
                      Icon(Icons.local_florist_rounded,
                          color: cs.onPrimary, size: 20),
                      const SizedBox(width: 4),
                      Icon(Icons.spa_rounded,
                          color: cs.onPrimary.withOpacity(0.7), size: 16),
                    ],
                  ),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Paradise: decorative script banner at top (None in Default) ──
            if (isParadise) ...[
              const _ParadiseBanner(),
              const SizedBox(height: 20),
            ],

            isParadise
                ? const _ParadiseSectionLabel('Account Preferences')
                : const _SectionLabel('Account Preferences'),
            const SizedBox(height: 6),
            isParadise
                ? const _ParadiseSubtitle(
                    'Tailor your experience to fit your lifestyle.')
                : Text(
                    'Tailor your learning experience to fit your lifestyle.',
                    style: tt.bodySmall?.copyWith(height: 1.5),
                  ),
            const SizedBox(height: 28),

            // ── NOTIFICATIONS ──────────────────────────────────────────────
            isParadise
                ? const _ParadiseSectionLabel('Notifications')
                : const _SectionLabel('Notifications'),
            const SizedBox(height: 12),
            _ToggleTile(
              title: 'Push Notifications',
              subtitle: 'Daily reminders on scheduled activity',
              value: true,
              onChanged: (_) {},
              isParadise: isParadise,
            ),
            const SizedBox(height: 8),
            _ToggleTile(
              title: 'Email Reports',
              subtitle: 'Weekly summaries of your progress',
              value: false,
              onChanged: (_) {},
              isParadise: isParadise,
            ),

            const SizedBox(height: 28),

            // ── APP THEME ─────────────────────────────────────────────────
            isParadise
                ? const _ParadiseSectionLabel('App Theme')
                : const _SectionLabel('App Theme'),
            const SizedBox(height: 6),
            isParadise
                ? const _ParadiseSubtitle(
                    'Changes apply instantly across all screens.')
                : Text('Changes apply instantly across all screens.',
                    style: tt.bodySmall),
            const SizedBox(height: 14),
            _ThemeGrid(manager: mgr),

            const SizedBox(height: 24),
            isParadise
                ? const _FloralDivider()
                : Divider(color: cs.outlineVariant),
            const SizedBox(height: 24),

            // ── SOUND ─────────────────────────────────────────────────────
            isParadise
                ? const _ParadiseSectionLabel('Sound')
                : const _SectionLabel('Sound'),
            const SizedBox(height: 12),
            _SliderTile(title: 'Lesson Effects Volume', isParadise: isParadise),
            const SizedBox(height: 8),
            _ToggleTile(
              title: 'Pronunciation Feedback',
              subtitle: 'Audio cues during speaking sessions',
              value: _tts,
              onChanged: (v) => setState(() => _tts = v),
              isParadise: isParadise,
            ),

            const SizedBox(height: 24),
            isParadise
                ? const _FloralDivider()
                : Divider(color: cs.outlineVariant),
            const SizedBox(height: 24),

            // ── FEATURES (Merged Logic) ───────────────────────────────────
            isParadise
                ? const _ParadiseSectionLabel('Features')
                : const _SectionLabel('Features'),
            const SizedBox(height: 12),
            _ToggleTile(
              title: AppStrings.settingsHaptics ?? 'Haptic Feedback',
              subtitle: 'Vibrate on filler words or posture alerts',
              value: _haptics,
              onChanged: (v) {
                setState(() => _haptics = v);
                HapticService.instance.selection();
              },
              isParadise: isParadise,
            ),
            const SizedBox(height: 8),
            _ToggleTile(
              title: AppStrings.settingsGaze ?? 'Eye Gaze Scroll',
              subtitle: 'Auto-scroll notes when your eyes look down',
              value: _gaze,
              onChanged: (v) => setState(() => _gaze = v),
              isParadise: isParadise,
            ),
            const SizedBox(height: 8),
            _ToggleTile(
              title: AppStrings.settingsGestures ?? 'Hands-free Gestures',
              subtitle: 'Swipe and double-tap for hands-free control',
              value: _gestures,
              onChanged: (v) => setState(() => _gestures = v),
              isParadise: isParadise,
            ),
            const SizedBox(height: 8),
            _ToggleTile(
              title: AppStrings.settingsPosture ?? 'Posture Coaching',
              subtitle: 'Live camera shoulder alignment coaching',
              value: _posture,
              onChanged: (v) => setState(() => _posture = v),
              isParadise: isParadise,
            ),

            const SizedBox(height: 24),
            isParadise
                ? const _FloralDivider()
                : Divider(color: cs.outlineVariant),
            const SizedBox(height: 24),

            // ── GESTURE GUIDE (Restored Logic) ────────────────────────────
            isParadise
                ? const _ParadiseSectionLabel('Gesture Guide')
                : const _SectionLabel('Gesture Guide'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isParadise
                    ? cs.secondaryContainer
                    : cs.surfaceContainer.withOpacity(0.6),
                borderRadius: BorderRadius.circular(isParadise ? 18 : 14),
                border: Border.all(
                    color: isParadise ? cs.tertiary : cs.outlineVariant,
                    width: isParadise ? 2.0 : 1.0),
              ),
              child: Column(children: [
                _GRow(
                    icon: Icons.swipe_left,
                    label: 'Swipe Left',
                    desc: 'Open Settings',
                    isParadise: isParadise),
                _GRow(
                    icon: Icons.swipe_right,
                    label: 'Swipe Right',
                    desc: 'Go Back',
                    isParadise: isParadise),
                _GRow(
                    icon: Icons.swipe_up,
                    label: 'Swipe Up',
                    desc: 'Start Spontaneous Mode',
                    isParadise: isParadise),
                _GRow(
                    icon: Icons.touch_app,
                    label: 'Double Tap',
                    desc: 'Toggle Theme',
                    isParadise: isParadise),
                _GRow(
                    icon: Icons.pan_tool,
                    label: 'Long Press',
                    desc: 'Read Gesture Summary Aloud',
                    isParadise: isParadise),
              ]),
            ),

            const SizedBox(height: 24),
            isParadise
                ? const _FloralDivider()
                : Divider(color: cs.outlineVariant),
            const SizedBox(height: 24),

            // ── PRIVACY ───────────────────────────────────────────────────
            isParadise
                ? const _ParadiseSectionLabel('Privacy')
                : const _SectionLabel('Privacy'),
            const SizedBox(height: 12),
            _ToggleTile(
              title: 'Public Profile',
              subtitle: 'Show your learning progress publicly',
              value: false,
              onChanged: (_) {},
              isParadise: isParadise,
            ),
            const SizedBox(height: 8),
            _DangerTile(
              title: 'Delete Account Data',
              subtitle: 'This action cannot be undone',
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // ── ABOUT (Restored Logic) ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainer.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant, width: 1.5),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConfig.appName,
                        style: tt.headlineMedium?.copyWith(
                            color: cs.onSurface, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                        '${AppStrings.settingsVersion ?? 'Version'} ${AppConfig.version}',
                        style:
                            tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(AppConfig.teamName,
                        style:
                            tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ]),
            ),

            const SizedBox(height: 32),

            // ── PRO UPSELL ────────────────────────────────────────────────
            isParadise ? const _ParadiseProBanner() : const _ProBanner(),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARADISE BANNER — cursive script + tropical strip
// ─────────────────────────────────────────────────────────────────────────────

class _ParadiseBanner extends StatelessWidget {
  const _ParadiseBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.tertiary, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: cs.secondaryContainer.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_florist_rounded,
                      color: cs.primary, size: 14),
                  const SizedBox(width: 6),
                  Icon(Icons.spa_rounded,
                      color: cs.onSecondaryContainer.withOpacity(0.6),
                      size: 12),
                  const SizedBox(width: 6),
                  Icon(Icons.eco_rounded, color: cs.primary, size: 12),
                  const SizedBox(width: 6),
                  Icon(Icons.spa_rounded,
                      color: cs.onSecondaryContainer.withOpacity(0.6),
                      size: 12),
                  const SizedBox(width: 6),
                  Icon(Icons.local_florist_rounded,
                      color: cs.primary, size: 14),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Paradise Settings',
                style: GoogleFonts.sacramento(
                  fontSize: 36,
                  color: cs.onSecondaryContainer,
                  letterSpacing: 1.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'SYSTEM CONFIGURATION',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSecondaryContainer.withOpacity(0.85),
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -8,
          left: -4,
          child: Icon(Icons.local_florist_rounded, color: cs.primary, size: 22),
        ),
        Positioned(
          top: -8,
          right: -4,
          child: Icon(Icons.local_florist_rounded, color: cs.primary, size: 22),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLORAL DIVIDER
// ─────────────────────────────────────────────────────────────────────────────

class _FloralDivider extends StatelessWidget {
  const _FloralDivider();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
            child: Container(height: 1.5, color: cs.primary.withOpacity(0.28))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.spa_rounded, color: cs.primary, size: 12),
              const SizedBox(width: 4),
              Icon(Icons.local_florist_rounded, color: cs.tertiary, size: 14),
              const SizedBox(width: 4),
              Icon(Icons.spa_rounded, color: cs.primary, size: 12),
            ],
          ),
        ),
        Expanded(
            child: Container(height: 1.5, color: cs.primary.withOpacity(0.28))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARADISE SUBTITLE helper
// ─────────────────────────────────────────────────────────────────────────────

class _ParadiseSubtitle extends StatelessWidget {
  final String text;
  const _ParadiseSubtitle(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: cs.onSurfaceVariant,
        height: 1.5,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME GRID
// ─────────────────────────────────────────────────────────────────────────────

IconData _iconForSlot(ThemeSlot slot) => switch (slot) {
      ThemeSlot.organic => Icons.eco_rounded,
      ThemeSlot.spicy => Icons.local_fire_department_rounded,
      ThemeSlot.candy => Icons.icecream_rounded,
      ThemeSlot.paradise => Icons.local_florist_rounded,
      ThemeSlot.glacialis => Icons.ac_unit_rounded,
      ThemeSlot.grunge => Icons.contrast_rounded,
    };

class _ThemeGrid extends StatelessWidget {
  final ThemeManager manager;
  const _ThemeGrid({required this.manager});

  @override
  Widget build(BuildContext context) {
    final tt = context.tt;
    final isParadise = manager.currentSlot == ThemeSlot.paradise;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ThemeSlot.values.map((slot) {
        final isActive = manager.currentSlot == slot;
        final swatch = slot.swatch;
        final bgColor = slot.swatchBg;
        final isThisParadise = slot == ThemeSlot.paradise;

        return GestureDetector(
          onTap: () {
            HapticService.instance.selection();
            manager.setSlot(slot);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 92,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(isThisParadise ? 20 : 16),
              border: Border.all(
                color: isActive ? swatch : swatch.withOpacity(0.2),
                width: isActive ? 2.5 : 0.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: swatch.withOpacity(isThisParadise ? 0.4 : 0.22),
                        blurRadius: isThisParadise ? 20 : 14,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isThisParadise)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_florist_rounded,
                          color: swatch.withOpacity(0.8), size: 10),
                      const SizedBox(width: 2),
                      Icon(_iconForSlot(slot), color: swatch, size: 18),
                      const SizedBox(width: 2),
                      Icon(Icons.spa_rounded,
                          color: swatch.withOpacity(0.8), size: 10),
                    ],
                  )
                else
                  Icon(_iconForSlot(slot), color: swatch, size: 20),
                const SizedBox(height: 6),
                if (isThisParadise)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ColorDot(swatch.withOpacity(0.5), 10),
                      const SizedBox(width: 2),
                      _ColorDot(swatch, 10),
                      const SizedBox(width: 2),
                      _ColorDot(swatch.withOpacity(0.8), 10),
                    ],
                  )
                else
                  Container(
                    width: 18,
                    height: 18,
                    decoration:
                        BoxDecoration(color: swatch, shape: BoxShape.circle),
                  ),
                const SizedBox(height: 7),
                Text(
                  slot.label,
                  style: isParadise
                      ? GoogleFonts.barlowCondensed(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: swatch,
                          letterSpacing: 1.0,
                          height: 1.2,
                        )
                      : tt.labelSmall?.copyWith(
                          color: swatch, letterSpacing: 0.4, height: 1.2),
                  textAlign: TextAlign.center,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isActive
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(Icons.check_circle_rounded,
                              size: 12, color: swatch),
                        )
                      : const SizedBox(height: 16),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final double size;
  const _ColorDot(this.color, this.size);

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABELS
// ─────────────────────────────────────────────────────────────────────────────

// Classmate's precise DEFAULT section label
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(
        label.toUpperCase(),
        style: context.tt.labelSmall,
      );
}

class _ParadiseSectionLabel extends StatelessWidget {
  final String label;
  const _ParadiseSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: cs.onSurface,
            letterSpacing: 0.3,
            height: 1.2,
          ),
        ),
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
                        : cs.tertiary.withOpacity(0.25),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.spa_rounded, color: cs.primary, size: 12),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GESTURE ROW
// ─────────────────────────────────────────────────────────────────────────────

class _GRow extends StatelessWidget {
  final IconData icon;
  final String label, desc;
  final bool isParadise;

  const _GRow(
      {required this.icon,
      required this.label,
      required this.desc,
      this.isParadise = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 20, color: isParadise ? cs.primary : cs.primary),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Text(label,
              style: isParadise
                  ? GoogleFonts.oswald(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSecondaryContainer,
                      letterSpacing: 0.5)
                  : tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700, color: cs.onSurface)),
        ),
        Expanded(
          child: Text(desc,
              style: isParadise
                  ? GoogleFonts.nunito(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: cs.onSecondaryContainer.withOpacity(0.8))
                  : tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant, fontStyle: FontStyle.italic)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOGGLE TILE
// ─────────────────────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isParadise;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isParadise = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isParadise
            ? cs.primaryContainer
            : cs.surfaceContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(isParadise ? 18 : 14),
        border: Border.all(
          color: isParadise ? cs.primary : cs.outlineVariant,
          width: isParadise ? 2.0 : 1.0,
        ),
      ),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              title,
              style: isParadise
                  ? GoogleFonts.oswald(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onPrimaryContainer,
                      letterSpacing: 1.5,
                    )
                  : tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: isParadise
                  ? GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: cs.onPrimaryContainer.withOpacity(0.85),
                    )
                  : tt.bodySmall,
            ),
          ]),
        ),
        const SizedBox(width: 12),
        Switch.adaptive(
          value: value,
          onChanged: (v) {
            HapticService.instance.selection();
            onChanged(v);
          },
          activeColor: cs.primary,
          activeTrackColor:
              isParadise ? cs.primaryContainer.withOpacity(0.6) : null,
          inactiveThumbColor: isParadise ? cs.surfaceVariant : null,
          inactiveTrackColor: isParadise ? cs.tertiary.withOpacity(0.35) : null,
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SLIDER TILE
// ─────────────────────────────────────────────────────────────────────────────

class _SliderTile extends StatefulWidget {
  final String title;
  final bool isParadise;
  const _SliderTile({required this.title, this.isParadise = false});

  @override
  State<_SliderTile> createState() => _SliderTileState();
}

class _SliderTileState extends State<_SliderTile> {
  double _value = 0.8;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final ip = widget.isParadise;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: ip ? cs.primaryContainer : cs.surfaceContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(ip ? 18 : 14),
        border: Border.all(
          color: ip ? cs.primary : cs.outlineVariant,
          width: ip ? 2.0 : 1.0,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(
              widget.title,
              style: ip
                  ? GoogleFonts.oswald(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onPrimaryContainer,
                      letterSpacing: 1.5,
                    )
                  : tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${(_value * 100).round()}%',
            style: ip
                ? GoogleFonts.sacramento(
                    fontSize: 26,
                    color: cs.primary,
                    letterSpacing: 1.0,
                  )
                : tt.bodySmall,
          ),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: ip ? 7 : 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            activeTrackColor: cs.primary,
            inactiveTrackColor:
                ip ? cs.tertiary.withOpacity(0.32) : cs.surfaceContainerHigh,
            thumbColor: cs.primary,
            overlayColor: cs.primary.withOpacity(0.15),
          ),
          child: Slider(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DANGER TILE
// ─────────────────────────────────────────────────────────────────────────────

class _DangerTile extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback onTap;
  const _DangerTile(
      {required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.error.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.error.withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(Icons.delete_outline_rounded, color: cs.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600, color: cs.error)),
                Text(subtitle,
                    style: tt.bodySmall
                        ?.copyWith(color: cs.error.withOpacity(0.7))),
              ])),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEFAULT PRO BANNER
// ─────────────────────────────────────────────────────────────────────────────

class _ProBanner extends StatelessWidget {
  const _ProBanner();

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Go Unlimited with\nEloqua Pro',
              style:
                  tt.headlineSmall?.copyWith(color: cs.onPrimary, height: 1.2)),
          const Spacer(),
          Icon(Icons.add_circle_outline,
              color: cs.onPrimary.withOpacity(0.7), size: 28),
        ]),
        const SizedBox(height: 8),
        Text('Unlock advanced analytics and all achievements.',
            style: tt.bodySmall
                ?.copyWith(color: cs.onPrimary.withOpacity(0.75), height: 1.4)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: cs.onPrimary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text('Start Free Trial',
              style: tt.labelLarge?.copyWith(color: cs.primary)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARADISE PRO BANNER
// ─────────────────────────────────────────────────────────────────────────────

class _ParadiseProBanner extends StatelessWidget {
  const _ParadiseProBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.tertiary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.primary, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: cs.tertiary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.local_florist_rounded,
                      color: cs.onTertiary, size: 16),
                  const SizedBox(width: 5),
                  Icon(Icons.spa_rounded, color: cs.primaryContainer, size: 13),
                  const SizedBox(width: 5),
                  Icon(Icons.eco_rounded, color: cs.onTertiary, size: 13),
                  const SizedBox(width: 5),
                  Icon(Icons.local_florist_rounded,
                      color: cs.primaryContainer, size: 14),
                ]),
                const SizedBox(height: 8),
                Text(
                  'Go Unlimited',
                  style: GoogleFonts.sacramento(
                    fontSize: 42,
                    color: cs.onTertiary,
                    letterSpacing: 1.0,
                    height: 1.0,
                  ),
                ),
                Text(
                  'with Eloqua Pro',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: cs.primaryContainer,
                    letterSpacing: 0.2,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(children: [
            Icon(Icons.local_florist_rounded, color: cs.primary, size: 30),
            const SizedBox(height: 4),
            Icon(Icons.star_rounded, color: cs.onTertiary, size: 22),
            const SizedBox(height: 4),
            Icon(Icons.spa_rounded, color: cs.primaryContainer, size: 16),
          ]),
        ]),
        const SizedBox(height: 12),
        Text(
          'Unlock advanced analytics, all achievements\nand unlimited coaching sessions.',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: cs.primaryContainer.withOpacity(0.9),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                color: cs.onPrimaryContainer.withOpacity(0.15), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: cs.onPrimaryContainer.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: cs.onPrimaryContainer, size: 16),
              const SizedBox(width: 8),
              Text(
                'START FREE TRIAL',
                style: GoogleFonts.oswald(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: cs.onPrimaryContainer,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded,
                  color: cs.onPrimaryContainer, size: 16),
            ],
          ),
        ),
      ]),
    );
  }
}

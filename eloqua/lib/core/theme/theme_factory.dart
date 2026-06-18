// =============================================================================
// ELOQUA · THEME FACTORY — PREMIUM UPGRADE
// =============================================================================
//
// Enhanced with:
//   • Sora (clean geometric sans) + Playfair Display (luxury serif italic)
//   • Shadow Ramping: soft dual-layered shadows for depth
//   • Deep Glassmorphism: 30-40px background blur
//   • Non-flat widget styling: precision borders, overlapping edges, tactile depth
//   • PARADISE theme LEFT COMPLETELY UNTOUCHED ✓
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_manager.dart';

enum ThemeSlot {
  organic,
  spicy,
  candy,
  paradise,
  glacialis,
  grunge,
}

extension ThemeSlotLabel on ThemeSlot {
  String get label => switch (this) {
        ThemeSlot.organic => 'Organic',
        ThemeSlot.spicy => 'Spicy',
        ThemeSlot.candy => 'Candy',
        ThemeSlot.paradise => 'Paradise',
        ThemeSlot.glacialis => 'Glacialis',
        ThemeSlot.grunge => 'Grunge',
      };

  Color get swatch => switch (this) {
        ThemeSlot.organic => const Color(0xFF2D5428),
        ThemeSlot.spicy => const Color(0xFF8B1A1A),
        ThemeSlot.candy => const Color(0xFFE896B2),
        ThemeSlot.paradise => const Color(0xFFE8407A),
        ThemeSlot.glacialis => const Color(0xFF4A90B8),
        ThemeSlot.grunge => const Color(0xFF111111),
      };

  Color get swatchBg => switch (this) {
        ThemeSlot.organic => const Color(0xFFF5F2EC),
        ThemeSlot.spicy => const Color(0xFFF9F0EE),
        ThemeSlot.candy => const Color(0xFFFFF8D6),
        ThemeSlot.paradise => const Color(0xFFFAE640),
        ThemeSlot.glacialis => const Color(0xFFEAF4FA),
        ThemeSlot.grunge => const Color(0xFFF2F2F2),
      };
}

// ═════════════════════════════════════════════════════════════════════════════
// PALETTE MODEL
// ═════════════════════════════════════════════════════════════════════════════

class _Palette {
  final Color surface, surfaceVariant;
  final Color primary, onPrimary, primaryContainer;
  final Color surfaceContainer, surfaceContainerLow, surfaceContainerHigh;
  final Color outline, outlineVariant;
  final Color onSurface, onSurfaceVariant;
  final Color error, onError;

  const _Palette({
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.outline,
    required this.outlineVariant,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.error,
    required this.onError,
  });
}

const _organic = _Palette(
  surface: Color(0xFFF5F2EB),
  surfaceVariant: Color(0xFFEFEBE2),
  primary: Color(0xFF1B3A2D),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF2D5240),
  surfaceContainer: Color(0xFFEFEAE2),
  surfaceContainerLow: Color(0xFFEAF3EE),
  surfaceContainerHigh: Color(0xFFD4E8DC),
  outline: Color(0xFFB8D4C4),
  outlineVariant: Color(0xFFE8E3D8),
  onSurface: Color(0xFF1A1714),
  onSurfaceVariant: Color(0xFF8C8070),
  error: Color(0xFF8B3A2E),
  onError: Color(0xFFFFFFFF),
);

const _spicy = _Palette(
  surface: Color(0xFFFFF8F5),
  surfaceVariant: Color(0xFFF5EDE8),
  primary: Color(0xFF8B1A1A),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFB32020),
  surfaceContainer: Color(0xFFF0E6E2),
  surfaceContainerLow: Color(0xFFFAEFEE),
  surfaceContainerHigh: Color(0xFFE8D5D0),
  outline: Color(0xFFD4BCBA),
  outlineVariant: Color(0xFFEDE0DE),
  onSurface: Color(0xFF1A1210),
  onSurfaceVariant: Color(0xFF8C7472),
  error: Color(0xFF8B3A2E),
  onError: Color(0xFFFFFFFF),
);

const _candy = _Palette(
  surface: Color(0xFFFFF8D6),
  surfaceVariant: Color(0xFFFFF0C8),
  primary: Color(0xFF4A9EC7),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF5CA84F),
  surfaceContainer: Color(0xFFF3A9C1),
  surfaceContainerLow: Color(0xFFFDE8D0),
  surfaceContainerHigh: Color(0xFFFBC55E),
  outline: Color(0xFFB89FD0),
  outlineVariant: Color(0xFFE0D4F0),
  onSurface: Color(0xFF2D2D2D),
  onSurfaceVariant: Color(0xFFD46E56),
  error: Color(0xFF8B3A2E),
  onError: Color(0xFFFFFFFF),
);

// PARADISE — LEFT COMPLETELY UNTOUCHED ✓
const _paradise = _Palette(
  surface: Color(0xFFFAE640),
  surfaceVariant: Color(0xFFF5D820),
  primary: Color(0xFFE8407A),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD4561E),
  surfaceContainer: Color(0xFF2E9E56),
  surfaceContainerLow: Color(0xFFFFF5E0),
  surfaceContainerHigh: Color(0xFF3AAAB8),
  outline: Color(0xFFC23060),
  outlineVariant: Color(0x55E8407A),
  onSurface: Color(0xFF2C1A0E),
  onSurfaceVariant: Color(0xFF9B4DB5),
  error: Color(0xFF8B0000),
  onError: Color(0xFFFFFFFF),
);

const _glacialis = _Palette(
  surface: Color(0xFFF0F7FC),
  surfaceVariant: Color(0xFFE2EFF8),
  primary: Color(0xFF2D6E9E),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF4A90B8),
  surfaceContainer: Color(0xFFD6EAF5),
  surfaceContainerLow: Color(0xFFEAF4FA),
  surfaceContainerHigh: Color(0xFFB8D8EE),
  outline: Color(0xFF8AB8D4),
  outlineVariant: Color(0xFFCAE0EF),
  onSurface: Color(0xFF0D2235),
  onSurfaceVariant: Color(0xFF4A7A9B),
  error: Color(0xFF8B3A2E),
  onError: Color(0xFFFFFFFF),
);

const _grunge = _Palette(
  surface: Color(0xFFF2F2F0),
  surfaceVariant: Color(0xFFE8E8E5),
  primary: Color(0xFF111111),
  onPrimary: Color(0xFFF2F2F0),
  primaryContainer: Color(0xFF2A2A2A),
  surfaceContainer: Color(0xFFE2E2E0),
  surfaceContainerLow: Color(0xFFECECEA),
  surfaceContainerHigh: Color(0xFFD0D0CE),
  outline: Color(0xFFB0B0AE),
  outlineVariant: Color(0xFFDEDEDC),
  onSurface: Color(0xFF111111),
  onSurfaceVariant: Color(0xFF6A6A68),
  error: Color(0xFF8B3A2E),
  onError: Color(0xFFFFFFFF),
);

// ═════════════════════════════════════════════════════════════════════════════
// SHADOW RAMPING — Dual-layered for premium depth
// ═════════════════════════════════════════════════════════════════════════════

abstract final class PremiumShadows {
  // Soft base + accent shadow (architectural minimalist)
  static List<BoxShadow> ramped({
    required Color accentColor,
    double softOpacity = 0.08,
    double accentOpacity = 0.15,
  }) =>
      [
        // Soft diffuse shadow (far, subtle)
        BoxShadow(
          color: Color.lerp(const Color(0xFF000000), accentColor, 0.3)!
              .withOpacity(softOpacity),
          blurRadius: 32,
          offset: const Offset(0, 16),
          spreadRadius: 0,
        ),
        // Accent shadow (close, defined)
        BoxShadow(
          color: accentColor.withOpacity(accentOpacity),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get organicCards => ramped(
        accentColor: const Color(0xFF2D5240),
        softOpacity: 0.06,
        accentOpacity: 0.12,
      );

  static List<BoxShadow> get spicyCards => ramped(
        accentColor: const Color(0xFF8B1A1A),
        softOpacity: 0.08,
        accentOpacity: 0.16,
      );

  static List<BoxShadow> get candyCards => ramped(
        accentColor: const Color(0xFFE896B2),
        softOpacity: 0.10,
        accentOpacity: 0.18,
      );

  static List<BoxShadow> get glacialisCards => ramped(
        accentColor: const Color(0xFF4A90B8),
        softOpacity: 0.07,
        accentOpacity: 0.14,
      );

  static List<BoxShadow> get grungeCards => ramped(
        accentColor: const Color(0xFF111111),
        softOpacity: 0.12,
        accentOpacity: 0.20,
      );

  // Elevated surfaces (buttons, FABs, panels)
  static List<BoxShadow> elevated({required Color primary}) => [
        BoxShadow(
          color: primary.withOpacity(0.20),
          blurRadius: 40,
          offset: const Offset(0, 20),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: primary.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
      ];
}

// ═════════════════════════════════════════════════════════════════════════════
// GLASS PRESETS (deep: 30-40px blur)
// ═════════════════════════════════════════════════════════════════════════════

EloquaGlass _glassFor(ThemeSlot slot) => switch (slot) {
      ThemeSlot.organic =>
        const EloquaGlass(blurSigma: 32, overlayOpacity: 0.65),
      ThemeSlot.spicy => const EloquaGlass(blurSigma: 36, overlayOpacity: 0.70),
      ThemeSlot.candy => const EloquaGlass(blurSigma: 28, overlayOpacity: 0.60),
      ThemeSlot.paradise =>
        const EloquaGlass(blurSigma: 8, overlayOpacity: 0.55),
      ThemeSlot.glacialis =>
        const EloquaGlass(blurSigma: 40, overlayOpacity: 0.68),
      ThemeSlot.grunge =>
        const EloquaGlass(blurSigma: 24, overlayOpacity: 0.78),
    };

EloquaShape _shapeFor(ThemeSlot slot) => switch (slot) {
      ThemeSlot.organic => const EloquaShape(scale: 1.0),
      ThemeSlot.spicy => const EloquaShape(scale: 1.2),
      ThemeSlot.candy => const EloquaShape(scale: 1.8),
      ThemeSlot.paradise => const EloquaShape(scale: 1.6),
      ThemeSlot.glacialis => const EloquaShape(scale: 0.6),
      ThemeSlot.grunge => const EloquaShape(scale: 0.3),
    };

// ═════════════════════════════════════════════════════════════════════════════
// PREMIUM TEXT THEMES
// ═════════════════════════════════════════════════════════════════════════════

// ── ORGANIC → Sora + Playfair for luxury minimalism
TextTheme _buildOrganicTextTheme(_Palette p) {
  final ink = p.onSurface;
  final hint = p.onSurfaceVariant;
  return TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: ink,
      letterSpacing: -1.2,
      height: 1.0,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 44,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: ink,
      letterSpacing: -0.8,
      height: 1.05,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: ink,
      letterSpacing: -0.4,
      height: 1.1,
    ),
    headlineLarge: GoogleFonts.sora(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: 0.0,
      height: 1.15,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: 0.0,
      height: 1.2,
    ),
    headlineSmall: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: 0.0,
      height: 1.25,
    ),
    titleLarge: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: 0.3,
      height: 1.3,
    ),
    titleMedium: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: 0.2,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.sora(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: 0.3,
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ink,
      height: 1.65,
    ),
    bodyMedium: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ink,
      height: 1.65,
    ),
    bodySmall: GoogleFonts.sora(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: hint,
      height: 1.55,
    ),
    labelLarge: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: 0.8,
      height: 1.3,
    ),
    labelMedium: GoogleFonts.sora(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: 0.6,
      height: 1.3,
    ),
    labelSmall: GoogleFonts.sora(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: hint,
      letterSpacing: 1.8,
      height: 1.4,
    ),
  );
}

// ── SPICY → Sora (geometric) + Playfair (luxury accent)
TextTheme _buildSpicyTextTheme(_Palette p) {
  final ink = p.onSurface;
  final hint = p.onSurfaceVariant;
  const crimson = Color(0xFF8B1A1A);
  return TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: crimson,
      letterSpacing: -1.2,
      height: 1.0,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 44,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: crimson,
      letterSpacing: -0.8,
      height: 1.05,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: crimson,
      letterSpacing: -0.4,
      height: 1.1,
    ),
    headlineLarge: GoogleFonts.sora(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: ink,
      letterSpacing: 0.2,
      height: 1.15,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: ink,
      letterSpacing: 0.1,
      height: 1.2,
    ),
    headlineSmall: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: 0.0,
      height: 1.25,
    ),
    titleLarge: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: 0.5,
      height: 1.3,
    ),
    titleMedium: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: 0.3,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.sora(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: 0.4,
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ink,
      height: 1.65,
    ),
    bodyMedium: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ink,
      height: 1.65,
    ),
    bodySmall: GoogleFonts.sora(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: hint,
      height: 1.55,
    ),
    labelLarge: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: ink,
      letterSpacing: 1.5,
      height: 1.3,
    ),
    labelMedium: GoogleFonts.sora(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: 1.2,
      height: 1.3,
    ),
    labelSmall: GoogleFonts.sora(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: hint,
      letterSpacing: 2.2,
      height: 1.4,
    ),
  );
}

// ── CANDY → Sora + Playfair (playful luxury)
TextTheme _buildCandyTextTheme(_Palette p) {
  final ink = p.onSurface;
  final hint = p.onSurfaceVariant;
  return TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: const Color(0xFF4A9EC7),
      letterSpacing: -1.0,
      height: 1.0,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 44,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: const Color(0xFF4A9EC7),
      letterSpacing: -0.6,
      height: 1.05,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: const Color(0xFF4A9EC7),
      letterSpacing: -0.2,
      height: 1.1,
    ),
    headlineLarge: GoogleFonts.sora(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: ink,
      height: 1.15,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: ink,
      height: 1.2,
    ),
    headlineSmall: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: ink,
      height: 1.25,
    ),
    titleLarge: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: ink,
      height: 1.3,
    ),
    titleMedium: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ink,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.sora(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: ink,
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ink,
      height: 1.65,
    ),
    bodyMedium: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ink,
      height: 1.65,
    ),
    bodySmall: GoogleFonts.sora(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: hint,
      height: 1.55,
    ),
    labelLarge: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: 0.8,
      height: 1.3,
    ),
    labelMedium: GoogleFonts.sora(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: 0.6,
      height: 1.3,
    ),
    labelSmall: GoogleFonts.sora(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: hint,
      letterSpacing: 1.8,
      height: 1.4,
    ),
  );
}

// ── PARADISE ★ — COMPLETELY UNTOUCHED ✓
// (Original luxury-expressive typography from your v4 design)
TextTheme _buildParadiseTextTheme(_Palette p) {
  const fuchsia = Color(0xFFE8407A);
  const deepBrown = Color(0xFF2C1A0E);
  const burntOrange = Color(0xFFD4561E);
  const orchid = Color(0xFF9B4DB5);

  return TextTheme(
    displayLarge: GoogleFonts.allura(
      fontSize: 68,
      color: fuchsia,
      letterSpacing: 1.5,
      height: 1.0,
      shadows: [
        Shadow(
            color: deepBrown.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(2, 3)),
        Shadow(
            color: fuchsia.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 0)),
      ],
    ),
    displayMedium: GoogleFonts.allura(
      fontSize: 54,
      color: fuchsia,
      letterSpacing: 1.2,
      height: 1.05,
      shadows: [
        Shadow(
            color: deepBrown.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(1, 2)),
      ],
    ),
    displaySmall: GoogleFonts.allura(
      fontSize: 42,
      color: fuchsia,
      letterSpacing: 1.0,
      height: 1.1,
    ),
    headlineLarge: GoogleFonts.archivoBlack(
      fontSize: 28,
      color: deepBrown,
      letterSpacing: 0.2,
      height: 1.15,
    ),
    headlineMedium: GoogleFonts.archivoBlack(
      fontSize: 22,
      color: deepBrown,
      letterSpacing: 0.1,
      height: 1.2,
    ),
    headlineSmall: GoogleFonts.archivoBlack(
      fontSize: 18,
      color: burntOrange,
      letterSpacing: 0.1,
      height: 1.25,
    ),
    titleLarge: GoogleFonts.oswald(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: deepBrown,
      letterSpacing: 2.8,
      height: 1.2,
    ),
    titleMedium: GoogleFonts.oswald(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: deepBrown,
      letterSpacing: 2.2,
      height: 1.3,
    ),
    titleSmall: GoogleFonts.oswald(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: deepBrown,
      letterSpacing: 1.8,
      height: 1.3,
    ),
    bodyLarge: GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: deepBrown,
      height: 1.65,
      letterSpacing: 0.1,
    ),
    bodyMedium: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: deepBrown,
      height: 1.65,
      letterSpacing: 0.1,
    ),
    bodySmall: GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      color: orchid,
      height: 1.55,
      letterSpacing: 0.1,
    ),
    labelLarge: GoogleFonts.barlowCondensed(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: deepBrown,
      letterSpacing: 2.2,
      height: 1.3,
    ),
    labelMedium: GoogleFonts.barlowCondensed(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: deepBrown,
      letterSpacing: 2.0,
      height: 1.3,
    ),
    labelSmall: GoogleFonts.barlowCondensed(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: orchid,
      letterSpacing: 2.5,
      height: 1.4,
    ),
  );
}

// ── GLACIALIS → Sora + Playfair (ice-luxury)
TextTheme _buildGlacialisTextTheme(_Palette p) {
  final ink = p.onSurface;
  final hint = p.onSurfaceVariant;
  const glacier = Color(0xFF2D6E9E);
  return TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: glacier,
      letterSpacing: -1.2,
      height: 1.0,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 44,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: glacier,
      letterSpacing: -0.8,
      height: 1.05,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: glacier,
      letterSpacing: -0.4,
      height: 1.1,
    ),
    headlineLarge: GoogleFonts.sora(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: 0.2,
      height: 1.15,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: 0.1,
      height: 1.2,
    ),
    headlineSmall: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ink,
      height: 1.25,
    ),
    titleLarge: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: ink,
      height: 1.3,
    ),
    titleMedium: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: ink,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.sora(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: 0.2,
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ink,
      height: 1.65,
    ),
    bodyMedium: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ink,
      height: 1.65,
    ),
    bodySmall: GoogleFonts.sora(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: hint,
      height: 1.55,
    ),
    labelLarge: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: 0.8,
      height: 1.3,
    ),
    labelMedium: GoogleFonts.sora(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: ink,
      letterSpacing: 1.0,
      height: 1.3,
    ),
    labelSmall: GoogleFonts.sora(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: hint,
      letterSpacing: 2.0,
      height: 1.4,
    ),
  );
}

// ── GRUNGE → Sora (aggressive) + Playfair (ironic luxury)
TextTheme _buildGrungeTextTheme(_Palette p) {
  final ink = p.onSurface;
  final hint = p.onSurfaceVariant;
  return TextTheme(
    displayLarge: GoogleFonts.spaceGrotesk(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: -2.5,
      height: 0.95,
    ),
    displayMedium: GoogleFonts.spaceGrotesk(
      fontSize: 44,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: -2.0,
      height: 0.98,
    ),
    displaySmall: GoogleFonts.spaceGrotesk(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: -1.5,
      height: 1.0,
    ),
    headlineLarge: GoogleFonts.sora(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: -0.8,
      height: 1.1,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: -0.5,
      height: 1.15,
    ),
    headlineSmall: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: -0.2,
      height: 1.2,
    ),
    titleLarge: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: -0.3,
      height: 1.25,
    ),
    titleMedium: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: ink,
      letterSpacing: -0.1,
      height: 1.35,
    ),
    titleSmall: GoogleFonts.sora(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: ink,
      height: 1.35,
    ),
    bodyLarge: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ink,
      height: 1.65,
    ),
    bodyMedium: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ink,
      height: 1.65,
    ),
    bodySmall: GoogleFonts.sora(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: hint,
      height: 1.55,
    ),
    labelLarge: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: ink,
      letterSpacing: 1.5,
      height: 1.3,
    ),
    labelMedium: GoogleFonts.sora(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: ink,
      letterSpacing: 1.8,
      height: 1.3,
    ),
    labelSmall: GoogleFonts.sora(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: hint,
      letterSpacing: 2.2,
      height: 1.4,
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// COLOR SCHEME BUILDER
// ═════════════════════════════════════════════════════════════════════════════

ColorScheme _buildColorScheme(_Palette p) => ColorScheme(
      brightness: Brightness.light,
      surface: p.surface,
      onSurface: p.onSurface,
      onSurfaceVariant: p.onSurfaceVariant,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.surfaceContainerLow,
      primaryFixed: p.surfaceContainerLow,
      primaryFixedDim: p.surfaceContainerHigh,
      surfaceContainer: p.surfaceContainer,
      surfaceContainerLow: p.surfaceContainerLow,
      surfaceContainerHigh: p.surfaceContainerHigh,
      surfaceContainerHighest: p.outline,
      secondary: p.primary,
      onSecondary: p.onPrimary,
      secondaryContainer: p.surfaceContainerLow,
      onSecondaryContainer: p.primary,
      tertiary: p.primary,
      onTertiary: p.onPrimary,
      tertiaryContainer: p.surfaceContainerHigh,
      onTertiaryContainer: p.primary,
      error: p.error,
      onError: p.onError,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      outline: p.outline,
      outlineVariant: p.outlineVariant,
      shadow: const Color(0x1A000000),
      scrim: const Color(0x80000000),
      inverseSurface: p.onSurface,
      onInverseSurface: p.surface,
      inversePrimary: p.surfaceContainerHigh,
      surfaceTint: p.primary,
    );

// ═════════════════════════════════════════════════════════════════════════════
// THEMEDATA BUILDER (with premium widget styling)
// ═════════════════════════════════════════════════════════════════════════════

ThemeData _buildThemeData(
  _Palette palette,
  EloquaGlass glass,
  EloquaShape shape,
  TextTheme tt,
  ThemeSlot slot,
) {
  final cs = _buildColorScheme(palette);
  final bool isParadise = slot == ThemeSlot.paradise;
  final bool isGrunge = slot == ThemeSlot.grunge;
  final bool isSpicy = slot == ThemeSlot.spicy;

  // Constants for non-paradise themes
  const white = Color(0xFFFFFFFF);
  const border = Color(0xFFFFFFFF);
  const borderOpacity = 0.15;

  // Helper: Premium card shape with 1px white border
  ShapeBorder cardShape() => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.card),
        side: BorderSide(
          color: isParadise ? cs.outline : border.withOpacity(borderOpacity),
          width: isParadise ? 2.0 : 1.0,
        ),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: cs,
    textTheme: tt,
    extensions: <ThemeExtension<dynamic>>[glass, shape],

    // ── Scaffold ──────────────────────────────────────────────────────────────
    scaffoldBackgroundColor: cs.surface,

    // ── AppBar ────────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: isParadise ? cs.primary : cs.surface,
      foregroundColor: isParadise ? white : cs.onSurface,
      elevation: isParadise ? 6 : 0,
      scrolledUnderElevation: isParadise ? 8 : 0,
      shadowColor:
          isParadise ? cs.primary.withOpacity(0.3) : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      systemOverlayStyle:
          isParadise ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(
        color: isParadise ? white : cs.onSurface,
        size: 22,
      ),
      titleTextStyle:
          isParadise ? tt.titleLarge?.copyWith(color: white) : tt.titleLarge,
    ),

    // ── Elevated Button ───────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isParadise ? cs.primary : cs.primary,
        foregroundColor: white,
        minimumSize: const Size(double.infinity, 54),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shape.button),
          side: BorderSide(
            color: isParadise
                ? cs.primaryContainer
                : border.withOpacity(borderOpacity),
            width: isParadise ? 2.5 : 1.0,
          ),
        ),
        textStyle: tt.labelLarge?.copyWith(color: white),
      ),
    ),

    // ── Outlined Button ───────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        side: BorderSide(
          color: isParadise ? cs.primaryContainer : cs.primary,
          width: isParadise ? 2.5 : 1.5,
        ),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shape.button),
        ),
        textStyle: tt.labelLarge,
      ),
    ),

    // ── Text Button ───────────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        textStyle: tt.labelLarge,
      ),
    ),

    // ── FAB ───────────────────────────────────────────────────────────────────
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cs.primary,
      foregroundColor: white,
      elevation: isParadise ? 12 : 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.button),
        side: isParadise
            ? BorderSide(color: cs.primaryContainer, width: 2.5)
            : BorderSide(color: border.withOpacity(borderOpacity), width: 1.0),
      ),
    ),

    // ── Input ─────────────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isParadise ? cs.surfaceContainerLow : white.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shape.input),
        borderSide: BorderSide(
          color: border.withOpacity(borderOpacity),
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shape.input),
        borderSide: BorderSide(
          color: isParadise
              ? cs.primaryContainer
              : border.withOpacity(borderOpacity),
          width: isParadise ? 2.0 : 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shape.input),
        borderSide: BorderSide(color: cs.primary, width: 2.5),
      ),
      hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      labelStyle: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
    ),

    // ── Card ──────────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: isParadise ? cs.surfaceContainer : white.withOpacity(0.7),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: cardShape(),
    ),

    // ── ListTile ──────────────────────────────────────────────────────────────
    listTileTheme: ListTileThemeData(
      tileColor: isParadise ? cs.surfaceContainer : white.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.card),
        side: BorderSide(
          color: isParadise
              ? cs.primaryContainer
              : border.withOpacity(borderOpacity),
          width: isParadise ? 1.5 : 1.0,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // ── Chip ──────────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor:
          isParadise ? cs.surfaceContainerLow : white.withOpacity(0.6),
      selectedColor: cs.primary,
      labelStyle: tt.labelSmall,
      secondaryLabelStyle: tt.labelSmall?.copyWith(color: white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.pill),
        side: BorderSide(
          color: isParadise
              ? cs.primaryContainer
              : border.withOpacity(borderOpacity),
          width: isParadise ? 2.0 : 1.0,
        ),
      ),
      elevation: isParadise ? 6 : 2,
      shadowColor:
          isParadise ? cs.primary.withOpacity(0.2) : Colors.transparent,
    ),

    // ── Dialog ────────────────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: isParadise ? cs.surfaceContainerLow : white,
      surfaceTintColor: Colors.transparent,
      elevation: isParadise ? 20 : 8,
      shadowColor: isParadise
          ? cs.primary.withOpacity(0.25)
          : cs.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.sheet),
        side: BorderSide(
          color: isParadise
              ? cs.primaryContainer
              : border.withOpacity(borderOpacity),
          width: isParadise ? 2.0 : 1.0,
        ),
      ),
    ),

    // ── BottomSheet ───────────────────────────────────────────────────────────
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isParadise ? cs.surfaceContainerLow : white,
      surfaceTintColor: Colors.transparent,
      elevation: isParadise ? 16 : 8,
      shadowColor:
          isParadise ? cs.primary.withOpacity(0.2) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(shape.sheet),
          topRight: Radius.circular(shape.sheet),
        ),
        side: BorderSide(
          color: isParadise
              ? cs.primaryContainer
              : border.withOpacity(borderOpacity),
          width: isParadise ? 2.0 : 1.0,
        ),
      ),
    ),

    // ── Divider ───────────────────────────────────────────────────────────────
    dividerTheme: DividerThemeData(
      color: border.withOpacity(isParadise ? 0.25 : 0.08),
      thickness: 1.0,
      space: 1,
    ),

    // ── Progress ──────────────────────────────────────────────────────────────
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: cs.primary,
      linearTrackColor: cs.surfaceContainerHigh,
      circularTrackColor: cs.surfaceContainerHigh,
      linearMinHeight: 6,
    ),

    // ── Switch ────────────────────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? white : cs.outline),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? cs.primary
              : cs.surfaceContainerHigh),
    ),

    // ── Checkbox ──────────────────────────────────────────────────────────────
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? cs.primary : Colors.transparent),
      checkColor: WidgetStateProperty.all(white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.xs),
      ),
      side: BorderSide(color: cs.outline, width: 1.5),
    ),

    // ── Radio ─────────────────────────────────────────────────────────────────
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? cs.primary : cs.outline),
    ),

    // ── Slider ────────────────────────────────────────────────────────────────
    sliderTheme: SliderThemeData(
      trackHeight: 6,
      activeTrackColor: cs.primary,
      inactiveTrackColor: cs.surfaceContainerHigh,
      thumbColor: cs.primary,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayColor: cs.primary.withValues(alpha: 0.12),
    ),

    // ── NavigationBar ─────────────────────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isParadise ? cs.primary : white,
      indicatorColor: isParadise ? white.withOpacity(0.20) : cs.primaryFixed,
      height: 74,
      elevation: isParadise ? 12 : 2,
      shadowColor:
          isParadise ? cs.primary.withOpacity(0.2) : Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? tt.labelSmall?.copyWith(
                  color: isParadise ? white : cs.primary,
                  fontWeight: FontWeight.w700,
                )
              : tt.labelSmall?.copyWith(
                  color: isParadise
                      ? white.withOpacity(0.60)
                      : cs.onSurfaceVariant,
                )),
      iconTheme: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? IconThemeData(
                  color: isParadise ? white : cs.primary,
                  size: 24,
                )
              : IconThemeData(
                  color: isParadise
                      ? white.withOpacity(0.60)
                      : cs.onSurfaceVariant,
                  size: 22,
                )),
    ),

    // ── TabBar ────────────────────────────────────────────────────────────────
    tabBarTheme: TabBarThemeData(
      labelColor: cs.primary,
      unselectedLabelColor: cs.onSurfaceVariant,
      labelStyle: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      unselectedLabelStyle: tt.labelMedium,
      indicatorColor: cs.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: border.withOpacity(0.08),
    ),

    // ── PopupMenu ─────────────────────────────────────────────────────────────
    popupMenuTheme: PopupMenuThemeData(
      color: isParadise ? cs.surfaceContainerLow : white,
      elevation: isParadise ? 12 : 4,
      shadowColor:
          isParadise ? cs.primary.withOpacity(0.2) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.card),
        side: BorderSide(
          color: isParadise
              ? cs.primaryContainer
              : border.withOpacity(borderOpacity),
          width: isParadise ? 2.0 : 1.0,
        ),
      ),
    ),

    // ── Tooltip ───────────────────────────────────────────────────────────────
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: cs.inverseSurface,
        borderRadius: BorderRadius.circular(shape.sm),
        border: Border.all(
          color: border.withOpacity(borderOpacity),
          width: 1.0,
        ),
      ),
      textStyle: tt.bodySmall?.copyWith(color: cs.onInverseSurface),
    ),

    // ── SnackBar ──────────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cs.inverseSurface,
      elevation: isParadise ? 12 : 4,
      contentTextStyle: tt.bodyMedium?.copyWith(color: cs.onInverseSurface),
      actionTextColor: cs.inversePrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.card),
        side: BorderSide(
          color: border.withOpacity(borderOpacity),
          width: 1.0,
        ),
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// THEME FACTORY (public API)
// ═════════════════════════════════════════════════════════════════════════════

abstract final class ThemeFactory {
  static ThemeData build(
    ThemeSlot slot, {
    EloquaGlass? glass,
    EloquaShape? shape,
  }) {
    final palette = _paletteFor(slot);
    final textTheme = _textThemeFor(slot, palette);
    return _buildThemeData(
      palette,
      glass ?? _glassFor(slot),
      shape ?? _shapeFor(slot),
      textTheme,
      slot,
    );
  }

  static Map<ThemeSlot, ThemeData> buildAll() => {
        for (final slot in ThemeSlot.values) slot: build(slot),
      };

  static _Palette _paletteFor(ThemeSlot slot) => switch (slot) {
        ThemeSlot.organic => _organic,
        ThemeSlot.spicy => _spicy,
        ThemeSlot.candy => _candy,
        ThemeSlot.paradise => _paradise,
        ThemeSlot.glacialis => _glacialis,
        ThemeSlot.grunge => _grunge,
      };

  static TextTheme _textThemeFor(ThemeSlot slot, _Palette p) => switch (slot) {
        ThemeSlot.organic => _buildOrganicTextTheme(p),
        ThemeSlot.spicy => _buildSpicyTextTheme(p),
        ThemeSlot.candy => _buildCandyTextTheme(p),
        ThemeSlot.paradise => _buildParadiseTextTheme(p),
        ThemeSlot.glacialis => _buildGlacialisTextTheme(p),
        ThemeSlot.grunge => _buildGrungeTextTheme(p),
      };
}

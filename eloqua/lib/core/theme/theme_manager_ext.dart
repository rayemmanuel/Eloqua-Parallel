// =============================================================================
// ELOQUA · THEME MANAGER EXT — PREMIUM UPGRADE (FIXED)
// =============================================================================
//
// Enhanced extensions:
//   • .shadowRamped — get ramped shadows for current theme
//   • .premiumGlass — access deep glassmorphism settings
//   • .cardPremium, .glassPremium — pre-built decorations
//
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import everything we need
import 'theme_factory.dart' show ThemeSlot, ThemeSlotLabel;
import 'theme_manager.dart'
    show
        ThemeManager,
        PremiumShadows,
        EloquaGlass,
        EloquaShape,
        LXMotion,
        LXHaptic;

// Export for convenience
export 'theme_factory.dart' show ThemeFactory, ThemeSlot, ThemeSlotLabel;

// ─────────────────────────────────────────────────────────────────────────────
// BUILDCONTEXT EXTENSIONS (Premium Sugar)
// ─────────────────────────────────────────────────────────────────────────────

extension ThemeManagerContext on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  ThemeManager get themeManager => read<ThemeManager>();
  ThemeManager get watchThemeManager => watch<ThemeManager>();

  /// True when Paradise theme is active — use for widget-level overrides.
  bool get isParadise => watch<ThemeManager>().isParadise;

  /// Returns [paradiseColor] when Paradise is active, else [fallback].
  Color paradiseOr(Color paradiseColor, Color fallback) =>
      isParadise ? paradiseColor : fallback;

  /// Returns the EloquaShape extension from the current theme.
  EloquaShape get shape =>
      Theme.of(this).extension<EloquaShape>() ?? const EloquaShape(scale: 1.0);

  /// Returns the EloquaGlass extension from the current theme.
  EloquaGlass get glass =>
      Theme.of(this).extension<EloquaGlass>() ?? EloquaGlass.standard;

  /// Premium glass: Deep glassmorphism (30-40px blur)
  EloquaGlass get premiumGlass => EloquaGlass.deep;

  /// Premium glass: Ultra-deep for intensive blur effects
  EloquaGlass get ultraDeepGlass => EloquaGlass.ultraDeep;

  /// Get ramped shadows for current theme
  List<BoxShadow> get shadowRamped {
    final slot = watch<ThemeManager>().currentSlot;
    return switch (slot) {
      ThemeSlot.organic => PremiumShadows.organicCards,
      ThemeSlot.spicy => PremiumShadows.spicyCards,
      ThemeSlot.candy => PremiumShadows.candyCards,
      ThemeSlot.paradise => [], // Paradise uses boxDecoration shadows in theme
      ThemeSlot.glacialis => PremiumShadows.glacialisCards,
      ThemeSlot.grunge => PremiumShadows.grungeCards,
    };
  }

  /// Elevated shadows (buttons, FABs, dialogs)
  List<BoxShadow> shadowElevated({Color? color}) =>
      PremiumShadows.elevated(primary: color ?? cs.primary);

  /// Hover/focus shadows
  List<BoxShadow> shadowHover({Color? color}) =>
      PremiumShadows.hover(primary: color ?? cs.primary);

  /// Premium border: 1px semi-transparent white
  Border get borderPremium => Border.all(
        color: const Color(0xFFFFFFFF).withOpacity(0.15),
        width: 1.0,
      );

  /// Premium border for paradise (uses primaryContainer)
  Border get borderParadise => Border.all(
        color: cs.primaryContainer,
        width: isParadise ? 2.0 : 1.0,
      );

  /// Dynamic shadow ramping: create a ramped shadow with custom color
  List<BoxShadow> shadowRampedCustom({
    required Color accentColor,
    double softOpacity = 0.08,
    double accentOpacity = 0.15,
  }) =>
      PremiumShadows.ramped(
        accentColor: accentColor,
        softOpacity: softOpacity,
        accentOpacity: accentOpacity,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET EXTENSIONS (Non-flat styling decorations)
// ─────────────────────────────────────────────────────────────────────────────

extension PremiumBoxDecorationContext on BuildContext {
  /// Premium card decoration: ramped shadow + premium border + subtle glass
  BoxDecoration get cardPremium => BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(shape.card),
        border: borderPremium,
        boxShadow: shadowRamped,
      );

  /// Premium elevated: stronger shadow + border
  BoxDecoration get surfaceElevated => BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(shape.card),
        border: borderPremium,
        boxShadow: shadowElevated(),
      );

  /// Premium hover state: lifted shadow
  BoxDecoration get surfaceHover => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(shape.card),
        border: borderPremium,
        boxShadow: shadowHover(),
      );

  /// Premium glass panel: 30px blur + 1px border
  BoxDecoration get glassPremium => BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(shape.card),
        border: borderPremium,
        boxShadow: shadowRamped,
      );

  /// Premium overlay: tinted glass with accent color
  BoxDecoration glassAccent({required Color accentColor}) => BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(shape.card),
        border: Border.all(
          color: accentColor.withOpacity(0.15),
          width: 1.0,
        ),
      );
}

// =============================================================================
// ELOQUA · THEME MANAGER — COMPLETE (Original Tokens + Premium Upgrades)
// =============================================================================

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme_factory.dart' show ThemeFactory, ThemeSlot, ThemeSlotLabel;

// ═════════════════════════════════════════════════════════════════════════════
// ORIGINAL · EloquaColors
// ═════════════════════════════════════════════════════════════════════════════

class EloquaColors {
  EloquaColors._();

  static const Color cream50 = Color(0xFFFDFAF4);
  static const Color cream100 = Color(0xFFF7F1E3);
  static const Color cream200 = Color(0xFFEDE4CC);
  static const Color sage200 = Color(0xFFA8C4A4);
  static const Color sage300 = Color(0xFF7A9E76);
  static const Color forest400 = Color(0xFF3A6B35);
  static const Color forest500 = Color(0xFF2D5428);
  static const Color forest600 = Color(0xFF1F3B1C);
  static const Color amber400 = Color(0xFFC8860A);
  static const Color clay400 = Color(0xFFB05A3A);
  static const Color textPrimary = Color(0xFF1A2B18);
  static const Color textSecondary = Color(0xFF4A6B45);
  static const Color textHint = Color(0xFF8AAB85);
  static const Color glassBg = Color(0xB8FDFAF4);
  static const Color glassBorder = Color(0x2E3A6B35);
  static const Color success = Color(0xFF2D5428);
  static const Color warning = Color(0xFFC8860A);
  static const Color error = Color(0xFFB05A3A);
  static const Color info = Color(0xFF3A6B35);
}

// ═════════════════════════════════════════════════════════════════════════════
// ORIGINAL · EloquaMotion
// ═════════════════════════════════════════════════════════════════════════════

class EloquaMotion {
  EloquaMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration entrance = Duration(milliseconds: 380);
  static const Duration scoreRing = Duration(milliseconds: 900);
  static const Duration personaReveal = Duration(milliseconds: 500);
  static const Duration fabPulse = Duration(milliseconds: 1600);
  static const Duration cardStagger = Duration(milliseconds: 60);
  static const Curve spring = Curves.easeOutBack;
  static const Curve smooth = Curves.easeOut;
  static const Curve decelerate = Curves.decelerate;
  static const Curve springBounce = Cubic(0.34, 1.56, 0.64, 1.0);
}

// ═════════════════════════════════════════════════════════════════════════════
// ORIGINAL · EloquaTextStyles
// ═════════════════════════════════════════════════════════════════════════════

class EloquaTextStyles {
  EloquaTextStyles._();

  static const TextStyle display = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: EloquaColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.1,
  );
  static const TextStyle heading1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: EloquaColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: EloquaColors.textPrimary,
    height: 1.3,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: EloquaColors.textPrimary,
    height: 1.6,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: EloquaColors.textPrimary,
    height: 1.5,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: EloquaColors.textSecondary,
    letterSpacing: 0.3,
  );
  static const TextStyle label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: EloquaColors.textHint,
    letterSpacing: 1.5,
  );
  static const TextStyle scoreValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: EloquaColors.forest500,
    letterSpacing: -0.5,
  );
  static const TextStyle statValue = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: EloquaColors.forest500,
    letterSpacing: -0.3,
  );
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: EloquaColors.cream50,
    letterSpacing: 0.2,
  );
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: EloquaColors.forest500,
    letterSpacing: 0.2,
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// ORIGINAL · EloquaRadius
// ═════════════════════════════════════════════════════════════════════════════

class EloquaRadius {
  EloquaRadius._();
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 28.0;
  static const double pill = 100.0;
}

// ═════════════════════════════════════════════════════════════════════════════
// ORIGINAL · EloquaShadows
// ═════════════════════════════════════════════════════════════════════════════

class EloquaShadows {
  EloquaShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x1F1F3B1C), blurRadius: 32, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> buttonPrimary = [
    BoxShadow(color: Color(0x4D2D5428), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> buttonHover = [
    BoxShadow(color: Color(0x662D5428), blurRadius: 20, offset: Offset(0, 6)),
  ];
  static const List<BoxShadow> fab = [
    BoxShadow(color: Color(0x592D5428), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> fabActive = [
    BoxShadow(
        color: Color(0x4D2D5428),
        blurRadius: 40,
        spreadRadius: 4,
        offset: Offset(0, 0)),
  ];
}

// ═════════════════════════════════════════════════════════════════════════════
// ORIGINAL · Glass / Background helpers
// ═════════════════════════════════════════════════════════════════════════════

BoxDecoration eloquaGlassCard({
  double radius = EloquaRadius.lg,
  Color? borderColor,
}) {
  return BoxDecoration(
    color: EloquaColors.glassBg,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: borderColor ?? EloquaColors.glassBorder,
      width: 1.0,
    ),
    boxShadow: EloquaShadows.card,
  );
}

BoxDecoration eloquaGlassNavBar() {
  return BoxDecoration(
    color: EloquaColors.glassBg,
    borderRadius: BorderRadius.circular(EloquaRadius.lg),
    border: Border.all(color: EloquaColors.glassBorder, width: 1.0),
    boxShadow: EloquaShadows.card,
  );
}

const BoxDecoration eloquaBackgroundGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFDFAF4),
      Color(0xFFEDE4CC),
      Color(0xFFD4E8CF),
    ],
    stops: [0.0, 0.45, 1.0],
  ),
);

// ═════════════════════════════════════════════════════════════════════════════
// ORIGINAL · buildEloquaOrganicTheme
// ═════════════════════════════════════════════════════════════════════════════

ThemeData buildEloquaOrganicTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: EloquaColors.forest500,
      onPrimary: EloquaColors.cream50,
      primaryContainer: EloquaColors.forest400,
      secondary: EloquaColors.sage300,
      onSecondary: EloquaColors.cream50,
      tertiary: EloquaColors.amber400,
      surface: EloquaColors.cream50,
      onSurface: EloquaColors.textPrimary,
      surfaceContainerHighest: EloquaColors.cream100,
      error: EloquaColors.clay400,
      onError: EloquaColors.cream50,
      outline: EloquaColors.glassBorder,
    ),
    scaffoldBackgroundColor: EloquaColors.cream50,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      iconTheme: IconThemeData(color: EloquaColors.forest500),
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: EloquaColors.textPrimary,
        letterSpacing: -0.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed))
            return EloquaColors.forest600;
          if (states.contains(WidgetState.hovered))
            return EloquaColors.forest400;
          return EloquaColors.forest500;
        }),
        foregroundColor: WidgetStateProperty.all(EloquaColors.cream50),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 2;
          if (states.contains(WidgetState.hovered)) return 8;
          return 4;
        }),
        shadowColor: WidgetStateProperty.all(
            EloquaColors.forest500.withValues(alpha: 0.35)),
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EloquaRadius.pill))),
        textStyle: WidgetStateProperty.all(EloquaTextStyles.buttonPrimary),
        animationDuration: EloquaMotion.fast,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return EloquaColors.forest500.withValues(alpha: 0.06);
          }
          return EloquaColors.glassBg;
        }),
        foregroundColor: WidgetStateProperty.all(EloquaColors.forest500),
        side: WidgetStateProperty.all(
            const BorderSide(color: EloquaColors.glassBorder, width: 1.5)),
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 22, vertical: 13)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EloquaRadius.pill))),
        textStyle: WidgetStateProperty.all(EloquaTextStyles.buttonSecondary),
        animationDuration: EloquaMotion.fast,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(EloquaColors.textSecondary),
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EloquaRadius.pill))),
        textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        animationDuration: EloquaMotion.fast,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: EloquaColors.glassBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(EloquaRadius.md),
        borderSide:
            const BorderSide(color: EloquaColors.glassBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(EloquaRadius.md),
        borderSide:
            const BorderSide(color: EloquaColors.glassBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(EloquaRadius.md),
        borderSide: const BorderSide(color: EloquaColors.forest400, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(EloquaRadius.md),
        borderSide: const BorderSide(color: EloquaColors.clay400, width: 1.5),
      ),
      labelStyle: const TextStyle(
        color: EloquaColors.textHint,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: EloquaColors.forest500,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(color: EloquaColors.textHint, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: EloquaColors.glassBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EloquaRadius.lg),
        side: const BorderSide(color: EloquaColors.glassBorder, width: 1.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: EloquaColors.forest500.withValues(alpha: 0.1),
      selectedColor: EloquaColors.forest500,
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: EloquaColors.forest500,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: EloquaColors.cream50,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EloquaRadius.pill),
      ),
      side: BorderSide.none,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: EloquaColors.glassBg,
      indicatorColor: EloquaColors.forest500.withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: EloquaColors.forest500, size: 22);
        }
        return const IconThemeData(color: EloquaColors.textHint, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: EloquaColors.forest500);
        }
        return const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: EloquaColors.textHint);
      }),
      elevation: 0,
      height: 68,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: EloquaColors.forest500,
      foregroundColor: EloquaColors.cream50,
      elevation: 8,
      focusElevation: 10,
      hoverElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(EloquaRadius.lg)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: EloquaColors.glassBorder,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: EloquaColors.forest500,
      linearTrackColor: Color(0x1F3A6B35),
      circularTrackColor: Color(0x1F3A6B35),
      linearMinHeight: 6,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: EloquaColors.forest500,
      inactiveTrackColor: EloquaColors.forest500.withValues(alpha: 0.15),
      thumbColor: EloquaColors.forest500,
      overlayColor: EloquaColors.forest500.withValues(alpha: 0.12),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      trackHeight: 4,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return EloquaColors.cream50;
        return EloquaColors.textHint;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected))
          return EloquaColors.forest500;
        return EloquaColors.glassBorder;
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: EloquaColors.forest600,
      contentTextStyle: const TextStyle(
        color: EloquaColors.cream50,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EloquaRadius.sm)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: EloquaColors.cream50,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EloquaRadius.lg)),
      elevation: 0,
      titleTextStyle: EloquaTextStyles.heading2,
      contentTextStyle: EloquaTextStyles.body,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// ORIGINAL · Widget Helpers
// ═════════════════════════════════════════════════════════════════════════════

class EloquaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? borderColor;

  const EloquaCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: eloquaGlassCard(
        radius: radius ?? EloquaRadius.lg,
        borderColor: borderColor,
      ),
      child: child,
    );
  }
}

class EloquaEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const EloquaEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<EloquaEntrance> createState() => _EloquaEntranceState();
}

class _EloquaEntranceState extends State<EloquaEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: EloquaMotion.entrance);
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: EloquaMotion.smooth),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: EloquaMotion.decelerate));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class EloquaPulsingFab extends StatefulWidget {
  final Widget child;
  final bool pulsing;

  const EloquaPulsingFab({
    super.key,
    required this.child,
    this.pulsing = false,
  });

  @override
  State<EloquaPulsingFab> createState() => _EloquaPulsingFabState();
}

class _EloquaPulsingFabState extends State<EloquaPulsingFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: EloquaMotion.fabPulse);
    _scale = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.4)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(EloquaPulsingFab old) {
    super.didUpdateWidget(old);
    if (widget.pulsing && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.pulsing) {
      _ctrl.stop();
      _ctrl.animateTo(0, duration: EloquaMotion.normal);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.pulsing ? _scale.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(EloquaRadius.lg),
              boxShadow: widget.pulsing
                  ? [
                      BoxShadow(
                        color: EloquaColors.forest500
                            .withValues(alpha: _glowOpacity.value),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ]
                  : EloquaShadows.fab,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CLASSMATE ADDITIONS · LX, LXT, LXMotion, LXDeco
// ═════════════════════════════════════════════════════════════════════════════

abstract final class LX {
  static const forest = Color(0xFF1B3A2D);
  static const forestMid = Color(0xFF2D5240);
  static const forestLight = Color(0xFF3D6E58);
  static const sage = Color(0xFF4A7C63);
  static const sageSoft = Color(0xFF6B9E84);
  static const mint = Color(0xFFB8D4C4);
  static const mintLight = Color(0xFFD4E8DC);
  static const mintFrost = Color(0xFFEAF3EE);
  static const cream = Color(0xFFF5F2EB);
  static const creamWarm = Color(0xFFEFEBE2);
  static const creamDeep = Color(0xFFE8E3D8);
  static const sand = Color(0xFFD4CBBA);
  static const taupe = Color(0xFF8C8070);
  static const charcoal = Color(0xFF3A3530);
  static const ink = Color(0xFF1A1714);
  static const pure = Color(0xFFFFFFFF);
  static const success = Color(0xFF2D6741);
  static const warning = Color(0xFF8B6A2E);
  static const danger = Color(0xFF8B3A2E);
  static const amber = Color(0xFFF0A500);
  static const glassBg = Color(0xB2F5F2EB);
  static const glassBorder = Color(0x33D4CBBA);
  static const chartPalette = <Color>[
    Color(0xFF2D5240),
    Color(0xFF6B9E84),
    Color(0xFFB8D4C4),
    Color(0xFF4A7C63),
  ];
  static const paradiseSurface = Color(0xFFFAE640);
  static const paradisePrimary = Color(0xFFE8407A);
  static const paradiseOrange = Color(0xFFD4561E);
  static const paradiseGreen = Color(0xFF2E9E56);
  static const paradiseTurquoise = Color(0xFF3AAAB8);
  static const paradiseCream = Color(0xFFFFF5E0);
  static const paradiseBrown = Color(0xFF2C1A0E);
  static const paradiseOrchid = Color(0xFF9B4DB5);
  static const paradiseAmber = Color(0xFFF5D820);
  static const paradiseWhite = Color(0xFFFFFFFF);
  static const bone = cream;
  static const parchment = creamWarm;
  static const linen = creamDeep;
  static const stone = taupe;
  static const graphite = charcoal;
  static const sienna = Color(0xFF8B4A2E);
  static const verdigris = forestLight;
  static const dust = Color(0xFFC4A882);
  static const meshA = cream;
  static const meshB = Color(0xFFEDE8DF);
  static const meshC = mintFrost;
}

abstract final class LXT {
  static const display = TextStyle(
      fontFamily: 'Georgia',
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: LX.ink,
      letterSpacing: -0.8,
      height: 1.1,
      fontStyle: FontStyle.italic);
  static const headline = TextStyle(
      fontFamily: 'Georgia',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: LX.ink,
      letterSpacing: -0.4,
      height: 1.2);
  static const headlineSm = TextStyle(
      fontFamily: 'Georgia',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: LX.ink,
      letterSpacing: -0.2,
      height: 1.25);
  static const overline = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: LX.taupe,
      letterSpacing: 2.0,
      height: 1.4);
  static const body = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: LX.charcoal,
      height: 1.6);
  static const bodyBold = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600, color: LX.ink, height: 1.5);
  static const caption = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400, color: LX.taupe, height: 1.5);
  static const mono = TextStyle(
      fontFamily: 'Courier New',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: LX.charcoal,
      letterSpacing: 0.5);
  static const stat = TextStyle(
      fontFamily: 'Georgia',
      fontSize: 48,
      fontWeight: FontWeight.w700,
      color: LX.ink,
      letterSpacing: -2,
      height: 1.0);
  static const statSm = TextStyle(
      fontFamily: 'Georgia',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: LX.ink,
      letterSpacing: -1,
      height: 1.0);
  static const label = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: LX.charcoal,
      letterSpacing: 0.2);
  static const labelLight = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: LX.taupe,
      letterSpacing: 0.2);
  static const btn = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: LX.pure,
      letterSpacing: 0.4);
  static const btnDark = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: LX.ink,
      letterSpacing: 0.4);
}

abstract final class LXMotion {
  static const snap = Duration(milliseconds: 120);
  static const fast = Duration(milliseconds: 220);
  static const normal = Duration(milliseconds: 380);
  static const slow = Duration(milliseconds: 600);
  static const reveal = Duration(milliseconds: 900);
  static const ease = Curves.easeOut;
  static const spring = Curves.easeOutCubic;
  static const decel = Curves.decelerate;
  static const Duration entrance = reveal;
  static const Duration fabPulse = Duration(milliseconds: 1600);
  static const Curve smooth = spring;
  static const Curve decelerate = decel;
}

abstract final class LXDeco {
  static BoxDecoration get pageMesh => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LX.cream, LX.creamWarm, LX.mintFrost],
          stops: [0.0, 0.5, 1.0],
        ),
      );
  static BoxDecoration get card => BoxDecoration(
        color: LX.pure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LX.creamDeep, width: 0.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 4))
        ],
      );
  static BoxDecoration get cardElevated => BoxDecoration(
        color: LX.pure,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LX.creamDeep, width: 0.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x12000000), blurRadius: 32, offset: Offset(0, 10)),
          BoxShadow(
              color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      );
  static BoxDecoration get mintCard => BoxDecoration(
        color: LX.mintFrost,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LX.mint, width: 0.5),
      );
  static BoxDecoration get forestCard => BoxDecoration(
        color: LX.forest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x301B3A2D), blurRadius: 24, offset: Offset(0, 8))
        ],
      );
  static BoxDecoration get glass => BoxDecoration(
        color: LX.glassBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LX.glassBorder, width: 0.5),
      );
  static BoxDecoration get darkCard => BoxDecoration(
        color: LX.forest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 0.5),
      );
  static BoxDecoration chip({Color? bg, Color? border}) => BoxDecoration(
        color: bg ?? LX.creamWarm,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border ?? LX.creamDeep, width: 0.5),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// CLASSMATE ADDITIONS · PremiumShadows, LXHaptic
// ═════════════════════════════════════════════════════════════════════════════

abstract final class PremiumShadows {
  static List<BoxShadow> ramped({
    required Color accentColor,
    double softOpacity = 0.08,
    double accentOpacity = 0.15,
  }) =>
      [
        BoxShadow(
          color: Color.lerp(const Color(0xFF000000), accentColor, 0.3)!
              .withOpacity(softOpacity),
          blurRadius: 32,
          offset: const Offset(0, 16),
          spreadRadius: 0,
        ),
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
      accentOpacity: 0.12);
  static List<BoxShadow> get spicyCards => ramped(
      accentColor: const Color(0xFF8B1A1A),
      softOpacity: 0.08,
      accentOpacity: 0.16);
  static List<BoxShadow> get candyCards => ramped(
      accentColor: const Color(0xFFE896B2),
      softOpacity: 0.10,
      accentOpacity: 0.18);
  static List<BoxShadow> get glacialisCards => ramped(
      accentColor: const Color(0xFF4A90B8),
      softOpacity: 0.07,
      accentOpacity: 0.14);
  static List<BoxShadow> get grungeCards => ramped(
      accentColor: const Color(0xFF111111),
      softOpacity: 0.12,
      accentOpacity: 0.20);
  static List<BoxShadow> elevated({required Color primary}) => [
        BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: 0),
        BoxShadow(
            color: primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0),
      ];
  static List<BoxShadow> hover({required Color primary}) => [
        BoxShadow(
            color: primary.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0),
        BoxShadow(
            color: primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: 0),
      ];
}

abstract final class LXHaptic {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void select() => HapticFeedback.selectionClick();
  static void rigid() => HapticFeedback.heavyImpact();
}

// ═════════════════════════════════════════════════════════════════════════════
// CLASSMATE ADDITIONS · EloquaGlass, EloquaShape
// ═════════════════════════════════════════════════════════════════════════════

@immutable
class EloquaGlass extends ThemeExtension<EloquaGlass> {
  const EloquaGlass({required this.blurSigma, required this.overlayOpacity});

  final double blurSigma;
  final double overlayOpacity;

  static const standard = EloquaGlass(blurSigma: 14, overlayOpacity: 0.70);
  static const heavy = EloquaGlass(blurSigma: 20, overlayOpacity: 0.80);
  static const light = EloquaGlass(blurSigma: 8, overlayOpacity: 0.60);
  static const deep = EloquaGlass(blurSigma: 32, overlayOpacity: 0.65);
  static const ultraDeep = EloquaGlass(blurSigma: 40, overlayOpacity: 0.72);

  @override
  EloquaGlass copyWith({double? blurSigma, double? overlayOpacity}) =>
      EloquaGlass(
        blurSigma: blurSigma ?? this.blurSigma,
        overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      );

  @override
  EloquaGlass lerp(EloquaGlass? other, double t) {
    if (other == null) return this;
    return EloquaGlass(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
      overlayOpacity: lerpDouble(overlayOpacity, other.overlayOpacity, t)!,
    );
  }
}

@immutable
class EloquaShape extends ThemeExtension<EloquaShape> {
  const EloquaShape({required this.scale});

  final double scale;
  static const double _xs = 4,
      _sm = 8,
      _md = 12,
      _lg = 16,
      _xl = 24,
      _pill = 100;

  double get xs => (_xs * scale).clamp(0, _pill);
  double get sm => (_sm * scale).clamp(0, _pill);
  double get md => (_md * scale).clamp(0, _pill);
  double get lg => (_lg * scale).clamp(0, _pill);
  double get xl => (_xl * scale).clamp(0, _pill);
  double get pill => _pill;
  double get button => md;
  double get input => md;
  double get card => lg;
  double get chip => pill;
  double get sheet => xl;

  @override
  EloquaShape copyWith({double? scale}) =>
      EloquaShape(scale: scale ?? this.scale);

  @override
  EloquaShape lerp(EloquaShape? other, double t) {
    if (other == null) return this;
    return EloquaShape(scale: lerpDouble(scale, other.scale, t)!);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CLASSMATE ADDITIONS · ThemeManager
// ═════════════════════════════════════════════════════════════════════════════

class ThemeManager extends ChangeNotifier {
  ThemeSlot _current = ThemeSlot.organic;
  ThemeSlot get currentSlot => _current;

  late final Map<ThemeSlot, ThemeData> _cache;

  ThemeManager() {
    _cache = ThemeFactory.buildAll();
  }

  ThemeData get theme => _cache[_current]!;
  ThemeData themeForSlot(ThemeSlot slot) => _cache[slot]!;

  void setSlot(ThemeSlot slot) {
    if (_current == slot) return;
    _current = slot;
    notifyListeners();
  }

  void next() {
    final slots = ThemeSlot.values;
    setSlot(slots[(slots.indexOf(_current) + 1) % slots.length]);
  }

  void previous() {
    final slots = ThemeSlot.values;
    setSlot(slots[(slots.indexOf(_current) - 1 + slots.length) % slots.length]);
  }

  void toggleDefault() => setSlot(ThemeSlot.organic);

  List<(ThemeSlot, String)> get allSlots =>
      ThemeSlot.values.map((s) => (s, s.label)).toList();

  String get currentLabel => _current.label;
  Color get currentSwatch => _current.swatch;
  Color get currentSwatchBg => _current.swatchBg;

  bool get isParadise => _current == ThemeSlot.paradise;
}

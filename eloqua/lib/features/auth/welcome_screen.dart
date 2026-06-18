import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/strings.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/theme_manager_ext.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbCtrl = AnimationController(
    vsync: this,
    duration:
        const Duration(seconds: 12), // Slightly slower for a more premium feel
  )..repeat();

  @override
  void dispose() {
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.isParadise;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        decoration: isParadise
            ? BoxDecoration(
                color: cs.surface,
                image: const DecorationImage(
                  image: AssetImage('assets/images/mesh_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.08,
                ),
              )
            : null,
        child: SafeArea(
          child: Stack(
            children: [
              // ───────────────────────────────────────────────────────────────
              // DYNAMIC FLOATING ORBS
              // ───────────────────────────────────────────────────────────────
              AnimatedBuilder(
                animation: _orbCtrl,
                builder: (_, __) {
                  final p = _orbCtrl.value;

                  return Stack(
                    children: [
                      // 1. Large Top Right Orb
                      Positioned(
                        top: 10 + math.sin(p * 2 * math.pi) * 50,
                        right: -70 + math.cos(p * 2 * math.pi) * 40,
                        child: _Orb(
                            size: 300,
                            color: cs.primaryContainer.withOpacity(0.5)),
                      ),

                      // 2. Medium Bottom Left Orb
                      Positioned(
                        bottom: 80 + math.cos(p * 2 * math.pi) * 70,
                        left: -90 + math.sin(p * 2 * math.pi) * 50,
                        child: _Orb(
                            size: 240,
                            color: cs.secondaryContainer.withOpacity(0.35)),
                      ),

                      // 3. Center Right Floating Orb (New)
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.4 +
                            math.sin(p * 1.5 * math.pi) * 40,
                        right: -30 + math.cos(p * 1.5 * math.pi) * 30,
                        child: _Orb(
                            size: 140, color: cs.primary.withOpacity(0.06)),
                      ),

                      // 4. Bottom Right Deep Orb (New)
                      Positioned(
                        bottom: 20 + math.sin(p * 2.5 * math.pi) * 30,
                        right: 40 + math.cos(p * 2.5 * math.pi) * 20,
                        child: _Orb(
                            size: 100, color: cs.secondary.withOpacity(0.04)),
                      ),

                      // 5. Small Accent Orb (Faster)
                      Positioned(
                        top: 250 + math.sin(p * 4 * math.pi) * 40,
                        left: 60 + math.cos(p * 3 * math.pi) * 30,
                        child:
                            _Orb(size: 45, color: cs.primary.withOpacity(0.08)),
                      ),
                    ],
                  );
                },
              ),

              // ───────────────────────────────────────────────────────────────
              // UI CONTENT
              // ───────────────────────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          AppConfig.appName.toUpperCase(),
                          style: tt.labelSmall?.copyWith(
                            color: cs.primary,
                            letterSpacing: 3.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 38),
                      ],
                    ),

                    const Spacer(),

                    // Hero Icon - FIX 1: Added Hero tag for seamless cross-screen animations
                    Hero(
                      tag: 'app_logo_hero_tag',
                      child: SizedBox(
                        width: 210,
                        height: 210,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    Text(
                      'Find Your\nVoice',
                      textAlign: TextAlign.center,
                      style: isParadise
                          ? GoogleFonts.playfairDisplay(
                              fontSize: 44,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              height: 1.1,
                            )
                          : tt.headlineLarge?.copyWith(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              height: 1.1,
                            ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      AppStrings.welcomeSubtitle,
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),

                    const Spacer(),

                    _PremiumButton(
                      label: AppStrings.welcomeGetStarted,
                      isParadise: isParadise,
                      trailing: Icon(Icons.arrow_forward_rounded,
                          color: cs.onPrimary, size: 20),
                      onTap: () {
                        HapticService.instance.medium();
                        // FIX 2: Custom PageRouteBuilder for smooth FadeTransition
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const OnboardingScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    _PremiumButton(
                      label: AppStrings.welcomeLogin,
                      outlined: true,
                      isParadise: isParadise,
                      onTap: () {
                        HapticService.instance.light();
                        // FIX 2: Custom PageRouteBuilder for smooth FadeTransition
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const LoginScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
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

// Internal Orb Widget for cleaner code
class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final Widget? trailing;
  final bool isParadise;

  const _PremiumButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.trailing,
    required this.isParadise,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    // FIX 3: Replaced GestureDetector with Material & InkWell for ripple transitions
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: outlined ? cs.surface : cs.primary,
            borderRadius: BorderRadius.circular(16),
            border: outlined ? Border.all(color: cs.primary, width: 2) : null,
            boxShadow: outlined
                ? null
                : [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: isParadise
                    ? GoogleFonts.oswald(
                        color: outlined ? cs.primary : cs.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      )
                    : context.tt.labelLarge?.copyWith(
                        color: outlined ? cs.primary : cs.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

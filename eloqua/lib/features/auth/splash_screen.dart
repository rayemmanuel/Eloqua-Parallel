import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/theme_manager_ext.dart'; // Added for context.cs/tt/isParadise
import '../../main.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 0.85,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
  ));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final auth = context.read<AuthService>();
    await auth.init();

    if (!mounted) return;

    final String dest = auth.isLoggedIn ? '/home' : '/welcome';
    Navigator.pushReplacementNamed(context, dest);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.isParadise;

    return Scaffold(
      backgroundColor: cs.surface, // Matches onboarding background
      body: Container(
        // Integrated the mesh background logic from your Onboarding Screen
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
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo icon with the same shadow/radius as onboarding icons
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AppConfig.useLogoImage
                          ? Image.asset(
                              AppConfig.logoPath,
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            )
                          : Icon(
                              Icons.language_rounded,
                              color: cs.onPrimary,
                              size: 42,
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Brand name using GoogleFonts if in Paradise mode
                  Text(
                    AppConfig.appName.toUpperCase(),
                    style: isParadise
                        ? GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                            letterSpacing: 6.0,
                          )
                        : tt.labelSmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4.0,
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Tagline using your theme variables
                  Text(
                    AppStrings.splashTagline,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

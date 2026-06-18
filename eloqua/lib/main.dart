import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// ── Design system ─────────────────────────────────────────────────────────────
import 'package:eloqua/core/theme/theme_manager.dart';
import 'package:eloqua/core/theme/theme_manager_ext.dart';

// ── Services ──────────────────────────────────────────────────────────────────
import 'package:eloqua/core/services/auth_service.dart';
import 'package:eloqua/core/services/session_service.dart';
import 'package:eloqua/core/services/speech_evaluation_service.dart';
import 'package:eloqua/core/services/haptic_service.dart';
import 'package:eloqua/core/services/tts_service.dart';
import 'package:eloqua/core/services/voice_service.dart';
import 'package:eloqua/core/services/pdf_service.dart';
import 'package:eloqua/core/services/share_service.dart';
import 'package:eloqua/core/services/feed_service.dart';

// ── Screens ───────────────────────────────────────────────────────────────────
import 'package:eloqua/features/auth/splash_screen.dart';
import 'package:eloqua/features/auth/welcome_screen.dart';
import 'package:eloqua/features/auth/onboarding_screen.dart';
import 'package:eloqua/features/auth/login_screen.dart';
import 'package:eloqua/features/auth/register_screen.dart';
import 'package:eloqua/features/auth/forgot_password_screen.dart';
import 'package:eloqua/features/home/home_screen.dart';
import 'package:eloqua/features/preparation/prep_screen.dart';
import 'package:eloqua/features/spontaneous/spont_screen.dart';
import 'package:eloqua/features/feedback/feedback_screen.dart';
import 'package:eloqua/features/share/share_screen.dart';
import 'package:eloqua/features/chat/ai_chat_screen.dart';
import 'package:eloqua/features/analytics/analytics_screen.dart';
import 'package:eloqua/features/history/history_screen.dart';
import 'package:eloqua/features/leaderboard/leaderboard_screen.dart';
import 'package:eloqua/features/social/social_screen.dart';
import 'package:eloqua/features/social/circuit_leaderboard_screen.dart';
import 'package:eloqua/features/profile/profile_screen.dart';
import 'package:eloqua/features/settings/settings_screen.dart';
import 'package:eloqua/features/filler_jar/filler_jar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await AuthService.instance.init();
  final userId = AuthService.instance.userId;
  if (userId != null) {
    await SessionService.instance.load(userId);
  }

  runApp(const EloquaApp());
}

class EloquaApp extends StatelessWidget {
  const EloquaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // FIXED: Injected her ThemeManager at the very root of the app
        ChangeNotifierProvider<ThemeManager>(
          create: (_) => ThemeManager(),
        ),
        ChangeNotifierProvider<AuthService>.value(
          value: AuthService.instance,
        ),
        ChangeNotifierProvider<SessionService>.value(
          value: SessionService.instance,
        ),
        ChangeNotifierProvider<SpeechEvaluationService>.value(
          value: SpeechEvaluationService.instance,
        ),
        ChangeNotifierProvider<FeedService>(
          create: (_) => FeedService.instance..load(),
        ),
        Provider<HapticService>.value(
          value: HapticService.instance,
        ),
        ChangeNotifierProvider<TtsService>(
          create: (_) => TtsService(),
        ),
        ChangeNotifierProvider<VoiceService>(
          create: (_) => VoiceService(),
        ),
        Provider<PdfService>.value(
          value: PdfService.instance,
        ),
        Provider<ShareService>.value(
          value: ShareService.instance,
        ),
      ],
      // We extract MaterialApp to a child widget so it can access the ThemeManager context
      child: const _EloquaMaterialApp(),
    );
  }
}

class _EloquaMaterialApp extends StatelessWidget {
  const _EloquaMaterialApp();

  @override
  Widget build(BuildContext context) {
    // Watch the theme manager to dynamically update the entire app's theme
    final themeManager = context.watchThemeManager;

    return MaterialApp(
      title: 'Eloqua',
      debugShowCheckedModeBanner: false,
      theme: themeManager
          .theme, // Swapped from your hardcoded theme to the dynamic one
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final routes = _buildRoutes();
        final builder = routes[settings.name];
        if (builder == null) return null;
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, _, __) => builder(context),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, _, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          ),
        );
      },
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/': (_) => const SplashScreen(),
      '/welcome': (_) => const WelcomeScreen(),
      '/onboarding': (_) => const OnboardingScreen(),
      '/login': (_) => const LoginScreen(),
      '/register': (_) => const RegisterScreen(),
      '/forgot-password': (_) => const ForgotPasswordScreen(),
      '/home': (_) =>
          const RootShell(), // Ensure this points to RootShell, not HomeScreen
      '/prep': (_) => const PrepScreen(),
      '/spontaneous': (_) => const SpontScreen(),
      '/practice': (_) => const SpontScreen(),
      '/feedback': (_) =>
          const FeedbackScreen(durationSecs: 0, fillerCount: 0, topicTitle: ''),
      '/share': (_) => const ShareScreen(
          overall: 0,
          clarity: 0,
          pacing: 0,
          grammar: 0,
          confidence: 0,
          topicTitle: '',
          duration: ''),
      '/chat': (_) => const AiChatScreen(),
      '/analytics': (_) => const AnalyticsScreen(),
      '/history': (_) => const HistoryScreen(),
      '/leaderboard': (_) => const LeaderboardScreen(),
      '/social': (_) => const SocialScreen(),
      '/circuit': (_) => const CircuitLeaderboardScreen(),
      '/profile': (_) => const ProfileScreen(),
      '/settings': (_) => const SettingsScreen(),
      '/filler-jar': (_) => const FillerJarScreen(),
    };
  }
}

// ── RootShell ─────────────────────────────────────────────────────────────────
class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AnalyticsScreen(),
    SocialScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watchThemeManager;

    return Scaffold(
      backgroundColor: themeManager.theme.scaffoldBackgroundColor,
      body: Stack(
        children: List.generate(_screens.length, (i) {
          final offset = i - _index;
          return AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            offset: Offset(offset.toDouble().clamp(-1.0, 1.0), 0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _index == i ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: _index != i,
                child: _screens[i],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ── Custom Bottom Nav ─────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.home_outlined, Icons.home_filled, 'HOME'),
    (Icons.bar_chart_outlined, Icons.bar_chart, 'STATS'),
    (Icons.people_outline, Icons.people, 'SOCIAL'),
    (Icons.person_outline, Icons.person, 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isParadise = context.watchThemeManager.isParadise;

    final navBg = isParadise ? const Color(0xFFE8407A) : cs.surfaceContainer;
    final navBorder = isParadise ? const Color(0xFFD4561E) : cs.outlineVariant;
    final selColor = isParadise ? Colors.white : cs.primary;
    final unselColor =
        isParadise ? Colors.white.withValues(alpha: 0.55) : cs.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(color: navBorder, width: isParadise ? 2.0 : 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final inactiveIcon = item.$1;
              final activeIcon = item.$2;
              final label = item.$3;
              final sel = currentIndex == i;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (currentIndex != i) {
                    HapticFeedback
                        .selectionClick(); // Replaced her custom haptic with standard
                    onTap(i);
                  }
                },
                child: AnimatedOpacity(
                  duration: const Duration(
                      milliseconds: 200), // Replaced custom duration
                  opacity: sel ? 1.0 : (isParadise ? 0.6 : 0.35),
                  child: SizedBox(
                    width: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sel ? activeIcon : inactiveIcon,
                          color: sel ? selColor : unselColor,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: tt.labelSmall?.copyWith(
                            fontSize: 9,
                            color: sel ? selColor : unselColor,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

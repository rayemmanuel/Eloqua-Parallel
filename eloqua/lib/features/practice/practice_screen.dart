import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/strings.dart';
import '../../core/services/api_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/session_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/theme/theme_manager_ext.dart';
import '../feedback/feedback_screen.dart';

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

// ── Provider ──────────────────────────────────────────────────────────────────
class PracticeProvider extends ChangeNotifier {
  bool _recording = false;
  bool _paused = false;
  bool _analyzing = false;
  int _secs = 0;
  int _fillers = 0;
  String? _analyzeError;
  final ScrollController scroll = ScrollController();

  bool get recording => _recording;
  bool get paused => _paused;
  bool get analyzing => _analyzing;
  int get fillers => _fillers;
  int get secs => _secs;
  String? get analyzeError => _analyzeError;

  String get timer {
    final m = (_secs ~/ 60).toString().padLeft(2, '0');
    final s = (_secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void start() {
    _recording = true;
    _paused = false;
    notifyListeners();
  }

  void pause() {
    _paused = true;
    notifyListeners();
  }

  void resume() {
    _paused = false;
    notifyListeners();
  }

  void stop() {
    _recording = false;
    _paused = false;
    notifyListeners();
  }

  void tick() {
    if (_recording && !_paused) {
      _secs++;
      notifyListeners();
    }
  }

  void filler() {
    _fillers++;
    HapticService.instance.light();
    notifyListeners();
  }

  void setAnalyzing(bool v) {
    _analyzing = v;
    notifyListeners();
  }

  void setError(String? msg) {
    _analyzeError = msg;
    notifyListeners();
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class PracticeScreen extends StatefulWidget {
  final List<String> talkingPoints;
  final String topicTitle;
  final String mode;
  final String? framework;

  const PracticeScreen({
    super.key,
    required this.talkingPoints,
    required this.topicTitle,
    this.mode = 'spontaneous',
    this.framework,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {
  final _provider = PracticeProvider();

  // Camera
  CameraController? _cam;
  bool _camReady = false;
  bool _camDenied = false;

  // Timer
  late AnimationController _timerCtrl;

  // Countdown
  bool _counting = false;
  int _countdown = 3;

  final String _token = AuthService.instance.token!;

  static const _personas = [
    'The Practitioner',
    'The Scholar',
    'The Conductor',
    'The Orator',
  ];

  @override
  void initState() {
    super.initState();
    _timerCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addStatusListener((s) {
            if (s == AnimationStatus.completed && mounted) {
              _provider.tick();
              _timerCtrl.forward(from: 0);
            }
          });

    _initCamera();
  }

  Future<void> _initCamera() async {
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!camStatus.isGranted || !micStatus.isGranted) {
      if (mounted) setState(() => _camDenied = true);
      return;
    }
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) return;
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      _cam =
          CameraController(front, ResolutionPreset.medium, enableAudio: true);
      await _cam!.initialize();
      if (mounted) setState(() => _camReady = true);
    } catch (_) {
      if (mounted) setState(() => _camDenied = true);
    }
  }

  Future<void> _startCountdown() async {
    setState(() {
      _counting = true;
      _countdown = 3;
    });
    await HapticService.instance.medium();
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() => _countdown = 2);
    await HapticService.instance.medium();
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() => _countdown = 1);
    await HapticService.instance.medium();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() => _counting = false);

    _provider.start();
    _timerCtrl.forward(from: 0);
    if (_camReady && _cam != null && !(_cam!.value.isRecordingVideo)) {
      try {
        await _cam!.startVideoRecording();
      } catch (_) {}
    }
  }

  Future<void> _confirmEnd() async {
    final tt = context.tt;
    final isParadise = context.read<ThemeManager>().isParadise;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isParadise ? _pCream : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppStrings.practiceEndTitle,
          style: isParadise
              ? GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w800, color: _pBrown)
              : tt.titleLarge?.copyWith(
                  fontFamily: 'Georgia', fontWeight: FontWeight.w700),
        ),
        content: Text(
          AppStrings.practiceEndBody,
          style: isParadise
              ? GoogleFonts.nunito(color: _pBrown.withOpacity(0.8))
              : null,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.practiceEndNo,
                  style: TextStyle(color: isParadise ? _pOrange : null))),
          ElevatedButton(
              style: isParadise
                  ? ElevatedButton.styleFrom(
                      backgroundColor: _pFuchsia, foregroundColor: _pWhite)
                  : null,
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(AppStrings.practiceEndYes)),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    _provider.stop();
    _timerCtrl.stop();
    await HapticService.instance.strong();

    XFile? videoFile;
    if (_camReady && _cam != null && _cam!.value.isRecordingVideo) {
      try {
        videoFile = await _cam!.stopVideoRecording();
      } catch (_) {}
    }

    if (!mounted) return;

    _provider.setAnalyzing(true);

    if (videoFile != null) {
      final persona =
          _personas[DateTime.now().millisecondsSinceEpoch % _personas.length];

      final result = await ApiService.instance.analyze(
        videoFile: File(videoFile.path),
        token: _token,
        topic: widget.topicTitle,
        practiceMode: widget.mode,
        talkingPoints: widget.talkingPoints,
      );

      if (!mounted) return;

      if (result.success) {
        await SessionService.instance.saveFromAnalyzeResult(
          result: result.data!,
          topic: widget.topicTitle,
          persona: persona,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => FeedbackScreen(
                durationSecs: result.data!.durationSeconds.round(),
                fillerCount: result.data!.totalFillers,
                topicTitle: widget.topicTitle,
                mode: widget.mode,
                analyzeResult: result.data,
                framework: widget.framework,
              ),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
                child: child,
              ),
            ));
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => FeedbackScreen(
                durationSecs: _provider.secs,
                fillerCount: _provider.fillers,
                topicTitle: widget.topicTitle,
                mode: widget.mode,
                analyzeResult: null,
                errorMessage: result.error,
                framework: widget.framework,
              ),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
                child: child,
              ),
            ));
      }
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => FeedbackScreen(
              durationSecs: _provider.secs,
              fillerCount: _provider.fillers,
              topicTitle: widget.topicTitle,
              mode: widget.mode,
              analyzeResult: null,
              errorMessage: 'Camera unavailable — video could not be recorded.',
              framework: widget.framework,
            ),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
              child: child,
            ),
          ));
    }
  }

  @override
  void dispose() {
    _provider.dispose();
    _cam?.dispose();
    _timerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isParadise = context.watch<ThemeManager>().isParadise;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<PracticeProvider>(builder: (ctx, p, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // ── Layer 0: Camera preview ──────────────────────────────────
              _CameraLayer(
                controller: _cam,
                isReady: _camReady,
                isDenied: _camDenied,
                isParadise: isParadise,
              ),

              // ── Layer 1: Gradient overlay ────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xCC000000),
                      Colors.transparent,
                      isParadise
                          ? _pBrown.withOpacity(0.8)
                          : const Color(0xDD000000),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // ── Layer 2: UI controls ─────────────────────────────────────
              SafeArea(
                child: Column(children: [
                  _TopBar(
                    topicTitle: widget.topicTitle,
                    onClose: _confirmEnd,
                    isParadise: isParadise,
                  ),
                  const Spacer(),
                  _ControlsBar(
                    onStart: _startCountdown,
                    onEnd: _confirmEnd,
                    isParadise: isParadise,
                  ),
                  const SizedBox(height: 28),
                ]),
              ),

              // ── Layer 3: Countdown ───────────────────────────────────────
              if (_counting)
                _CountdownOverlay(count: _countdown, isParadise: isParadise),

              // ── Layer 4: Analyzing overlay ───────────────────────────────
              if (p.analyzing) _AnalyzingOverlay(isParadise: isParadise),
            ],
          ),
        );
      }),
    );
  }
}

// ── Camera layer ──────────────────────────────────────────────────────────────
class _CameraLayer extends StatelessWidget {
  final CameraController? controller;
  final bool isReady, isDenied, isParadise;
  const _CameraLayer({
    required this.controller,
    required this.isReady,
    required this.isDenied,
    required this.isParadise,
  });

  @override
  Widget build(BuildContext context) {
    if (isDenied) {
      return Container(
        color: const Color(0xFF111111),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.videocam_off_outlined,
                color: isParadise ? _pOrange : Colors.white24, size: 40),
            const SizedBox(height: 12),
            Text(AppStrings.cameraUnavailable,
                style: TextStyle(
                    color: isParadise ? _pCream : Colors.white24, fontSize: 12),
                textAlign: TextAlign.center),
          ]),
        ),
      );
    }
    if (!isReady || controller == null) {
      return ColoredBox(
        color: const Color(0xFF111111),
        child: Center(
            child: CircularProgressIndicator(
                color: isParadise ? _pYellow : Colors.white24,
                strokeWidth: 1.5)),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller!.value.previewSize?.height ?? 1,
          height: controller!.value.previewSize?.width ?? 1,
          child: CameraPreview(controller!),
        ),
      ),
    );
  }
}

// ── Floating Top bar ──────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String topicTitle;
  final VoidCallback onClose;
  final bool isParadise;

  const _TopBar(
      {required this.topicTitle,
      required this.onClose,
      required this.isParadise});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PracticeProvider>();
    final tt = context.tt;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isParadise ? _pBrown.withOpacity(0.5) : Colors.black45,
          borderRadius: BorderRadius.circular(50),
          border: isParadise
              ? Border.all(color: _pOrange.withOpacity(0.5), width: 1.0)
              : Border.all(color: Colors.white12, width: 1.0),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color:
                      isParadise ? _pWhite.withOpacity(0.15) : Colors.white24,
                  shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(topicTitle,
                style: isParadise
                    ? GoogleFonts.playfairDisplay(
                        color: _pCream,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic)
                    : tt.labelMedium?.copyWith(
                        color: Colors.white,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 10),
          _Pill(
            bg: p.recording
                ? (isParadise ? _pFuchsia : Colors.white)
                : (isParadise ? _pWhite.withOpacity(0.15) : Colors.white24),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (p.recording) ...[
                Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: isParadise ? _pWhite : Colors.red,
                        shape: BoxShape.circle)),
                const SizedBox(width: 5),
              ],
              Text(p.timer,
                  style: isParadise
                      ? GoogleFonts.oswald(
                          color: p.recording ? _pWhite : _pCream,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0)
                      : TextStyle(
                          color: p.recording ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 6),
          _Pill(
            bg: p.fillers > 5
                ? (isParadise ? _pOrange : Colors.red.withAlpha(200))
                : (isParadise ? _pWhite.withOpacity(0.15) : Colors.white24),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                  isParadise
                      ? Icons.warning_amber_rounded
                      : Icons.water_drop_outlined,
                  size: 12,
                  color: isParadise ? _pWhite : Colors.white),
              const SizedBox(width: 4),
              Text('${p.fillers}',
                  style: isParadise
                      ? GoogleFonts.oswald(
                          color: _pWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)
                      : const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;
  final Color bg;
  const _Pill({required this.child, required this.bg});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(50)),
        child: child,
      );
}

// ── Controls bar ──────────────────────────────────────────────────────────────
class _ControlsBar extends StatelessWidget {
  final VoidCallback onStart, onEnd;
  final bool isParadise;

  const _ControlsBar(
      {required this.onStart, required this.onEnd, required this.isParadise});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PracticeProvider>();
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (!p.recording)
        _Btn(
          label: 'Start Recording',
          icon: Icons.mic_rounded,
          bg: isParadise ? _pYellow : Colors.white,
          fg: isParadise ? _pBrown : Colors.black,
          isParadise: isParadise,
          onTap: onStart,
        )
      else if (p.paused) ...[
        _Btn(
          label: AppStrings.practiceResume,
          icon: Icons.play_arrow_rounded,
          bg: isParadise ? _pYellow : Colors.white,
          fg: isParadise ? _pBrown : Colors.black,
          isParadise: isParadise,
          onTap: () {
            context.read<PracticeProvider>().resume();
            HapticService.instance.medium();
          },
        ),
        const SizedBox(width: 12),
        _Btn(
          label: AppStrings.practiceFinish,
          icon: Icons.stop_rounded,
          bg: isParadise ? _pFuchsia : Colors.red,
          fg: Colors.white,
          isParadise: isParadise,
          onTap: onEnd,
        ),
      ] else ...[
        GestureDetector(
          onTap: () {
            context.read<PracticeProvider>().pause();
            HapticService.instance.medium();
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: isParadise ? _pWhite.withOpacity(0.2) : Colors.white24,
                shape: BoxShape.circle,
                border: isParadise
                    ? Border.all(color: _pCream.withOpacity(0.5))
                    : null),
            child:
                const Icon(Icons.pause_rounded, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 16),
        _Btn(
          label: AppStrings.practiceStop,
          icon: Icons.stop_circle_rounded,
          bg: isParadise ? _pFuchsia : Colors.red,
          fg: Colors.white,
          isParadise: isParadise,
          onTap: onEnd,
        ),
      ],
    ]);
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg, fg;
  final VoidCallback onTap;
  final bool isParadise;

  const _Btn({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
    required this.isParadise,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                  color: bg.withAlpha(80),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: isParadise
                    ? GoogleFonts.oswald(
                        color: fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0)
                    : TextStyle(
                        color: fg, fontSize: 14, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

// ── Countdown overlay ─────────────────────────────────────────────────────────
class _CountdownOverlay extends StatelessWidget {
  final int count;
  final bool isParadise;
  const _CountdownOverlay({required this.count, required this.isParadise});

  @override
  Widget build(BuildContext context) => Container(
        color: isParadise ? _pBrown.withOpacity(0.8) : Colors.black54,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$count',
                style: isParadise
                    ? GoogleFonts.oswald(
                        color: _pYellow,
                        fontSize: 120,
                        fontWeight: FontWeight.w700,
                        height: 1.0)
                    : const TextStyle(
                        color: Colors.white,
                        fontSize: 96,
                        fontWeight: FontWeight.w900,
                        height: 1.0)),
            const SizedBox(height: 14),
            Text(AppStrings.practiceCountdown,
                style: isParadise
                    ? GoogleFonts.nunito(
                        color: _pCream,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600)
                    : const TextStyle(color: Colors.white54, fontSize: 16)),
          ]),
        ),
      );
}

// ── Analyzing Overlay ─────────────────────────────────────────────────────────
class _AnalyzingOverlay extends StatelessWidget {
  final bool isParadise;
  const _AnalyzingOverlay({required this.isParadise});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isParadise ? _pTurquoise.withOpacity(0.9) : Colors.black87,
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (isParadise)
            const Icon(Icons.spa_rounded, color: _pCream, size: 32),
          if (isParadise) const SizedBox(height: 24),
          CircularProgressIndicator(
            color: isParadise ? _pYellow : Colors.white,
            strokeWidth: 3.0,
          ),
          const SizedBox(height: 24),
          Text('Analyzing your session…',
              style: isParadise
                  ? GoogleFonts.playfairDisplay(
                      color: _pBrown,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic)
                  : const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('This may take up to a minute.',
              style: isParadise
                  ? GoogleFonts.nunito(
                      color: _pBrown.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)
                  : const TextStyle(color: Colors.white38, fontSize: 12)),
        ]),
      ),
    );
  }
}

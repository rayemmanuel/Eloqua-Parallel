import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/strings.dart';
import '../../core/services/api_service.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/theme/theme_manager_ext.dart';
import '../practice/practice_screen.dart';

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
class PrepProvider extends ChangeNotifier {
  String? _fileName;
  File? _file;
  bool _loading = false;
  String? _error;
  List<String> _points = [];
  String _summary = '';
  List<BubbleData> _bubbles = [];

  String? get fileName => _fileName;
  bool get loading => _loading;
  String? get error => _error;
  List<String> get points => _points;
  String get summary => _summary;
  List<BubbleData> get bubbles => _bubbles;
  bool get hasFile => _file != null;
  bool get hasPoints => _points.isNotEmpty;

  final _pdf = PdfService.instance;

  Future<void> pickFile() async {
    _error = null;
    notifyListeners();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'pptx'],
    );
    if (result == null || result.files.isEmpty) return;

    final f = result.files.first;
    if (f.size > 10 * 1024 * 1024) {
      _error = AppStrings.errorFileTooBig;
      notifyListeners();
      return;
    }

    _fileName = f.name;
    _file = f.path != null ? File(f.path!) : null;
    _points = [];
    _summary = '';
    _bubbles = [];
    notifyListeners();
  }

  Future<void> generate() async {
    if (_file == null) return;
    _loading = true;
    _error = null;
    notifyListeners();

    // 1. Send file to backend POST /upload-document
    //    Backend uses Gemini to extract talking points — no OpenAI key needed.
    final apiResult = await ApiService.instance.uploadDocument(_file!);

    if (!apiResult.success) {
      // Backend failed — fall back to local PDF extraction for concept bubbles
      // but show the error so the user knows talking points aren't AI-generated.
      _error = apiResult.error ?? AppStrings.errorGeneric;

      // Still extract concept bubbles locally for a partial experience
      if (_fileName?.endsWith('.pdf') == true) {
        _bubbles = await _pdf.extractBubbles(_file!.path);
      }

      _loading = false;
      notifyListeners();
      return;
    }

    final doc = apiResult.data!;
    _points = doc.talkingPoints;
    _summary = doc.title;

    // 2. Build concept bubbles from talking points
    _bubbles = _points
        .asMap()
        .entries
        .map((e) => BubbleData(text: e.value, index: e.key))
        .toList();

    _loading = false;
    notifyListeners();
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class PrepScreen extends StatelessWidget {
  const PrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrepProvider(),
      child: const _PrepBody(),
    );
  }
}

class _PrepBody extends StatelessWidget {
  const _PrepBody();

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;
    final p = context.watch<PrepProvider>();

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.prepUploadTitle,
                      style: isParadise
                          ? GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: _pBrown,
                              height: 1.1)
                          : tt.headlineMedium?.copyWith(
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Upload a PDF, DOCX, or PPTX file. '
                      'Our AI will extract key talking points for your practice session.',
                      style: isParadise
                          ? GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: _pBrown.withOpacity(0.8),
                              height: 1.5)
                          : tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),

                    // ── Upload zone ──────────────────────────────────────────────────
                    GestureDetector(
                      onTap: () {
                        HapticService.instance.light();
                        context.read<PrepProvider>().pickFile();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 36, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isParadise ? _pCream : cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: p.hasFile
                                ? (isParadise ? _pFuchsia : cs.primary)
                                : (isParadise
                                    ? _pOrange.withOpacity(0.3)
                                    : cs.outlineVariant),
                            width: p.hasFile ? 2 : 1.5,
                          ),
                          boxShadow: (isParadise && p.hasFile)
                              ? [
                                  BoxShadow(
                                      color: _pFuchsia.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4))
                                ]
                              : null,
                        ),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                            p.hasFile
                                ? Icons.check_circle_rounded
                                : (isParadise
                                    ? Icons.folder_open_rounded
                                    : Icons.upload_file_rounded),
                            size: 48,
                            color: p.hasFile
                                ? (isParadise ? _pFuchsia : cs.primary)
                                : (isParadise
                                    ? _pOrange.withOpacity(0.5)
                                    : cs.onSurfaceVariant.withOpacity(0.4)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            p.hasFile
                                ? (p.fileName ?? 'File selected')
                                : 'Choose a PDF, DOCX, or PPTX file',
                            textAlign: TextAlign.center,
                            style: isParadise
                                ? GoogleFonts.oswald(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: p.hasFile
                                        ? _pBrown
                                        : _pBrown.withOpacity(0.6),
                                    letterSpacing: 0.5)
                                : tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: p.hasFile
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant),
                          ),
                          if (p.hasFile) ...[
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.prepChangeFile,
                              style: isParadise
                                  ? GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: _pOrange)
                                  : tt.labelSmall?.copyWith(color: cs.primary),
                            ),
                          ],
                        ]),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Generate button ──────────────────────────────────────────────
                    if (p.hasFile && !p.hasPoints)
                      _ActionButton(
                        icon: Icons.auto_awesome_rounded,
                        label: p.loading
                            ? AppStrings.prepGenerating
                            : AppStrings.prepGenerateBtn,
                        isLoading: p.loading,
                        onTap: p.loading
                            ? null
                            : () => context.read<PrepProvider>().generate(),
                      ),

                    // ── Error ────────────────────────────────────────────────────────
                    if (p.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isParadise
                              ? _pFuchsia.withOpacity(0.1)
                              : cs.errorContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isParadise
                                ? _pFuchsia.withOpacity(0.4)
                                : cs.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(children: [
                          Icon(Icons.error_outline_rounded,
                              color: isParadise ? _pFuchsia : cs.error,
                              size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(p.error!,
                                  style: TextStyle(
                                    color: isParadise ? _pFuchsia : cs.error,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ))),
                        ]),
                      ),
                    ],

                    // ── Concept bubbles (shown while loading or before points) ───────
                    if (p.bubbles.isNotEmpty && !p.hasPoints) ...[
                      const SizedBox(height: 32),
                      const _SectionLabel('Extracted Concepts'),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: p.bubbles
                            .map((b) => _BubbleChip(text: b.text))
                            .toList(),
                      ),
                    ],

                    // ── Talking points ───────────────────────────────────────────────
                    if (p.hasPoints) ...[
                      const SizedBox(height: 32),

                      // Summary card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isParadise
                              ? _pTurquoise.withOpacity(0.12)
                              : cs.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isParadise
                                  ? _pTurquoise.withOpacity(0.4)
                                  : cs.primaryContainer),
                        ),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb_outline_rounded,
                                  color: isParadise ? _pTurquoise : cs.primary,
                                  size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(p.summary,
                                      style: isParadise
                                          ? GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: _pBrown,
                                              height: 1.5)
                                          : tt.bodyMedium?.copyWith(
                                              color: cs.onSurface,
                                              height: 1.5))),
                            ]),
                      ),

                      const SizedBox(height: 28),

                      _SectionLabel(AppStrings.prepPointsTitle),
                      const SizedBox(height: 6),
                      Text(AppStrings.prepPointsHint,
                          style: isParadise
                              ? GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: _pBrown.withOpacity(0.7))
                              : tt.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 16),

                      ...p.points.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isParadise ? _pWhite : cs.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: isParadise
                                    ? Border.all(
                                        color: _pOrange.withOpacity(0.3),
                                        width: 1.5)
                                    : Border.all(color: cs.outlineVariant),
                                boxShadow: isParadise
                                    ? [
                                        BoxShadow(
                                            color: _pBrown.withOpacity(0.04),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4))
                                      ]
                                    : [
                                        BoxShadow(
                                            color: cs.shadow.withOpacity(0.02),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2))
                                      ],
                              ),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      margin: const EdgeInsets.only(right: 14),
                                      decoration: BoxDecoration(
                                          color: isParadise
                                              ? _pFuchsia
                                              : cs.primary,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Center(
                                          child: Text('${e.key + 1}',
                                              style: isParadise
                                                  ? GoogleFonts.oswald(
                                                      color: _pWhite,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700)
                                                  : TextStyle(
                                                      color: cs.onPrimary,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800))),
                                    ),
                                    Expanded(
                                        child: Text(e.value,
                                            style: isParadise
                                                ? GoogleFonts.nunito(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: _pBrown,
                                                    height: 1.4)
                                                : tt.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.4))),
                                  ]),
                            ),
                          )),

                      const SizedBox(height: 32),

                      _ActionButton(
                        icon: Icons.mic_rounded,
                        label: AppStrings.prepStartBtn,
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => PracticeScreen(
                              talkingPoints: p.points,
                              topicTitle: p.summary,
                              mode: 'preparation',
                            ),
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(
                              opacity: CurvedAnimation(
                                  parent: anim, curve: Curves.easeInOut),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 48),
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
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 14),
      decoration: isParadise
          ? BoxDecoration(
              color: _pFuchsia,
              boxShadow: [
                BoxShadow(
                    color: _pBrown.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 6)),
                BoxShadow(
                    color: _pFuchsia.withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 10)),
              ],
            )
          : BoxDecoration(
              color: cs.primary,
              boxShadow: [
                BoxShadow(
                    color: cs.shadow.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 6)),
              ],
            ),
      child: Row(children: [
        GestureDetector(
          onTap: () {
            HapticService.instance.light();
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.transparent,
            child: Icon(Icons.arrow_back_ios_rounded,
                size: 20, color: isParadise ? _pWhite : cs.onPrimary),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(AppStrings.prepTitle.toUpperCase(),
              style: isParadise
                  ? GoogleFonts.oswald(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _pWhite,
                      letterSpacing: 2.5,
                    )
                  : tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onPrimary,
                      letterSpacing: 2.0)),
        ),
        if (isParadise) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_florist_rounded, color: _pCream, size: 16),
              const SizedBox(width: 4),
              Icon(Icons.spa_rounded, color: _pYellow, size: 20),
            ],
          ),
        ]
      ]),
    );
  }
}

// ── SECTION LABEL (Properly toggling elements based on theme) ─────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;

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

    // Default theme: Clean Georgia text AND dashed lines, NO dot, NO flower.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: tt.titleMedium?.copyWith(
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w700,
                color: cs.onSurface)),
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

// ── CUSTOM ACTION BUTTON ──────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.watchThemeManager.isParadise;

    final bgColor = isParadise ? _pYellow : cs.primary;
    final fgColor = isParadise ? _pBrown : cs.onPrimary;

    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticService.instance.medium();
              onTap!();
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: onTap == null ? bgColor.withOpacity(0.5) : bgColor,
          borderRadius: BorderRadius.circular(100),
          border: isParadise
              ? Border.all(color: _pBrown.withOpacity(0.15), width: 1.0)
              : null,
          boxShadow: (isParadise && onTap != null)
              ? [
                  BoxShadow(
                      color: _pBrown.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: fgColor))
            else
              Icon(icon, color: fgColor, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: isParadise
                  ? GoogleFonts.oswald(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: fgColor,
                      letterSpacing: 2.0)
                  : tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: fgColor,
                      letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

// ── BUBBLE CHIP ───────────────────────────────────────────────────────────────
class _BubbleChip extends StatelessWidget {
  final String text;
  const _BubbleChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isParadise = context.watchThemeManager.isParadise;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isParadise ? _pFuchsia : cs.secondaryContainer,
        borderRadius: BorderRadius.circular(50),
        border: isParadise ? Border.all(color: _pBrown.withOpacity(0.2)) : null,
        boxShadow: isParadise
            ? [
                BoxShadow(
                    color: _pFuchsia.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ]
            : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.circle,
            size: 6,
            color: isParadise
                ? _pWhite.withOpacity(0.6)
                : cs.onSecondaryContainer.withOpacity(0.5)),
        const SizedBox(width: 8),
        Text(text,
            style: isParadise
                ? GoogleFonts.barlowCondensed(
                    color: _pWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)
                : TextStyle(
                    color: cs.onSecondaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

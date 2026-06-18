import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/strings.dart';
import '../../core/services/api_service.dart';
import '../../core/services/haptic_service.dart';
import '../practice/practice_screen.dart';
import '../../core/theme/theme_manager_ext.dart';

// Fallback topics used when the backend is unreachable.
const _fallbackTopics = {
  'Foundational': [
    'Why is reading regularly important for students?',
    'What are the benefits of physical exercise?',
    'Describe your ideal study environment.',
    'Why is time management important in college?',
    'What makes a good team leader?',
    'Explain the importance of financial literacy.',
  ],
  'Intermediate': [
    'How does social media affect mental health in students?',
    'Should artificial intelligence be used in education?',
    'What is the impact of climate change on the economy?',
    'Discuss the role of critical thinking in problem-solving.',
    'How does poverty affect access to quality education?',
    'Should college education be free for all students?',
  ],
  'Advanced': [
    'Analyze the sociopolitical impact of misinformation in democratic societies.',
    'How does cognitive bias affect decision-making in organizations?',
    'Evaluate the long-term consequences of automation on labor markets.',
    'Discuss the philosophical tension between free will and determinism.',
    'How should governments balance privacy rights with national security?',
    'Critique the effectiveness of international climate agreements.',
  ],
};

const _diffMap = {
  'Foundational': 'foundational',
  'Intermediate': 'intermediate',
  'Advanced': 'advanced',
};

// ── IDEA framework talking points ─────────────────────────────────────────────
List<String> _ideaTalkingPoints(String topic) => [
      'Introduction: Open with a strong statement or hook about "$topic".',
      'Definition: Define the key concept or term at the heart of "$topic".',
      'Example: Give a concrete, real-world example that illustrates your point.',
      'Analysis: Explain the significance and draw a meaningful conclusion.',
    ];

class SpontScreen extends StatefulWidget {
  const SpontScreen({super.key});
  @override
  State<SpontScreen> createState() => _SpontScreenState();
}

class _SpontScreenState extends State<SpontScreen>
    with SingleTickerProviderStateMixin {
  String _difficulty = 'Intermediate';
  String _topic = '';
  bool _loading = false;
  bool _offline = false;

  final _customController = TextEditingController();
  bool _usingCustomTopic = false;

  late FixedExtentScrollController _wheelCtrl;
  final _rand = Random();
  late AnimationController _pulseCtrl;
  int _selectedWheelIndex = 0;

  List<String> _currentWheelTopics = [];

  @override
  void initState() {
    super.initState();
    _currentWheelTopics = List.from(_fallbackTopics[_difficulty]!);
    _wheelCtrl = FixedExtentScrollController(initialItem: _rand.nextInt(100));
    _selectedWheelIndex = _wheelCtrl.initialItem;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fetchTopic();
  }

  @override
  void dispose() {
    _customController.dispose();
    _wheelCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchTopic({int? targetIndex}) async {
    if (_usingCustomTopic && _customController.text.trim().isNotEmpty) return;

    setState(() {
      _loading = true;
      _offline = false;
    });

    final result = await ApiService.instance.getPrompt(
      category: 'academic',
      difficulty: _diffMap[_difficulty]!,
    );

    if (!mounted) return;

    final index = targetIndex ?? _wheelCtrl.selectedItem;

    if (result.success) {
      setState(() {
        _topic = result.data!.prompt;
        _loading = false;
        _offline = false;
        _currentWheelTopics[index % _currentWheelTopics.length] = _topic;
      });
    } else {
      setState(() {
        _topic = _currentWheelTopics[index % _currentWheelTopics.length];
        _loading = false;
        _offline = true;
      });
    }
  }

  void _spin() {
    HapticFeedback.mediumImpact();
    final nextIndex = _wheelCtrl.selectedItem + _rand.nextInt(10) + 5;
    _wheelCtrl.animateToItem(
      nextIndex,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
    _fetchTopic(targetIndex: nextIndex);
  }

  List<String> get _talkingPoints {
    final topic = _usingCustomTopic ? _customController.text.trim() : _topic;
    return _ideaTalkingPoints(topic);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final isParadise = context.isParadise;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(AppStrings.spontTitle, style: tt.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── OFFLINE BANNER ──────────────────────────────────────────────
              if (_offline)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cs.error),
                    ),
                    child: Row(children: [
                      Icon(Icons.wifi_off,
                          size: 14, color: cs.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Using offline topics — backend unreachable.',
                          style: TextStyle(
                              fontSize: 12, color: cs.onErrorContainer),
                        ),
                      ),
                    ]),
                  ),
                ),

              // ── HEADER ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MODE · SPONTANEOUS',
                      style: isParadise
                          ? GoogleFonts.oswald(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                              color: cs.tertiary,
                            )
                          : tt.labelSmall?.copyWith(
                              letterSpacing: 1.5,
                              color: cs.onSurfaceVariant,
                            ),
                    ),
                    const SizedBox(height: 8),
                    if (isParadise)
                      Text(
                        'Let the\nrhythm guide\nyou.',
                        style: GoogleFonts.sacramento(
                          fontSize: 48,
                          color: cs.primary,
                          letterSpacing: 1.0,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      Text(
                        'Let the rhythm\nguide you.',
                        style: tt.headlineLarge?.copyWith(
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      'Sharpen your wit with unrehearsed challenges.',
                      style: isParadise
                          ? GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: cs.secondary,
                              height: 1.5,
                            )
                          : tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── DIFFICULTY TABS ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: ['Foundational', 'Intermediate', 'Advanced']
                      .map((d) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _DifficultyTab(
                              label: d,
                              isSelected: _difficulty == d,
                              isParadise: isParadise,
                              onTap: () {
                                HapticService.instance.selection();
                                setState(() {
                                  _difficulty = d;
                                  _currentWheelTopics =
                                      List.from(_fallbackTopics[d]!);
                                });
                                _spin();
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 24),

              if (!isParadise)
                Divider(
                  color: cs.outline.withOpacity(0.1),
                  indent: 24,
                  endIndent: 24,
                ),
              const SizedBox(height: 20),

              // ── SECTION LABEL & SPIN BUTTON ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Wrapped in Expanded to prevent overflow pushing the spin button out
                    Expanded(
                      child: isParadise
                          ? const _ParadiseSectionLabel('Topic of the Moment')
                          : Text(
                              'TOPIC OF THE MOMENT',
                              style:
                                  tt.labelSmall?.copyWith(letterSpacing: 1.2),
                            ),
                    ),
                    const SizedBox(width: 8),
                    _SpinButton(
                      isParadise: isParadise,
                      onTap: _loading ? () {} : _spin,
                      isLoading: _loading,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── TOPIC WHEEL ─────────────────────────────────────────────────
              Opacity(
                opacity: _usingCustomTopic ? 0.3 : 1.0,
                child: IgnorePointer(
                  ignoring: _usingCustomTopic,
                  child: _TopicWheelSection(
                    topics: _currentWheelTopics,
                    controller: _wheelCtrl,
                    isParadise: isParadise,
                    onSelected: (index) {
                      if (_selectedWheelIndex != index) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedWheelIndex = index;
                          _topic = _currentWheelTopics[
                              index % _currentWheelTopics.length];
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── CUSTOM TOPIC INPUT ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          'Or enter your own topic',
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_usingCustomTopic)
                        TextButton(
                          onPressed: () {
                            _customController.clear();
                            setState(() => _usingCustomTopic = false);
                            _fetchTopic();
                          },
                          child: Text('Use wheel',
                              style:
                                  TextStyle(fontSize: 12, color: cs.primary)),
                        ),
                    ]),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      style: tt.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'e.g. The future of renewable energy...',
                        hintStyle: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant.withOpacity(0.5)),
                        filled: true,
                        fillColor: cs.surfaceVariant.withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: cs.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: cs.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: cs.primary, width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        final trimmed = val.trim();
                        if (trimmed.isEmpty) {
                          setState(() => _usingCustomTopic = false);
                          _fetchTopic();
                        } else {
                          setState(() {
                            _usingCustomTopic = true;
                            _topic = trimmed;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── IDEA MODEL FOLDER ───────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: _IdeaFrameworkFolder(),
              ),

              const SizedBox(height: 24),

              // ── META ROW (SINGLE LINE HORIZONTAL SCROLL) ────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _MetaPill(
                        icon: Icons.timer_outlined,
                        label: '2 min prep',
                        isParadise: isParadise,
                      ),
                      const SizedBox(width: 8),
                      _MetaPill(
                        icon: Icons.mic_none_rounded,
                        label: '5 min talk',
                        isParadise: isParadise,
                      ),
                      const SizedBox(width: 8),
                      _MetaPill(
                        icon: Icons.lightbulb_outline_rounded,
                        label: 'IDEA Framework',
                        isParadise: isParadise,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── CTA BUTTON ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ||
                            (_usingCustomTopic
                                ? _customController.text.trim().isEmpty
                                : _topic.isEmpty)
                        ? null
                        : () {
                            HapticService.instance.medium();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => PracticeScreen(
                                  topicTitle: _usingCustomTopic
                                      ? _customController.text.trim()
                                      : _topic,
                                  talkingPoints: _talkingPoints,
                                  mode: 'spontaneous',
                                  framework: 'IDEA',
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
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: isParadise ? 8 : 0,
                      shadowColor:
                          isParadise ? cs.primary.withOpacity(0.4) : null,
                    ),
                    child: _loading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: cs.onPrimary, strokeWidth: 2))
                        : Text(
                            AppStrings.spontStartBtn,
                            style: isParadise
                                ? GoogleFonts.oswald(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: cs.onPrimary,
                                  )
                                : const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIFFICULTY TAB
// ─────────────────────────────────────────────────────────────────────────────

class _DifficultyTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isParadise;
  final VoidCallback onTap;

  const _DifficultyTab({
    required this.label,
    required this.isSelected,
    required this.isParadise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceVariant,
          borderRadius: BorderRadius.circular(100),
          border: isParadise && isSelected
              ? Border.all(color: cs.secondary, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPIN BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _SpinButton extends StatelessWidget {
  final bool isParadise;
  final VoidCallback onTap;
  final bool isLoading;

  const _SpinButton({
    required this.isParadise,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    color: context.cs.primary, strokeWidth: 2))
          else
            Icon(
              Icons.refresh_rounded,
              size: 14,
              color: context.cs.primary,
            ),
          const SizedBox(width: 4),
          Text(
            'Spin for New Topic',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOPIC WHEEL SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _TopicWheelSection extends StatelessWidget {
  final List<String> topics;
  final FixedExtentScrollController controller;
  final bool isParadise;
  final ValueChanged<int> onSelected;

  const _TopicWheelSection({
    required this.topics,
    required this.controller,
    required this.isParadise,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 24,
            right: 24,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isParadise
                      ? cs.secondary.withOpacity(0.3)
                      : cs.primary.withOpacity(0.15),
                  width: isParadise ? 2.0 : 1.0,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [cs.surface, cs.surface.withOpacity(0)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [cs.surface, cs.surface.withOpacity(0)],
                  ),
                ),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 100,
            perspective: 0.003,
            diameterRatio: 2.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelected,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final topic = topics[index % topics.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Center(
                    child: Text(
                      topic,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: isParadise
                          ? GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                              height: 1.3,
                            )
                          : context.tt.titleMedium?.copyWith(
                              fontFamily: 'Georgia',
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// META PILL
// ─────────────────────────────────────────────────────────────────────────────

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isParadise;

  const _MetaPill({
    required this.icon,
    required this.label,
    this.isParadise = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
        border: isParadise
            ? Border.all(color: cs.tertiary.withOpacity(0.3), width: 1.0)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isParadise ? cs.tertiary : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isParadise ? cs.tertiary : cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARADISE SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _ParadiseSectionLabel extends StatelessWidget {
  final String label;
  const _ParadiseSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: cs.primary,
            shape: BoxShape.circle,
          ),
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
        Flexible(
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
        Icon(Icons.spa_rounded, color: cs.secondary, size: 12),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IDEA FRAMEWORK ADVISORY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _IdeaFrameworkFolder extends StatelessWidget {
  const _IdeaFrameworkFolder();

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.04), // Very subtle background tint
        borderRadius: BorderRadius.circular(20), // Slightly smaller radius
        border: Border.all(
            color: cs.primary.withOpacity(0.15),
            width: 1.5), // Softer, thinner border
        // Removed the heavy drop shadow to flatten it into the background
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Clean, uniform padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overline to establish it as a helper/advisory section
            Text('ADVISORY · IDEA FRAMEWORK',
                style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                    letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(
                'A structured approach to spontaneous speaking. Use this mental model to organize your thoughts on the fly.',
                style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                    height: 1.5)),
            const SizedBox(height: 16),

            // I.D.E.A Blocks (Slightly shrunk down to match the advisory scale)
            Row(
              children: [
                ['I', 'Intro'],
                ['D', 'Define'],
                ['E', 'Example'],
                ['A', 'Analyze'],
              ].map((item) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: cs.outlineVariant.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            item[0],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item[1],
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

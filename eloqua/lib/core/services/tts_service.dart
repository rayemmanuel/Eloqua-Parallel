import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Why: wrapping FlutterTts in a service means screens never touch the TTS
// engine directly — just call speak(), and settings are applied automatically.

class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  double _pitch    = 1.0;  // Range: 0.5 (deep) → 2.0 (high)
  double _rate     = 0.5;  // Range: 0.0 (slow) → 1.0 (fast)
  String _language = 'en-US';
  bool   _speaking = false;
  bool   _enabled  = true;

  double get pitch    => _pitch;
  double get rate     => _rate;
  String get language => _language;
  bool   get speaking => _speaking;
  bool   get enabled  => _enabled;

  // Available languages for the picker
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en-US', 'label': 'English (US)'},
    {'code': 'en-GB', 'label': 'English (UK)'},
    {'code': 'fil-PH', 'label': 'Filipino'},
    {'code': 'es-ES', 'label': 'Spanish'},
    {'code': 'fr-FR', 'label': 'French'},
    {'code': 'ja-JP', 'label': 'Japanese'},
  ];

  TtsService() {
    _init();
  }

  Future<void> _init() async {
    await _tts.setLanguage(_language);
    await _tts.setPitch(_pitch);
    await _tts.setSpeechRate(_rate);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      _speaking = true;
      notifyListeners();
    });
    _tts.setCompletionHandler(() {
      _speaking = false;
      notifyListeners();
    });
    _tts.setErrorHandler((_) {
      _speaking = false;
      notifyListeners();
    });
  }

  // ── Speak ─────────────────────────────────────────────────────────────────
  Future<void> speak(String text) async {
    if (!_enabled || text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  // ── Stop ──────────────────────────────────────────────────────────────────
  Future<void> stop() async {
    await _tts.stop();
    _speaking = false;
    notifyListeners();
  }

  // ── Shortcut: read feedback score aloud ───────────────────────────────────
  Future<void> readFeedback({
    required int overall,
    required int clarity,
    required int pacing,
    required int grammar,
    required int confidence,
    required String coachNote,
  }) async {
    final text = 'Your overall score is $overall out of 100. '
        'Clarity: $clarity. Pacing: $pacing. Grammar: $grammar. Confidence: $confidence. '
        'Coach note: $coachNote';
    await speak(text);
  }

  // ── Goodbye ───────────────────────────────────────────────────────────────
  Future<void> sayGoodbye(String name) async {
    await speak('Goodbye $name. Keep practicing!');
  }

  // ── Gesture summary for accessibility ────────────────────────────────────
  Future<void> readGestureSummary() async {
    await speak(
      'Available gestures: '
      'Swipe left to go to Settings. '
      'Swipe up to start a session. '
      'Swipe right to go back. '
      'Double tap to toggle theme. '
      'Long press here to repeat this summary.',
    );
  }

  // ── Settings ──────────────────────────────────────────────────────────────
  Future<void> setPitch(double value) async {
    _pitch = value.clamp(0.5, 2.0);
    await _tts.setPitch(_pitch);
    notifyListeners();
  }

  Future<void> setRate(double value) async {
    _rate = value.clamp(0.1, 1.0);
    await _tts.setSpeechRate(_rate);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _language = code;
    await _tts.setLanguage(code);
    notifyListeners();
    // Confirm the change with a short spoken sample
    await speak('Language set.');
  }

  void setEnabled(bool value) {
    _enabled = value;
    if (!value) _tts.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
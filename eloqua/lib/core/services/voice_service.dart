import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

// Why: voice commands let users navigate hands-free while standing to practice.
// Foundation: SpeechToText listens for keywords then triggers callbacks.

// Recognized command keywords mapped to actions
enum VoiceCommand {
  startRecording,   // "start", "begin", "go"
  stopRecording,    // "stop", "end", "finish"
  pauseRecording,   // "pause", "wait"
  resumeRecording,  // "resume", "continue"
  openSettings,     // "settings", "options"
  openPrep,         // "preparation", "document", "upload"
  openSpontaneous,  // "spontaneous", "random", "topic"
  goHome,           // "home", "back", "menu"
  unknown,
}

class VoiceService extends ChangeNotifier {
  final SpeechToText _stt = SpeechToText();

  bool   _available   = false;
  bool   _listening   = false;
  String _lastWords   = '';
  String _statusMsg   = 'Not initialized';

  bool   get available  => _available;
  bool   get listening  => _listening;
  String get lastWords  => _lastWords;
  String get statusMsg  => _statusMsg;

  // Callback triggered when a recognized command is detected
  void Function(VoiceCommand)? onCommand;

  Future<void> init() async {
    _available = await _stt.initialize(
      onStatus: _onStatus,
      onError:  _onError,
    );
    _statusMsg = _available ? 'Ready' : 'Microphone unavailable';
    notifyListeners();
  }

  // ── Start listening ────────────────────────────────────────────────────────
  Future<void> startListening() async {
    if (!_available || _listening) return;

    await _stt.listen(
      onResult: _onResult,
      listenFor:    const Duration(seconds: 10),
      pauseFor:     const Duration(seconds: 3),
      partialResults: true,
      localeId:     'en_US',
    );

    _listening = true;
    _statusMsg = 'Listening...';
    notifyListeners();
  }

  // ── Stop listening ─────────────────────────────────────────────────────────
  Future<void> stopListening() async {
    await _stt.stop();
    _listening = false;
    _statusMsg = 'Stopped';
    notifyListeners();
  }

  void _onResult(dynamic result) {
    _lastWords = result.recognizedWords as String;
    notifyListeners();

    if (result.finalResult as bool) {
      final cmd = _parseCommand(_lastWords.toLowerCase());
      if (cmd != VoiceCommand.unknown && onCommand != null) {
        onCommand!(cmd);
      }
    }
  }

  void _onStatus(String status) {
    _statusMsg = status;
    if (status == 'done' || status == 'notListening') {
      _listening = false;
    }
    notifyListeners();
  }

  void _onError(dynamic error) {
    _listening = false;
    _statusMsg = 'Error: ${error.errorMsg}';
    notifyListeners();
  }

  // ── Keyword matching ───────────────────────────────────────────────────────
  VoiceCommand _parseCommand(String words) {
    if (_contains(words, ['start', 'begin', 'go']))            return VoiceCommand.startRecording;
    if (_contains(words, ['stop', 'end', 'finish']))           return VoiceCommand.stopRecording;
    if (_contains(words, ['pause', 'wait', 'hold']))           return VoiceCommand.pauseRecording;
    if (_contains(words, ['resume', 'continue', 'keep going'])) return VoiceCommand.resumeRecording;
    if (_contains(words, ['settings', 'options', 'config']))   return VoiceCommand.openSettings;
    if (_contains(words, ['preparation', 'document', 'upload', 'prepared'])) return VoiceCommand.openPrep;
    if (_contains(words, ['spontaneous', 'random', 'topic', 'impromptu']))   return VoiceCommand.openSpontaneous;
    if (_contains(words, ['home', 'menu', 'back', 'main']))    return VoiceCommand.goHome;
    return VoiceCommand.unknown;
  }

  bool _contains(String input, List<String> keywords) =>
      keywords.any((k) => input.contains(k));

  @override
  void dispose() {
    _stt.stop();
    super.dispose();
  }
}
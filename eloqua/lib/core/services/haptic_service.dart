import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

// Why: centralizing haptics means every screen uses the same patterns consistently.
// Foundation: haptic feedback is a form of non-visual confirmation for user actions.

class HapticService {
  HapticService._();
  static final HapticService instance = HapticService._();

  // Whether the device supports custom vibration patterns
  Future<bool> get _hasVibrator async => await Vibration.hasVibrator();

  // ── Tier 1: Light ─────────────────────────────────────────────────────────
  // Use for: filler word detected, scroll reached end, chip selected
  Future<void> light() async {
    HapticFeedback.lightImpact();
  }

  // ── Tier 2: Medium ────────────────────────────────────────────────────────
  // Use for: countdown tick, mode card tapped, button pressed
  Future<void> medium() async {
    HapticFeedback.mediumImpact();
  }

  // ── Tier 3: Strong ────────────────────────────────────────────────────────
  // Use for: recording started, session ended, major state change
  Future<void> strong() async {
    HapticFeedback.heavyImpact();
  }

  // ── Success pattern: two short pulses ────────────────────────────────────
  // Use for: talking points generated, file uploaded, session saved
  Future<void> success() async {
    if (await _hasVibrator) {
      Vibration.vibrate(pattern: [0, 80, 60, 80], intensities: [0, 128, 0, 255]);
    } else {
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      HapticFeedback.mediumImpact();
    }
  }

  // ── Error pattern: one long pulse ────────────────────────────────────────
  // Use for: permission denied, API error, file too large
  Future<void> error() async {
    if (await _hasVibrator) {
      Vibration.vibrate(duration: 300, amplitude: 200);
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  // ── Warning pattern: three quick taps ────────────────────────────────────
  // Use for: posture alert, filler jar overflow, pacing too fast
  Future<void> warning() async {
    if (await _hasVibrator) {
      Vibration.vibrate(pattern: [0, 50, 50, 50, 50, 50], intensities: [0, 180, 0, 180, 0, 180]);
    } else {
      for (int i = 0; i < 3; i++) {
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 80));
      }
    }
  }

  // ── Selection pattern: single crisp tick ─────────────────────────────────
  // Use for: difficulty chip selected, theme switched, toggle changed
  Future<void> selection() async {
    HapticFeedback.selectionClick();
  }
}
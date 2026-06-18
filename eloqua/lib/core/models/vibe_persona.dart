import 'package:flutter/material.dart';

class VibePersona {
  final String title;
  final IconData icon;

  const VibePersona._({required this.title, required this.icon});

  static const VibePersona thePractitioner = VibePersona._(
    title: 'The Practitioner',
    icon: Icons.auto_graph_rounded,
  );
  static const VibePersona theStoryteller = VibePersona._(
    title: 'The Storyteller',
    icon: Icons.menu_book_rounded,
  );
  static const VibePersona theDebater = VibePersona._(
    title: 'The Debater',
    icon: Icons.gavel_rounded,
  );
  static const VibePersona theCoach = VibePersona._(
    title: 'The Coach',
    icon: Icons.sports_rounded,
  );
  static const VibePersona theAnalyst = VibePersona._(
    title: 'The Analyst',
    icon: Icons.analytics_rounded,
  );
  static const VibePersona theRookie = VibePersona._(
    title: 'The Rookie',
    icon: Icons.star_outline_rounded,
  );

  factory VibePersona.fromScores({
    required int clarity,
    required int pacing,
    required int grammar,
    required int confidence,
  }) {
    final avg = (clarity + pacing + grammar + confidence) / 4;

    if (avg >= 88) return theCoach;
    if (grammar >= 88 && confidence >= 80) return theDebater;
    if (clarity >= 85 && pacing >= 80) return theStoryteller;
    if (avg >= 75) return theAnalyst;
    if (avg >= 60) return thePractitioner;
    return theRookie;
  }
}

import 'package:flutter/material.dart';

enum ThemeProfile {
  executiveDark,
  nordicLight,
  cyberneticMatrix,
  sereneFocus,
}

class SyncoraTheme {
  final ThemeProfile profile;
  final Color baseBackground;
  final Color panelBackground;
  final Color primaryAccent;
  final Color vectorLine;

  const SyncoraTheme._({
    required this.profile,
    required this.baseBackground,
    required this.panelBackground,
    required this.primaryAccent,
    required this.vectorLine,
  });

  factory SyncoraTheme.fromProfile(ThemeProfile profile) {
    switch (profile) {
      case ThemeProfile.executiveDark:
        return SyncoraTheme._(
          profile: profile,
          baseBackground: const Color(0xFF121820),
          panelBackground: const Color(0xFF1A232E).withValues(alpha: 0.60),
          primaryAccent: const Color(0xFF76C7A2),
          vectorLine: const Color(0xFF4A909B),
        );
      case ThemeProfile.nordicLight:
        return SyncoraTheme._(
          profile: profile,
          baseBackground: const Color(0xFFF5F7FA),
          panelBackground: const Color(0xFFFFFFFF).withValues(alpha: 0.75),
          primaryAccent: const Color(0xFF629A7D),
          vectorLine: const Color(0xFF333E48),
        );
      case ThemeProfile.cyberneticMatrix:
        return SyncoraTheme._(
          profile: profile,
          baseBackground: const Color(0xFF05070A),
          panelBackground: const Color(0xFF11161B).withValues(alpha: 1.0), // 100%
          primaryAccent: const Color(0xFFE5A93C),
          vectorLine: const Color(0xFF39FF14),
        );
      case ThemeProfile.sereneFocus:
        return SyncoraTheme._(
          profile: profile,
          baseBackground: const Color(0xFF1C1816),
          panelBackground: const Color(0xFF282320).withValues(alpha: 0.65),
          primaryAccent: const Color(0xFFD97450),
          vectorLine: const Color(0xFFEAE3DB),
        );
    }
  }

  /// ThemeData factory mapper for root MaterialApp
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: baseBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        brightness: _getBrightness(),
        surface: baseBackground,
        primary: primaryAccent,
      ),
      canvasColor: panelBackground,
      tabBarTheme: TabBarThemeData(indicatorColor: vectorLine),
    );
  }

  Brightness _getBrightness() {
    if (profile == ThemeProfile.nordicLight) {
      return Brightness.light;
    }
    return Brightness.dark;
  }
}

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_bloc.dart';

enum ThemeProfile {
  executiveDark,
  nordicLight,
  cyberneticMatrix,
  sereneFocus,
}

class SyncoraTheme {
  static SyncoraTheme of(BuildContext context) {
    return context.watch<ThemeBloc>().state.theme;
  }
  final ThemeProfile profile;
  final Color baseBackground;
  final Color panelBackground;
  final Color primaryAccent;
  final Color vectorLine;
  final Color edgeHighlight;
  final Color textPrimary;
  final Color panelBorder;
  final List<BoxShadow>? panelShadow;
  final Duration themeTransitionDuration;

  const SyncoraTheme._({
    required this.profile,
    required this.baseBackground,
    required this.panelBackground,
    required this.primaryAccent,
    required this.vectorLine,
    required this.edgeHighlight,
    required this.textPrimary,
    required this.panelBorder,
    this.panelShadow,
    required this.themeTransitionDuration,
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
          edgeHighlight: Colors.white.withValues(alpha: 0.15),
          textPrimary: Colors.white,
          panelBorder: Colors.white.withValues(alpha: 0.15),
          panelShadow: null,
          themeTransitionDuration: const Duration(milliseconds: 600),
        );
      case ThemeProfile.nordicLight:
        return SyncoraTheme._(
          profile: profile,
          baseBackground: const Color(0xFFF5F7FA),
          panelBackground: const Color(0xFFEBF2FA),
          primaryAccent: const Color(0xFF629A7D),
          vectorLine: const Color(0xFF333E48),
          edgeHighlight: Colors.black.withValues(alpha: 0.20),
          textPrimary: const Color(0xFF1C2541),
          panelBorder: const Color(0xFF94A3B8).withValues(alpha: 0.25),
          panelShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          themeTransitionDuration: const Duration(milliseconds: 600),
        );
      case ThemeProfile.cyberneticMatrix:
        return SyncoraTheme._(
          profile: profile,
          baseBackground: const Color(0xFF05070A),
          panelBackground: const Color(0xFF11161B).withValues(alpha: 1.0), // 100%
          primaryAccent: const Color(0xFFE5A93C),
          vectorLine: const Color(0xFF39FF14),
          edgeHighlight: Colors.white.withValues(alpha: 0.15),
          textPrimary: Colors.white,
          panelBorder: Colors.white.withValues(alpha: 0.15),
          panelShadow: null,
          themeTransitionDuration: const Duration(milliseconds: 600),
        );
      case ThemeProfile.sereneFocus:
        return SyncoraTheme._(
          profile: profile,
          baseBackground: const Color(0xFF1C1816),
          panelBackground: const Color(0xFF282320).withValues(alpha: 0.65),
          primaryAccent: const Color(0xFFD97450),
          vectorLine: const Color(0xFFEAE3DB),
          edgeHighlight: Colors.white.withValues(alpha: 0.15),
          textPrimary: Colors.white,
          panelBorder: Colors.white.withValues(alpha: 0.15),
          panelShadow: null,
          themeTransitionDuration: const Duration(milliseconds: 600),
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

  SyncoraTheme copyWith({
    Duration? themeTransitionDuration,
  }) {
    return SyncoraTheme._(
      profile: profile,
      baseBackground: baseBackground,
      panelBackground: panelBackground,
      primaryAccent: primaryAccent,
      vectorLine: vectorLine,
      edgeHighlight: edgeHighlight,
      textPrimary: textPrimary,
      panelBorder: panelBorder,
      panelShadow: panelShadow,
      themeTransitionDuration: themeTransitionDuration ?? this.themeTransitionDuration,
    );
  }
}

const syncoraThemeProfiles = ThemeProfile.values;

extension ThemeProfileExt on ThemeProfile {
  String get displayName {
    switch (this) {
      case ThemeProfile.executiveDark: return 'Executive Dark';
      case ThemeProfile.nordicLight: return 'Nordic Light';
      case ThemeProfile.cyberneticMatrix: return 'Cybernetic Matrix';
      case ThemeProfile.sereneFocus: return 'Serene Focus';
    }
  }
}

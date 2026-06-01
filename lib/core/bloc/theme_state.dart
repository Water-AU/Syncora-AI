import 'package:flutter/foundation.dart';
import '../theme/syncora_theme.dart';

@immutable
class ThemeState {
  final SyncoraTheme theme;

  const ThemeState({required this.theme});
}

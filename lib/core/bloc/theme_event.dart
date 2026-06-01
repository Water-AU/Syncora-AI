import 'package:flutter/foundation.dart';
import '../theme/syncora_theme.dart';

@immutable
abstract class ThemeEvent {}

class ThemeToggleEvent extends ThemeEvent {
  final ThemeProfile profile;
  ThemeToggleEvent(this.profile);
}

class ThemeDurationChangedEvent extends ThemeEvent {
  final Duration duration;
  ThemeDurationChangedEvent(this.duration);
}

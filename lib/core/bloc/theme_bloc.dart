import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import '../theme/syncora_theme.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({
    required ThemeProfile initialThemeProfile,
    required Duration initialDuration,
  }) : super(ThemeState(
          theme: SyncoraTheme.fromProfile(initialThemeProfile)
              .copyWith(themeTransitionDuration: initialDuration),
        )) {
    on<ThemeToggleEvent>((event, emit) async {
      final newTheme = SyncoraTheme.fromProfile(event.profile).copyWith(
        themeTransitionDuration: state.theme.themeTransitionDuration,
      );
      emit(ThemeState(theme: newTheme));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_profile_index', event.profile.index);
    });

    on<ThemeDurationChangedEvent>((event, emit) async {
      emit(ThemeState(theme: state.theme.copyWith(themeTransitionDuration: event.duration)));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_duration_ms', event.duration.inMilliseconds);
    });
  }
}

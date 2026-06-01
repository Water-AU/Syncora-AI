import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import '../theme/syncora_theme.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(theme: SyncoraTheme.fromProfile(ThemeProfile.executiveDark))) {
    on<ThemeToggleEvent>((event, emit) {
      emit(ThemeState(theme: SyncoraTheme.fromProfile(event.profile)));
    });
  }
}

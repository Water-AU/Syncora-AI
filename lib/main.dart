import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/bloc/theme_bloc.dart';
import 'core/bloc/theme_state.dart';
import 'core/bloc/analytics/analytics_bloc.dart';
import 'core/bloc/telemetry/telemetry_bloc.dart';
import 'core/bloc/telemetry/telemetry_event.dart';
import 'core/theme/syncora_theme.dart';
import 'core/audience/syncora_audience.dart';
import 'core/bloc/layout/layout_bloc.dart';
import 'features/palette/presentation/pages/palette_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final themeIndex = prefs.getInt('theme_profile_index') ?? ThemeProfile.executiveDark.index;
  final themeDurationMs = prefs.getInt('theme_duration_ms') ?? 600;
  final audienceIndex = prefs.getInt('audience_profile_index') ?? AudienceProfile.whiteCollar.index;

  final initialThemeProfile = ThemeProfile.values[themeIndex];
  final initialDuration = Duration(milliseconds: themeDurationMs);
  final initialAudience = AudienceProfile.values[audienceIndex];

  runApp(SyncoraApp(
    initialThemeProfile: initialThemeProfile,
    initialDuration: initialDuration,
    initialAudience: initialAudience,
  ));
}

class SyncoraApp extends StatelessWidget {
  final ThemeProfile initialThemeProfile;
  final Duration initialDuration;
  final AudienceProfile initialAudience;

  const SyncoraApp({
    super.key,
    required this.initialThemeProfile,
    required this.initialDuration,
    required this.initialAudience,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc(
            initialThemeProfile: initialThemeProfile,
            initialDuration: initialDuration,
          ),
        ),
        BlocProvider(
          create: (context) => TelemetryBloc()..add(StartTelemetryStream(initialAudience)),
        ),
        BlocProvider(
          create: (context) => AnalyticsBloc()..add(RefreshAnalytics()),
        ),
        BlocProvider(
          create: (context) => LayoutBloc(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Syncora AI',
            theme: state.theme.themeData,
            home: PaletteDashboardPage(initialAudience: initialAudience),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/bloc/theme_bloc.dart';
import 'core/bloc/theme_state.dart';
import 'features/palette/presentation/pages/palette_dashboard_page.dart';

void main() {
  runApp(const SyncoraApp());
}

class SyncoraApp extends StatelessWidget {
  const SyncoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Syncora AI',
            theme: state.theme.themeData,
            home: const PaletteDashboardPage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

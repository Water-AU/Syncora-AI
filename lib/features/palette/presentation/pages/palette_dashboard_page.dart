import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/theme_bloc.dart';
import '../../../../core/bloc/theme_event.dart';
import '../../../../core/theme/syncora_theme.dart';

class PaletteDashboardPage extends StatelessWidget {
  const PaletteDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Palette Dashboard Canvas'),
        actions: [
          PopupMenuButton<ThemeProfile>(
            onSelected: (profile) {
              context.read<ThemeBloc>().add(ThemeToggleEvent(profile));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ThemeProfile.executiveDark,
                child: Text('Executive Dark'),
              ),
              const PopupMenuItem(
                value: ThemeProfile.nordicLight,
                child: Text('Nordic Light'),
              ),
              const PopupMenuItem(
                value: ThemeProfile.cyberneticMatrix,
                child: Text('Cybernetic Matrix'),
              ),
              const PopupMenuItem(
                value: ThemeProfile.sereneFocus,
                child: Text('Serene Focus'),
              ),
            ],
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _SectionHeader(title: 'Row A: Core Elements & Containers'),
          SizedBox(height: 100), // Placeholder for future components
          
          _SectionHeader(title: 'Row B: Controls & Action Triggers'),
          SizedBox(height: 100),
          
          _SectionHeader(title: 'Row C: Telemetry Tiles & Gauges'),
          SizedBox(height: 100),
          
          _SectionHeader(title: 'Row D: System Banners & Intercepts'),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      margin: const EdgeInsets.only(bottom: 16.0, top: 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

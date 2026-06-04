import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/theme/syncora_theme.dart';
import 'package:syncora_ai/core/bloc/telemetry/telemetry_bloc.dart';
import 'package:syncora_ai/core/bloc/telemetry/telemetry_state.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/glass_panel.dart';
import 'package:syncora_ai/core/interfaces/drill_down_provider.dart';
import 'package:syncora_ai/core/bloc/layout/layout_event.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/generic_drill_down_wrapper.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';

class BiometricStatusHub extends StatelessWidget implements DrillDownProvider {
  final AppScreen activeScreen;
  const BiometricStatusHub({super.key, required this.activeScreen});

  @override
  DrillDownCriteria get drillDownConfig => const DrillDownCriteria(
    tableName: 'biometric_records',
    filterColumn: 'session_id',
    targetId: 'biometric_hub_root',
    criteriaType: 'vital_signs',
  );

  @override
  Widget build(BuildContext context) {
    return GenericDrillDownWrapper(
      activeScreen: activeScreen,
      provider: this,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildHeartRateTile()),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricTile()),
            const SizedBox(width: 16),
            const Expanded(child: SessionStopwatchTile()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateTile() {
    return BlocBuilder<TelemetryBloc, TelemetryState>(
      builder: (context, state) {
        final theme = SyncoraTheme.of(context);
        return GlassPanel(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: Colors.redAccent, size: 32),
              const SizedBox(height: 8),
              Text(
                '${state.heartRate} bpm',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Live Heart Rate',
                style: TextStyle(
                  color: theme.textPrimary.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricTile() {
    return BlocBuilder<TelemetryBloc, TelemetryState>(
      builder: (context, state) {
        final theme = SyncoraTheme.of(context);
        final percentage = (state.primaryMetricValue * 100).toStringAsFixed(1);
        return GlassPanel(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, color: theme.primaryAccent, size: 32),
              const SizedBox(height: 8),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.contextualNotification,
                style: TextStyle(
                  color: theme.textPrimary.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class SessionStopwatchTile extends StatefulWidget {
  const SessionStopwatchTile({super.key});

  @override
  State<SessionStopwatchTile> createState() => _SessionStopwatchTileState();
}

class _SessionStopwatchTileState extends State<SessionStopwatchTile> {
  late Timer _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = SyncoraTheme.of(context);
    return GlassPanel(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Colors.amber, size: 32),
          const SizedBox(height: 8),
          Text(
            _formattedTime,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Session Duration',
            style: TextStyle(
              color: theme.textPrimary.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

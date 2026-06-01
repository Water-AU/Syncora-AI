import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/theme/syncora_theme.dart';
import 'package:syncora_ai/core/bloc/analytics/analytics_bloc.dart';
import 'glass_panel.dart';

class HistoricalAnalyticsPanel extends StatelessWidget {
  const HistoricalAnalyticsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SyncoraTheme.of(context);
    return GlassPanel(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Vault Records & Telemetry Trends',
                style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AnalyticsBloc>().add(RefreshAnalytics());
                },
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryAccent),
                child: const Text('Refresh Logs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AnalyticsBloc>().add(PurgeAnalytics());
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Purge Vault Records', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              return Row(
                children: [
                  _buildStatCard('Total Records Row Count', '${state.totalRecords}', theme),
                  const SizedBox(width: 16),
                  _buildStatCard('Dynamic Session Average', '${(state.sessionAverage * 100).toStringAsFixed(1)}%', theme),
                  const SizedBox(width: 16),
                  _buildStatCard('Heart Rate Variance', '${state.heartRateAverage.toStringAsFixed(1)} bpm avg', theme),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, SyncoraTheme theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.primaryAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primaryAccent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: theme.textPrimary.withValues(alpha: 0.7), fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: theme.textPrimary, fontSize: 24, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

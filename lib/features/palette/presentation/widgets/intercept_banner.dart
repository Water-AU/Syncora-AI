import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/theme/syncora_theme.dart';
import 'package:syncora_ai/core/bloc/telemetry/telemetry_bloc.dart';
import 'package:syncora_ai/core/bloc/telemetry/telemetry_state.dart';
import 'package:syncora_ai/core/audience/syncora_audience.dart';
import 'glass_panel.dart';

class InterceptBanner extends StatelessWidget {
  final Widget? actionButton;

  const InterceptBanner({
    super.key,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SyncoraTheme.of(context);

    return BlocBuilder<TelemetryBloc, TelemetryState>(
      builder: (context, state) {
        final title = '${AudienceConfiguration.of(context).audienceName} Protocol';
        final message = 'Targeted Metric: ${AudienceConfiguration.of(context).primaryMetricFocus}\nRecommended: ${state.contextualNotification}';

        return GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: theme.primaryAccent,
                size: 28.0,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: theme.textPrimary.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                    if (actionButton != null) ...[
                      const SizedBox(height: 12.0),
                      actionButton!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

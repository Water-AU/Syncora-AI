import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/theme/syncora_theme.dart';
import 'package:syncora_ai/core/bloc/analytics/analytics_bloc.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';
import 'package:syncora_ai/core/interfaces/drill_down_provider.dart';
import 'package:syncora_ai/core/bloc/layout/layout_event.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/generic_drill_down_wrapper.dart';
import 'glass_panel.dart';

class ActivityTrendTimeline extends StatefulWidget implements DrillDownProvider {
  final LayoutManifestItem component;
  
  const ActivityTrendTimeline({super.key, required this.component});

  @override
  DrillDownCriteria get drillDownConfig => const DrillDownCriteria(
    tableName: 'telemetry_logs',
    filterColumn: 'activity_type',
    targetId: 'timeline_root',
  );

  @override
  State<ActivityTrendTimeline> createState() => _ActivityTrendTimelineState();
}

class _ActivityTrendTimelineState extends State<ActivityTrendTimeline> {
  @override
  Widget build(BuildContext context) {
    final theme = SyncoraTheme.of(context);
    return GenericDrillDownWrapper(
      activeScreen: widget.component.targetScreen,
      provider: widget,
      child: GlassPanel(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Trend Timeline',
              style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                builder: (context, state) {
                  if (state.rawLogs.isEmpty) {
                    return Center(
                      child: Text(
                        'No timeline data available.',
                        style: TextStyle(color: theme.textPrimary.withValues(alpha: 0.5)),
                      ),
                    );
                  }
                  return CustomPaint(
                    painter: _TimelinePainter(logs: state.rawLogs, theme: theme),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final List<Map<String, dynamic>> logs;
  final SyncoraTheme theme;

  _TimelinePainter({required this.logs, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.isEmpty) return;

    final paint = Paint()
      ..color = theme.primaryAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final double stepX = size.width / (logs.length > 1 ? (logs.length - 1) : 1);
    
    // Normalize heart rate (assuming range 60 - 180 for simple drawing)
    double getY(int hr) {
      final normalized = ((hr - 60) / 120).clamp(0.0, 1.0);
      return size.height - (normalized * size.height);
    }

    for (int i = 0; i < logs.length; i++) {
      final hr = logs[i]['heart_rate'] as int? ?? 80;
      final x = i * stepX;
      final y = getY(hr);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Draw points
      canvas.drawCircle(Offset(x, y), 4.0, Paint()..color = theme.textPrimary);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) {
    return oldDelegate.logs != logs || oldDelegate.theme != theme;
  }
}

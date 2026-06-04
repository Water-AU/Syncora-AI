import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/theme/syncora_theme.dart';
import 'package:syncora_ai/core/bloc/telemetry/telemetry_bloc.dart';
import 'package:syncora_ai/core/bloc/telemetry/telemetry_state.dart';
import 'package:syncora_ai/core/interfaces/drill_down_provider.dart';
import 'package:syncora_ai/core/bloc/layout/layout_event.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/generic_drill_down_wrapper.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';

class ArcGauge extends StatefulWidget implements DrillDownProvider {
  final AppScreen activeScreen;
  const ArcGauge({super.key, required this.activeScreen});

  @override
  DrillDownCriteria get drillDownConfig => const DrillDownCriteria(
    tableName: 'telemetry_logs',
    filterColumn: 'metric_category',
    targetId: 'arc_gauge_root',
    criteriaType: 'voltage_amperage',
  );

  @override
  State<ArcGauge> createState() => _ArcGaugeState();
}

class _ArcGaugeState extends State<ArcGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(ArcGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // State is now internally managed via BlocBuilder, removing manual progress checking.
    // Upstream theme transition or layout change detected.
    _controller.forward(from: 0.0);
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SyncoraTheme.of(context);
    
    return GenericDrillDownWrapper(
      activeScreen: widget.activeScreen,
      provider: widget,
      child: BlocBuilder<TelemetryBloc, TelemetryState>(
        builder: (context, state) {
        // Only trigger animation retween if the data actually changed
        if (_animation.value != state.primaryMetricValue) {
          _animation = Tween<double>(begin: _animation.value, end: state.primaryMetricValue).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
          _controller.forward(from: 0.0);
        }
        
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _ArcGaugePainter(
                progress: _animation.value,
                primaryAccent: theme.primaryAccent,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(_animation.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 42.0,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  final double progress;
  final Color primaryAccent;

  _ArcGaugePainter({
    required this.progress,
    required this.primaryAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 12.0;
    
    // The Background Track (15% opacity)
    final trackPaint = Paint()
      ..color = primaryAccent.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // The Progress Arc (Solid primaryAccent)
    final arcPaint = Paint()
      ..color = primaryAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -pi / 2; // Start from the top
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.primaryAccent != primaryAccent;
  }
}

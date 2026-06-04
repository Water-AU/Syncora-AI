import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/theme/syncora_theme.dart';
import 'package:syncora_ai/core/bloc/analytics/analytics_bloc.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';
import 'glass_panel.dart';

class NutrientConsumptionHistory extends StatefulWidget {
  final LayoutManifestItem component;
  
  const NutrientConsumptionHistory({super.key, required this.component});

  @override
  State<NutrientConsumptionHistory> createState() => _NutrientConsumptionHistoryState();
}

class _NutrientConsumptionHistoryState extends State<NutrientConsumptionHistory> {
  @override
  Widget build(BuildContext context) {
    final theme = SyncoraTheme.of(context);
    return GlassPanel(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Nutrient Consumption History',
            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            width: 180,
            child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, state) {
                final target = 1.0; // 100%
                final actual = state.sessionAverage; // e.g. 0.85
                
                return CustomPaint(
                  painter: _ArcPainter(
                    target: target,
                    actual: actual,
                    theme: theme,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(actual * 100).toStringAsFixed(1)}%',
                          style: TextStyle(color: theme.textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'of Target',
                          style: TextStyle(color: theme.textPrimary.withValues(alpha: 0.7), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double target;
  final double actual;
  final SyncoraTheme theme;

  _ArcPainter({required this.target, required this.actual, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = theme.primaryAccent.withValues(alpha: 0.2)
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = theme.primaryAccent
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = target == 0 ? 0.0 : (actual / target).clamp(0.0, 1.0) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.actual != actual || oldDelegate.target != target || oldDelegate.theme != theme;
  }
}

import 'package:flutter/foundation.dart';

@immutable
class TelemetryState {
  final double primaryMetricValue;
  final int heartRate;
  final String contextualNotification;

  const TelemetryState({
    required this.primaryMetricValue,
    required this.heartRate,
    required this.contextualNotification,
  });

  factory TelemetryState.initial() {
    return const TelemetryState(
      primaryMetricValue: 0.0,
      heartRate: 70,
      contextualNotification: 'Initializing telemetry streams...',
    );
  }

  TelemetryState copyWith({
    double? primaryMetricValue,
    int? heartRate,
    String? contextualNotification,
  }) {
    return TelemetryState(
      primaryMetricValue: primaryMetricValue ?? this.primaryMetricValue,
      heartRate: heartRate ?? this.heartRate,
      contextualNotification: contextualNotification ?? this.contextualNotification,
    );
  }
}

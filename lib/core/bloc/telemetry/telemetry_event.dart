import 'package:flutter/foundation.dart';
import '../../audience/syncora_audience.dart';

@immutable
abstract class TelemetryEvent {}

class StartTelemetryStream extends TelemetryEvent {
  final AudienceProfile profile;
  StartTelemetryStream(this.profile);
}

class UpdateAudienceTelemetry extends TelemetryEvent {
  final AudienceProfile profile;
  UpdateAudienceTelemetry(this.profile);
}

class TelemetryDataReceived extends TelemetryEvent {
  final double primaryMetricValue;
  final int heartRate;
  final String contextualNotification;

  TelemetryDataReceived({
    required this.primaryMetricValue,
    required this.heartRate,
    required this.contextualNotification,
  });
}

import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../database/database_service.dart';
import '../../audience/syncora_audience.dart';
import 'telemetry_event.dart';
import 'telemetry_state.dart';

class TelemetryBloc extends Bloc<TelemetryEvent, TelemetryState> {
  StreamSubscription<int>? _tickerSubscription;
  AudienceProfile _currentProfile = AudienceProfile.whiteCollar;
  final _random = Random();

  TelemetryBloc() : super(TelemetryState.initial()) {
    on<StartTelemetryStream>((event, emit) {
      _currentProfile = event.profile;
      _tickerSubscription?.cancel();
      // Instantly generate the first tick
      add(_generateTelemetryTick());
      _tickerSubscription = Stream.periodic(const Duration(seconds: 4), (x) => x).listen((tick) {
        add(_generateTelemetryTick());
      });
    });

    on<UpdateAudienceTelemetry>((event, emit) {
      _currentProfile = event.profile;
      add(_generateTelemetryTick());
    });

    on<TelemetryDataReceived>((event, emit) {
      emit(state.copyWith(
        primaryMetricValue: event.primaryMetricValue,
        heartRate: event.heartRate,
        contextualNotification: event.contextualNotification,
      ));
    });
  }

  TelemetryDataReceived _generateTelemetryTick() {
    double metric;
    int hr;
    String notification;

    switch (_currentProfile) {
      case AudienceProfile.whiteCollar:
        metric = 0.60 + (_random.nextDouble() * 0.25); // 60% - 85%
        hr = 65 + _random.nextInt(15);
        final alerts = [
          'Sedentary posture detected. Consider a 2-minute standing stretch.',
          'Cognitive load peaking. Optimize lighting for focus.',
          'Ergonomic misalignment detected in lower back region.',
        ];
        notification = alerts[_random.nextInt(alerts.length)];
        break;
      case AudienceProfile.blueCollar:
        metric = 0.45 + (_random.nextDouble() * 0.45); // 45% - 90%
        hr = 80 + _random.nextInt(40);
        final alerts = [
          'Muscular fatigue approaching threshold. Hydration recommended.',
          'Asymmetric lifting strain detected. Reset stance.',
          'Joint compression sustained. Prepare for decompression protocol.',
        ];
        notification = alerts[_random.nextInt(alerts.length)];
        break;
      case AudienceProfile.educator:
        metric = 0.50 + (_random.nextDouble() * 0.35); // 50% - 85%
        hr = 70 + _random.nextInt(25);
        final alerts = [
          'High vocal strain detected. Active rest recommended.',
          'Prolonged standing stance. Shift weight distribution.',
          'Sensory load approaching overload. Dim lighting slightly.',
        ];
        notification = alerts[_random.nextInt(alerts.length)];
        break;
    }

    // Persist to SQLite
    DatabaseService.instance.insertLog(_currentProfile.name, metric, hr);

    return TelemetryDataReceived(
      primaryMetricValue: metric,
      heartRate: hr,
      contextualNotification: notification,
    );
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}

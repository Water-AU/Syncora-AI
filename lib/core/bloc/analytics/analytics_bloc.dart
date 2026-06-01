import 'package:flutter_bloc/flutter_bloc.dart';
import '../../database/database_service.dart';

abstract class AnalyticsEvent {}

class RefreshAnalytics extends AnalyticsEvent {}

class PurgeAnalytics extends AnalyticsEvent {}

class AnalyticsState {
  final int totalRecords;
  final double sessionAverage;
  final double heartRateAverage;

  const AnalyticsState({
    required this.totalRecords,
    required this.sessionAverage,
    required this.heartRateAverage,
  });

  factory AnalyticsState.initial() {
    return const AnalyticsState(
      totalRecords: 0,
      sessionAverage: 0.0,
      heartRateAverage: 0.0,
    );
  }
}

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(AnalyticsState.initial()) {
    on<RefreshAnalytics>((event, emit) async {
      final aggregates = await DatabaseService.instance.getHistoricalAggregates();
      emit(AnalyticsState(
        totalRecords: aggregates['total_records'] as int? ?? 0,
        sessionAverage: aggregates['average_metric'] as double? ?? 0.0,
        heartRateAverage: aggregates['average_hr'] as double? ?? 0.0,
      ));
    });

    on<PurgeAnalytics>((event, emit) async {
      await DatabaseService.instance.purgeAllLogs();
      emit(AnalyticsState.initial());
    });
  }
}

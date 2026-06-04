# Phase C Step-1: Engineering Historical Reporting Components

We need to implement the new Activity and Diet reporting canvases to provide data-heavy visual analysis using our local telemetry database. This involves creating two new custom data visualization widgets, extending our SQLite and BLoC pipelines to support raw historical data extraction, and mapping them into our dynamic layout engine.

## Proposed Changes

### Core Data & State Upgrades

#### [MODIFY] `lib/core/database/database_service.dart`
- Add a new method `Future<List<Map<String, dynamic>>> getRawTelemetryLogs({int limit = 50})` to fetch the chronological series of logs required for timeline rendering.

#### [MODIFY] `lib/core/bloc/analytics/analytics_bloc.dart`
- Expand `AnalyticsState` to include `final List<Map<String, dynamic>> rawLogs`.
- Update `RefreshAnalytics` to fetch and store these raw logs alongside the existing aggregates, so any connected UI component can instantly access the historical series.

---

### Manifest Registry & Router Bindings

#### [MODIFY] `lib/core/layout/layout_manifest.dart`
- Append the new UUID tokens to `defaultManifest`:
  - `LayoutManifestItem(id: 'a2b3c4d5-e6f7-8a9b-0c1d-2e3f4a5b6c7d', debugTag: 'ActivityTrendTimeline', targetScreen: AppScreen.activity, rowPosition: 1)`
  - `LayoutManifestItem(id: 'd5c4b3a2-f7e6-9b8a-1c0d-3e2f5a4b6c7d', debugTag: 'NutrientConsumptionHistory', targetScreen: AppScreen.diet, rowPosition: 1)`

#### [MODIFY] `lib/features/palette/presentation/pages/palette_dashboard_page.dart`
- Add switch cases in `_buildManifestComponent` to resolve the two new UUID strings, returning the new widget classes securely wrapped in `_SectionHeader`.

---

### New Visualization Components

#### [NEW] `lib/features/palette/presentation/widgets/activity_trend_timeline.dart`
- Build a responsive layout wrapped in our `GlassPanel` styling.
- Utilize a `BlocBuilder<AnalyticsBloc, AnalyticsState>` to consume the `rawLogs`.
- Implement a `CustomPainter` to draw a sleek, dynamic line graph mapping `timestamp` (X-axis) against `heart_rate` or `metric_value` (Y-axis). 
- Provide an elegant fallback/baseline if the dataset is empty.

#### [NEW] `lib/features/palette/presentation/widgets/nutrient_consumption_history.dart`
- Build a multi-day comparison module enclosed in a `GlassPanel`.
- Visualize the `sessionAverage` against an implicit daily target (e.g., 100%) using a sophisticated circular tracking ring (drawn via `CustomPaint` or nested progress arcs).
- Display historical aggregates beneath the ring.

## Verification Plan

### Automated Compilation
- I will execute `dart bin/architecture_audit.dart` or `flutter analyze` via programmatic reporting to guarantee perfect compilation and decoupled architecture boundaries.

### Manual Verification
- Re-run `flutter run -d windows`.
- Navigate between the Home, Activity, and Diet tabs to observe the newly populated tracking charts successfully rendering the SQLite data streams natively on the desktop canvas.

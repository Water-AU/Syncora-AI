# Syncora AI: Phase 4 Expansion — Local Database Verification

This document outlines the proposed architectural implementation for the Database Inspector UI and the Historical Analytics Reporting Engine.

## User Review Required

> [!WARNING]
> **Database Engine on Windows:** Native `sqflite` does not support Windows directly. We must utilize `sqflite_common_ffi` to interact with SQLite on a desktop environment. This plan assumes we will inject `sqflite` and `sqflite_common_ffi` into `pubspec.yaml` and initialize the FFI bindings in `main.dart`. 

> [!IMPORTANT]
> **Data Generation:** Currently, our telemetry stream does not automatically log to a database. As part of this implementation, I will attach a database write operation inside `TelemetryBloc` so that every 4-second tick saves a row to the `telemetry_logs` table, giving the UI real data to query.

## Proposed Changes

### Core Storage Layer (New)
#### [NEW] `lib/core/database/database_service.dart`
- Initialize a local `sqlite3` database via `sqflite_common_ffi`.
- Create a `telemetry_logs` table structured to store: `id` (int), `timestamp` (datetime), `metric_value` (real), and `heart_rate` (integer).
- Implement explicit methods: `insertLog()`, `getHistoricalAggregates()`, and `purgeAllLogs()`.
- Expose a clean Dart repository interface to shield the UI from raw SQL execution.

### BLoC State Management (New)
#### [NEW] `lib/core/bloc/analytics/analytics_bloc.dart`
- Manage state for `totalRecords`, `sessionAverage`, and `heartRateVariance`.
- Handle `RefreshAnalytics` and `PurgeAnalytics` events.

### Presentation UI (New & Modified)
#### [NEW] `lib/features/palette/presentation/widgets/historical_analytics_panel.dart`
- **Data Counters:** Visual aggregate grids rendering the row count, dynamic session average, and HR variance.
- **Manual Query Triggers:** Two action buttons (`Refresh Logs`, `Purge Vault Records`) that strictly dispatch events to the `AnalyticsBloc`.
- Wrapped elegantly in `GlassPanel` for uniform design tokens.

#### [MODIFY] `lib/features/palette/presentation/pages/palette_dashboard_page.dart`
- Mount `HistoricalAnalyticsPanel` under **Row F**.

## Verification Plan

### Automated Checks
- Execute `dart bin/architecture_audit.dart` to verify zero SQL or raw logic leaks into the presentation tier.
- Ensure the newly created BLoCs and Database services fall strictly under `lib/core/`.

### Manual Testing
- Start the Windows application. 
- Wait 12 seconds for the telemetry stream to generate 3 logs.
- Click **Refresh Logs** to ensure the analytics counter hits `3` and average is calculated.
- Click **Purge Vault Records** and confirm the counters reset to `0`.

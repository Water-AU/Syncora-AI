# Syncora AI: Phase A — Manifest-Driven Layout Engine (Revised)

## AS-IS Discovery Audit Findings

I have audited the active workspace and confirmed the precise structural state of the requested components:

1. **`palette_dashboard_page.dart`**: Currently hardcodes a `ListView` mapping `ArcGauge`, `InterceptBanner`, `SettingsControlRow`, and `HistoricalAnalyticsPanel` sequentially. Crucially, it manages the `_activeAudience` state locally and wraps `ArcGauge` and `InterceptBanner` in `BlocBuilder<TelemetryBloc, TelemetryState>` externally.
2. **`arc_gauge.dart`**: Purely declarative. Takes a `progress` double. It contains no internal state awareness of the `TelemetryBloc`.
3. **`intercept_banner.dart`**: Purely declarative. Takes `title` and `message` strings. It has no internal awareness of the `TelemetryBloc` or `AudienceConfiguration`.
4. **`historical_analytics_panel.dart`**: Already fully self-contained. It internally houses a `BlocBuilder<AnalyticsBloc>` and safely manages its own dispatch events (`RefreshAnalytics`, `PurgeAnalytics`).
5. **`settings_control_row.dart`**: Expects `activeAudience` and `onAudienceChanged` parameters, directly mutating the local layout state of the dashboard while dispatching BLoC events for themes and telemetry updates.

## Proposed Implementation Plan

### 1. Build the Layout Manifest Schema
#### [NEW] `lib/core/layout/layout_manifest.dart`
- Define the configuration schema mapping unique component string IDs to screen destinations and chronological row indexes.
- Pre-populate `defaultManifest` using our real components:
  - `widget_arc_gauge` (Row 0)
  - `widget_intercept_banner` (Row 1)
  - `widget_settings_control` (Row 2)
  - `widget_sql_analytics` (Row 3)

### 2. Encapsulate State (Smart Widgets)
We will transition the passive widgets into "Smart Widgets" so they load their own data natively.
#### [MODIFY] `lib/features/palette/presentation/widgets/arc_gauge.dart`
- Remove the `progress` parameter from the public constructor.
- Inject the `BlocBuilder<TelemetryBloc, TelemetryState>` directly into the internal widget `build` method, mapping `state.primaryMetricValue` to the painter automatically.
#### [MODIFY] `lib/features/palette/presentation/widgets/intercept_banner.dart`
- Remove `title` and `message` from the public constructor.
- Inject `BlocBuilder<TelemetryBloc, TelemetryState>` and `AudienceConfiguration.of(context)` inside the widget so it calculates its own dynamic alert text.

### 3. Deploy the Layout Factory
#### [MODIFY] `lib/features/palette/presentation/pages/palette_dashboard_page.dart`
- Erase the hardcoded chronological `ListView`.
- Implement a `ListView.builder` iterating over the sorted `LayoutManifestItem` array.
- Create a `_buildManifestComponent(String id)` resolver function that acts as a factory, returning `ArcGauge()`, `InterceptBanner()`, `HistoricalAnalyticsPanel()`, or `SettingsControlRow(...)` based on the manifest ID. 

## Verification Plan
- Execute `dart bin/architecture_audit.dart` to verify that encapsulating BLoC builders inside the specific widget files does not violate pure presentation rules (the audit script permits BLoC consumption in widgets, only rejecting raw conditional business logic).
- Verify the Windows execution renders the precise same chronological dashboard layout, but derived completely from the `defaultManifest` array rather than hardcoded tree lists.

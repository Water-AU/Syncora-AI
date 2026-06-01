# Syncora AI: Biometric Status Hub Blueprint

This document details the STAGE-0 DIRECTIVE forensic audit and implementation blueprint for integrating the Biometric Status Hub into the Manifest-Driven Layout Engine.

## PART 1: FORENSIC AS-IS STATE & VISUAL AUDIT

### 1. Telemetry State Availability
**File Locations**: 
- [telemetry_state.dart](file:///c:/Users/a428037/Development/AntiGravity/Syncora-AI/lib/core/bloc/telemetry/telemetry_state.dart)
- [telemetry_bloc.dart](file:///c:/Users/a428037/Development/AntiGravity/Syncora-AI/lib/core/bloc/telemetry/telemetry_bloc.dart)

**State Variables**:
- `primaryMetricValue` (double): Tracks the core adaptive metric (e.g., fatigue/cognitive load). Values are synthetically generated based on the `AudienceProfile` (ranging from 0.45 to 0.90 depending on the profile).
- `heartRate` (int): Represents the live heart rate in bpm. Dynamically ranges from 65 up to 120 based on the active audience profile context.
- `contextualNotification` (String): Alert message correlated with the telemetry tick.

**Stream Interval**:
The `TelemetryBloc` orchestrates a synthetic stream using `Stream.periodic(const Duration(seconds: 4), ...)` which dispatches a `TelemetryDataReceived` tick every 4 seconds.

### 2. Resolver Factory Alignment
**File Location**: [palette_dashboard_page.dart](file:///c:/Users/a428037/Development/AntiGravity/Syncora-AI/lib/features/palette/presentation/pages/palette_dashboard_page.dart)

The manifest is hydrated through the `_buildManifestComponent(String id, int displayIndex)` switch resolver. To insert the new hub without breaking existing flows, we will register a new `case 'c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f':` immediately before the `default:` branch. This case will yield a `Column` containing:
1. `_SectionHeader(title: 'Row $displayIndex: Biometric Status Hub')`
2. `BiometricStatusHub()` (The new multi-column widget)

---

## PART 2: PROPOSED MULTI-COLUMN DESIGN & ALIGNMENT PLAN

### 1. Immutable UUID Correlation
**UUID Token**: `'c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f'`

**Registration & Seeding**:
In [layout_manifest.dart](file:///c:/Users/a428037/Development/AntiGravity/Syncora-AI/lib/core/layout/layout_manifest.dart), we will append a new `LayoutManifestItem` to the `defaultManifest` constant array:
```dart
  LayoutManifestItem(
    id: 'c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f',
    debugTag: 'BiometricStatusHub',
    targetScreen: AppScreen.home,
    rowPosition: 1, // Target insertion position
  ),
```
Because the `layout_manifest` SQLite table is synced from `defaultManifest` during database initialization and layout cascade resets, no direct SQL query insertion is needed. The BLoC engine will automatically insert the missing record on its next boot sequence check.

### 2. Horizontal Multi-Column Constraints
**Widget Tree Definition**:
The new file `lib/features/palette/presentation/widgets/biometric_status_hub.dart` will be structured natively using an `IntrinsicHeight` layout wrapper.

```dart
IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(child: _buildHeartRateTile()),
      const SizedBox(width: 16),
      Expanded(child: _buildMetricTile()),
      const SizedBox(width: 16),
      Expanded(child: _buildStopwatchTile()),
    ],
  ),
)
```

### 3. Cross-Axis Alignment Strategy
To guarantee that the three side-by-side cards scale dynamically and symmetrically without clipping (especially when a window resize causes one card's textual content to wrap and expand vertically), we will implement a dual-constraint strategy:
1. Wrap the parent `Row` inside an `IntrinsicHeight` widget. This forces the Row to size itself to the height of its tallest child.
2. Inside the `Row`, apply `crossAxisAlignment: CrossAxisAlignment.stretch`. This instructs all `Expanded` children (the glass-morphic cards) to forcibly stretch vertically to fill that IntrinsicHeight bounds.
This pattern ensures 100% uniformity across the three tiles under all responsive constraints.

### 4. Tile Functionality & State Bindings

- **Tile 1 (Left - Heart Rate)**:
  - Uses `BlocBuilder<TelemetryBloc, TelemetryState>` to listen for live state.
  - Displays a pulsating or static heart icon alongside `state.heartRate` formatting (e.g., "72 bpm").
- **Tile 2 (Center - Cognitive/Fatigue Metric)**:
  - Also relies on the `TelemetryBloc`.
  - Maps `state.primaryMetricValue` (e.g., `0.65`) into a percentage or gauge.
  - Textually adapts to the contextual notification or profile type.
- **Tile 3 (Right - Session Stopwatch)**:
  - Internally managed using a `StatefulWidget` or `TickerProviderStateMixin`.
  - Operates a parameterless local timer loop (`Timer.periodic`) tracking elapsed seconds.
  - Formats duration into `MM:SS` (e.g., `04:12`), maintaining total UI isolation from the BLoC engine.

> [!IMPORTANT]
> **User Review Required**
> Please review this forensic audit and implementation blueprint. If the constraints and UUID assignments align with your expectations, approve this plan so we can transition into the STAGE-1 CODE EXECUTION phase.

# Syncora AI: Phase A — Manifest-Driven Layout Engine

This document outlines the architectural upgrade to fully decouple our UI widgets from the raw `PaletteDashboardPage` sequential layout and transition to a dynamic `LayoutManifest` builder.

## Open Questions & User Review Required

> [!WARNING]
> **Missing Components:** The layout manifest specifies `ProfileHeaderInfoCard` and `Modular Biometric Status Hub`. These widgets do not currently exist in the codebase. 
> * **My Proposal:** I will engineer clean, sandbox-ready placeholder widgets for `ProfileHeaderInfoCard` (Row 0) and `BiometricStatusHub` (Row 1) so that the manifest loop can flawlessly map them out on screen. If you prefer to map existing widgets (like `SettingsControlRow`), let me know.

> [!IMPORTANT]
> **State Bridging in Widgets:** Currently, `ArcGauge` and `InterceptBanner` are wrapped in `BlocBuilder<TelemetryBloc, TelemetryState>` directly inside the `palette_dashboard_page.dart` layout tree. As part of this upgrade, I will move these `BlocBuilder` wrappers *inside* the standalone components themselves. This guarantees they are completely self-contained "smart widgets" that don't rely on parent page bindings.

## Proposed Changes

### 1. Build the Layout Manifest Schema
#### [NEW] `lib/core/layout/layout_manifest.dart`
- Define `enum AppScreen { home, activity, ai, diet, profile }`.
- Define `class LayoutManifestItem { final String id; final AppScreen targetScreen; final int rowPosition; }`.
- Pre-populate a static `defaultManifest` array mapping the 5 requested rows (0 through 4) to `AppScreen.home`.

### 2. Refactor Top-Level Components
#### [MODIFY] `lib/features/palette/presentation/widgets/arc_gauge.dart`
- Wrap the raw gauge in a `BlocBuilder<TelemetryBloc, TelemetryState>` and `GlassPanel` so it is a standalone object.
#### [MODIFY] `lib/features/palette/presentation/widgets/intercept_banner.dart`
- Internalize the `BlocBuilder<TelemetryBloc, TelemetryState>` and `AudienceConfiguration.of(context)` lookups.
#### [NEW] `lib/features/palette/presentation/widgets/profile_header_info_card.dart`
- Create a standalone header card placeholder.
#### [NEW] `lib/features/palette/presentation/widgets/biometric_status_hub.dart`
- Create a modular biometric hub placeholder.

### 3. Dynamic Layout Canvas Resolver
#### [MODIFY] `lib/features/palette/presentation/pages/palette_dashboard_page.dart`
- Strip out the hardcoded `ListView` sequential children.
- Build a dynamic `ListView.builder` that loops over `defaultManifest.where((item) => item.targetScreen == AppScreen.home).toList()..sort()`.
- Use a `switch(item.id)` to instantiate the standalone widget blocks reactively.

## Verification Plan

### Automated Checks
- Execute `dart bin/architecture_audit.dart` to verify zero architectural linter flags, confirming the decoupling of widgets from the main canvas.

### Manual Verification
- Visual check of the Windows runner to ensure all 5 rows render in chronological sequence, driven entirely by the `LayoutManifestItem.rowPosition` values.

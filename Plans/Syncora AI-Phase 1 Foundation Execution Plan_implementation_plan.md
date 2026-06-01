# Syncora AI: Phase 1 Foundation Execution Plan

This plan outlines the steps to initialize the core Flutter workspace and establish the component-driven architectural foundation for Syncora AI based on the provided Master Specifications.

> [!IMPORTANT]  
> **Blocker Identified:** During initial environment checks, the `flutter` command was not recognized in the system PATH. Before we can execute `flutter create .` and build the application, Flutter must be installed on this machine and added to the PATH, or the path to the Flutter SDK must be provided.

## User Review Required
Please review the architectural file layout and theme token values mapped below. Once approved, and the Flutter path issue is resolved, I will autonomously execute this sequence.

## Open Questions
1. **Flutter SDK Location:** The `flutter` command is not available in your system's current PATH. Is Flutter installed on this machine? If so, could you provide the absolute path to the Flutter `bin` directory?
2. **Platform Targets:** By default, `flutter create .` will attempt to scaffold Windows, Web, Android, and iOS. Do you want to restrict the generated platform folders to only Android and iOS?

## Proposed Changes

We will systematically execute the creation of the Flutter project and the Component-Driven Development scaffolding.

### Flutter Project Initialization
- Run `flutter create .` (or specific platform target like `flutter create --platforms=android,ios .`).
- Add the `flutter_bloc` and `bloc` dependencies to `pubspec.yaml`.

---

### Core Architecture & Theme System

#### [NEW] lib/core/theme/syncora_theme.dart
Will contain the immutable design system defining the four required themes (Executive Dark, Nordic Light, Cybernetic Matrix, Serene Focus) with exact hex values mapped from the specifications.

#### [NEW] lib/core/utils/sanitization_utils.dart
Will contain placeholder helper methods for cryptographic sanitization and data scrubbing prior to transient processing.

#### [NEW] lib/core/bloc/theme_event.dart
Will define the intent objects to switch between the 4 themes.

#### [NEW] lib/core/bloc/theme_state.dart
Will define the immutable output objects representing the currently active theme styling.

#### [NEW] lib/core/bloc/theme_bloc.dart
Will implement the standard `flutter_bloc` logic to handle `ThemeEvent.toggle` inputs and emit `ThemeState` outputs.

---

### Component Palette Canvas

#### [NEW] lib/features/palette/presentation/pages/palette_dashboard_page.dart
A developer-focused scaffold containing a scrollable viewport. It will implement distinct placeholder sections for future components:
* Row A: Core Elements & Containers
* Row B: Controls & Action Triggers
* Row C: Telemetry Tiles & Gauges
* Row D: System Banners & Intercepts

#### [NEW] lib/features/palette/presentation/widgets/.gitkeep
Empty folder to hold future isolated visual components.

#### [NEW] lib/features/palette/domain/.gitkeep
Empty folder for the domain-level logical files of the palette feature.

#### [NEW] lib/features/palette/data/.gitkeep
Empty folder for the data layer of the palette feature.

---

### Bootstrapping

#### [MODIFY] lib/main.dart
Strip the default counter template and wrap the root `MaterialApp` in a `BlocProvider` for `ThemeBloc`. Force the root routing to boot directly into `PaletteDashboardPage`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to guarantee the codebase compiles with zero linting or static typing errors.
- Ensure all BLoC state streams transition without throwing unhandled exceptions.

### Manual Verification
- Launch the application via `flutter run` on an available device/emulator to verify the `PaletteDashboardPage` renders with the Default Executive Dark theme without distortion.

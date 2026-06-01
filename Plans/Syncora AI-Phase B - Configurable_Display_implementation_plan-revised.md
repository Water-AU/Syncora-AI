# Syncora AI: Phase B — Forensic Audit & Index-Shifting Blueprint

As instructed, this is a strict STAGE-0 discovery and architectural planning document. Zero files have been modified.

---

## PART 1: Forensic AS-IS Infrastructure Audit

### 1. Persistence Architecture Lookup
- **App Hydration (`main.dart`)**: The app currently hydrates basic key-value preferences (Theme, Audience, Duration) synchronously before `runApp` using `SharedPreferences`.
- **Relational Data (`database_service.dart`)**: Our native Windows data layer initializes `sqflite_common_ffi` at runtime and mounts a SQLite database (`telemetry.db`) inside the native `getApplicationDocumentsDirectory()`. It currently houses a single `telemetry_logs` schema table.

### 2. Active State Layer Map (`settings_control_row.dart`)
- **Consumption**: Natively reads visual tokens via `SyncoraTheme.of(context)`. Initially inherits its state from the `AudienceScope` root injection via `AudienceConfiguration.of(context).profile`.
- **Dispatch**: Directly pushes event payloads into our global `MultiBlocProvider` instance via `context.read<ThemeBloc>().add(...)` and `context.read<TelemetryBloc>().add(...)`.
- **Side Effects**: Fires asynchronous disk commits via `AudienceConfiguration.saveProfile()` on interaction.

### 3. In-Memory Manifest Mutability (`layout_manifest.dart`)
- **Immutability Lock**: The `defaultManifest` array is currently typed as a strict compile-time `const List<LayoutManifestItem>`. It is 100% immutable at runtime. Structural changes currently require hard-recompilation.

---

## PART 2: Proposed Step-By-Step Implementation Plan

To enable true drag-and-drop / algorithmic layout shifting at runtime, we must break the `const` lock and engineer a persistence bridge.

### 1. Algorithm Design: Index-Shifting Cascade Logic
We will construct a new `LayoutBloc` responsible for intercepting position shift events. 
- **Screen Filter Constraint**: The cascade calculation algorithm will *strictly* isolate its mapping to components sharing the active `AppScreenExtension.uuid`. Cross-screen collisions are mathematically impossible.
- **Cascade Shift (Push Down)**: If a collision exists within the active screen UUID list, Component B is mutated to `rowPosition + 1`. The check repeats recursively downwards until an empty slot is found.
- **Array Sorting**: The mutated, collision-free list is sorted (`.sort(...)`) and emitted to the UI state.

### 2. Hydration & Storage System (SQLite Integration)
Rather than overloading key-value preferences, we will leverage our established `sqflite` FFI pipeline:
- **Schema Expansion**: In `database_service.dart`, `layout_manifest` table has been deployed mapping:
  - `screen_uuid` (TEXT NOT NULL)
  - `object_uuid` (TEXT NOT NULL UNIQUE)
  - `row_position` (INTEGER NOT NULL)
  - `PRIMARY KEY (screen_uuid, row_position)`
- **Composite Integrity**: The SQLite unique constraint mathematically blocks an object from duplicating across screens, and the composite Primary Key blocks two objects from occupying the same row on the same screen.
- **Hydration Bridge**: `LayoutBloc` will initialize by executing `SELECT * FROM layout_manifest WHERE screen_uuid = ?` and map the results to the UI.
- **Auto-Commit**: The cascade algorithm concludes with a bulk transaction to `INSERT OR REPLACE` the new coordinated rows to disk safely without violating constraints.

### 3. Control UI Panel Integration
- **Settings Row Expansion**: Inside `settings_control_row.dart`, each component in our UUID manifest registry will display its human-readable `debugTag` alongside two distinct parameterless Dropdown buttons.
- **Dropdown 1 (Target Screen Selector)**: Allows the user to select which `AppScreen` canvas they want the widget to live on.
- **Dropdown 2 (Vertical Row Index Selector)**: Allows the user to select the targeted vertical row positioning for that widget.
- **Decoupled Execution**: Toggling these dropdowns dispatches a clean layout modification event (`ShiftComponentLayout`) to the `LayoutBloc`, keeping the control UI fully decoupled from raw array logic.

## User Review Required

> [!IMPORTANT]
> **Database Migration:** Altering `_createDB` in `database_service.dart` will not automatically trigger for users with an existing `telemetry.db` file unless we increment the `version` integer in `openDatabase` and implement `onUpgrade`. I will handle this explicitly in the code.

Please review this implementation plan. I will not proceed with execution until I receive your explicit approval.

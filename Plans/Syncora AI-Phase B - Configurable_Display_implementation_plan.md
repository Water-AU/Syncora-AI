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
We will construct a new `LayoutBloc` responsible for intercepting position shift events. When a user requests to move Component A to `rowPosition = 1`:
1. **Collision Detection**: The algorithm checks if a Component B already occupies `rowPosition = 1`.
2. **Cascade Shift (Push Down)**: If a collision exists, Component B is mutated to `rowPosition = 2`. The check repeats recursively for row 2, cascading conflicts downwards until an empty slot is found.
3. **Array Sorting**: The mutated, collision-free list is mathematically sorted (`.sort(...)`) and emitted to the UI state.

### 2. Hydration & Storage System (SQLite Integration)
Rather than overloading key-value preferences, we will leverage our established `sqflite` FFI pipeline:
- **Schema Expansion**: In `database_service.dart`, expand the `_createDB` method to build a `layout_manifest` table holding `id` (UUID) and `row_position` (INTEGER).
- **Hydration Bridge**: `LayoutBloc` will initialize by executing `SELECT * FROM layout_manifest`. If the table is empty, it will fall back to the initial `defaultManifest` list and instantly save it to SQLite.
- **Auto-Commit**: The cascade algorithm will conclude with a bulk SQL `UPDATE` to permanently store the new layout coordinates to disk.

### 3. Control UI Panel Integration
- **Settings Row Expansion**: Inside `settings_control_row.dart`, we will construct a secondary vertical block under the configuration panel.
- **Directional Triggers**: Since the widgets are strictly UUID-bound, we will loop over the active `LayoutBloc` state array and render a small directional keypad (Up/Down arrows) for each semantic widget tag. 
- **Parameterless Execution**: Clicking an arrow simply dispatches `ShiftComponentUpEvent(uuid)` to the `LayoutBloc`, keeping the control UI fully parameterless and isolated from raw array logic.

## User Review Required

> [!IMPORTANT]
> **Database Migration:** Altering `_createDB` in `database_service.dart` will not automatically trigger for users with an existing `telemetry.db` file unless we increment the `version` integer in `openDatabase` and implement `onUpgrade`. I will handle this explicitly in the code.

Please review this implementation plan. I will not proceed with execution until I receive your explicit approval.

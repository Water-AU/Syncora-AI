# Syncora AI: Phase B Walkthrough

This walkthrough outlines the structural upgrades implemented during the Phase B deployment. The layout matrix is now fully dynamic, persisted securely to SQLite, and mutation-ready.

## Structural Execution Summary

### 1. The Layout BLoC & Algorithm Core
We constructed a new immutable state machine (`LayoutBloc`) mapped over `layout_event.dart` and `layout_state.dart`. 
When a user mutates a component's target index:
- The Bloc loads the raw UUID list from the `layout_manifest` SQLite table corresponding to the destination `AppScreen`.
- A recursive cascade loop shifts conflicting items (pushing them down +1 row) until a structural gap is found.
- The isolated screen array is sorted and saved simultaneously as an atomic transaction.
- The UI triggers an asynchronous reload.

### 2. SQLite Database Integrity
The `database_service.dart` file has been aggressively upgraded to Version 2.
- An `onUpgrade` script injected the `layout_manifest` table into the active SQLite file on Windows.
- It strictly enforces the composite `PRIMARY KEY (screen_uuid, row_position)` and a `UNIQUE (object_uuid)` lock to protect against layout corruption.
- Layout transactions now clear out matching UUIDs before inserting the newly shifted mapping, safely mitigating cascade collision faults at the database level.

### 3. Dynamic Dropdown UI Integration
As requested in the final amendment, the legacy arrow keypads were scrapped.
- `SettingsControlRow` now includes an expanding GlassPanel mapping out every active widget globally.
- Each widget is assigned a **Target Screen** dropdown (AppScreen.home, AppScreen.diet, etc.) and a **Vertical Row Index** dropdown (Rows 0-9).
- Modifying either dropdown triggers a clean, parameterless `ShiftComponentLayout` event, instantly pushing the mutation across the system.

> [!TIP]
> Try shifting the `InterceptBanner` to Row 5, or move `ArcGauge` completely off the home screen onto `AppScreen.ai` using the settings panel. The layout will gracefully hot-swap!

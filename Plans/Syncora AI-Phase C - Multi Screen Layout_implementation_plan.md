# Syncora AI: Phase C Stage-0 — Multi-Screen Layout Matrix

This document provides a forensic audit of the current application state and proposes a step-by-step integration blueprint to implement a dynamic multi-screen layout matrix.

## Part 1: Forensic As-Is Multi-Screen Navigation Audit

### 1. The Core Navigation Router
**Finding:** Currently, there is **no core navigation router** implemented. 
- In `lib/main.dart`, the `MaterialApp`'s `home` property is hardwired directly to `PaletteDashboardPage(initialAudience: initialAudience)`.
- There is no app shell, `NavigationRail`, `BottomNavigationBar`, or `PageController` managing tab shifts or routing state.

### 2. Canvas Screen Routing Pathways
**Finding:** The primary canvas, `PaletteDashboardPage` (`lib/features/palette/presentation/pages/palette_dashboard_page.dart`), is **hardwired to only display the Home screen layout**.
- It does **not** accept an `AppScreen` configuration parameter in its constructor.
- Inside its `initState()`, it emits a static event to the BLoC: `context.read<LayoutBloc>().add(LoadLayoutManifest(AppScreen.home));`.

### 3. Seeding Verification
**Finding:** The seeding mechanism in `LayoutBloc` (`lib/core/bloc/layout/layout_bloc.dart`) is **fully functional**.
- When an unseeded screen (e.g., `AppScreen.diet`) is requested, the bloc checks `if (dbLayouts.isEmpty)`.
- If true, it automatically filters the `defaultManifest` to find default widgets associated with `event.targetScreen`.
- It maps these default items and executes a sweep, seeding them into SQLite via `DatabaseService.instance.saveLayoutBatch(batch);`.

---

## Part 2: Proposed Step-by-Step Multi-Screen Binding Plan

### 1. Parameterized Canvas Architecture
To transform `PaletteDashboardPage` into a dynamic, parameterized canvas:
1. **Refactor Constructor:** Add `final AppScreen activeScreen;` to `PaletteDashboardPage`'s constructor.
2. **Dynamic Initialization:** Update `initState()` to dispatch `LoadLayoutManifest(widget.activeScreen)`.
3. **Lifecycle Binding:** Implement `didUpdateWidget(covariant PaletteDashboardPage oldWidget)` to dispatch a new `LoadLayoutManifest(widget.activeScreen)` event whenever the parent shell passes in a new `AppScreen`, triggering a smooth, animated cache refresh.
4. **Dynamic Header:** Update the `AppBar` title to dynamically reflect the active screen (e.g., based on `widget.activeScreen.name`).

### 2. Application Navigation Rail Bindings
To implement the structural app shell and route tab shifts:
1. **Create App Shell:** Scaffold a new file `lib/features/shell/presentation/pages/app_shell.dart`.
2. **Implement Shell State:** Create a `StatefulWidget` that maintains a local `int _selectedIndex` referencing the active `AppScreen`.
3. **Construct NavigationRail:** Build a `Row` containing a `NavigationRail` on the left and an `Expanded` body on the right. 
4. **Map Destinations:** Populate the `NavigationRail` with destinations mapping sequentially to `AppScreen` values (e.g., Home, Diet, Activity).
5. **Connect Rail to Canvas:** The `Expanded` body will render the parameterized `PaletteDashboardPage(activeScreen: AppScreen.values[_selectedIndex])`. 
6. **Update Entry Point:** Modify `lib/main.dart` to boot into `AppShell` instead of `PaletteDashboardPage`.

### 3. Pre-Execution Governance Validation
To ensure perfect compliance with existing architecture guardrails:
1. **Code Execution:** Execute the structural file additions and modifications cleanly, adhering to the bloc pattern and presentation boundaries.
2. **Audit Verification:** Prior to finalizing the feature, execute `dart bin/architecture_audit.dart` in the terminal.
3. **Remediation:** If the audit flags any dependency inversion or boundary violations, remediate them immediately until a 100% compliance rate is achieved. 

> [!CAUTION]
> As per the Stage-0 directive, no files have been created or modified yet. Please review this blueprint and provide official approval before execution begins.

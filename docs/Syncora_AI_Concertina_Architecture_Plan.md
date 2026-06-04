# Syncora AI Concertina Architecture Plan

## PART 1: THE AS-IS STATE FORENSIC AUDIT

### 1. The Row Rendering Loop (`palette_dashboard_page.dart`)
Currently, `PaletteDashboardPage` builds the active layout using a flat `ListView.builder`. 
- **Iteration:** It iterates over `homeWidgets` (extracted from `state.screenLayouts[widget.activeScreen]`).
- **Row Positioning:** It ignores the actual semantic `item.rowPosition` parameter for grouping. Instead, it natively renders every single item sequentially as a vertical block, explicitly labeling it using the list's raw sequential `index` (e.g., `_SectionHeader(title: 'Row $index: ...')`). Multiple widgets sharing a row index would currently just render as stacked vertical rows, ignoring the horizontal intent.

### 2. The Layout Management State (`layout_bloc.dart` & `layout_state.dart`)
- **State Map:** `LayoutState` holds `Map<AppScreen, List<LayoutManifestItem>> screenLayouts`. 
- **Collision Push-Down:** Inside `_onShiftComponentLayout` in `layout_bloc.dart`, there is strict cascade logic to enforce a 1:1 widget-to-row ratio. If an item is moved to an occupied `rowPosition`, the BLoC intercepts the collision, increments the `currentInsertionRow`, and programmatically pushes the occupying widget (and all subsequent widgets) down to `newRowPosition + 1`. This actively prevents items from ever sharing a row pool.

### 3. The Control Subsystem (`settings_control_row.dart`)
- **Dropdown Logic:** The control subsystem loops over `defaultManifest` and searches `state.screenLayouts.values` to locate each item's current screen and `rowPosition`.
- **Mutation:** It provides a 0-9 Dropdown. When mutated, it dispatches `ShiftComponentLayout`. Because of the BLoC collision logic mentioned above, attempting to group items via the UI currently just triggers a vertical cascade shift.

---

## PART 2: THE MULTI-WIDGET CONCERTINA IMPLEMENTATION PLAN

### 1. The Row-Grouping Strategy
To resolve the flat vertical stack without altering the SQLite schema, we will dynamically map the arrays in the UI layer.
* **BLoC Refactor:** First, we must delete the collision "push-down" cascade block inside `_onShiftComponentLayout`. We will allow multiple SQLite rows to natively share the exact same `rowPosition` integer.
* **UI Grouping:** Inside `palette_dashboard_page.dart`, before rendering the `ListView.builder`, we will execute a collection partitioning algorithm (e.g., `groupBy`) to fold the flat `List<LayoutManifestItem>` into a `Map<int, List<LayoutManifestItem>>` keyed explicitly by `rowPosition`. The `ListView` will then iterate over these unique row keys rather than raw items.

### 2. The Concertina Component Architecture
We will introduce a new `RowConcertinaContainer` widget to handle arrays of items sitting on the same row key.
* **Structure:** The widget will take a `List<LayoutManifestItem>` array. 
* **Single Item:** If the array length is 1, it renders the component full-width exactly as it does today.
* **Overflow Handling (Concertina):** If the array has multiple items, we will implement an adaptive `ExpansionTile` or a horizontal `Wrap` combined with an `AnimatedCrossFade`. 
* **Layout:** A horizontal accordion layout will be built using a parent `Row` with flexible child bounds (`Expanded`). To prevent UI squishing on desktop resizing, users will be able to expand or collapse sibling containers to grant primary focus to a specific chart while hiding the others behind a "View Sibling Widgets" toggle button.

### 3. The Settings Integrity Guard
By removing the BLoC cascade logic, shifting a widget to Row 1 via `settings_control_row.dart` will now seamlessly join the widget into the existing Row 1 collection pool. 
* **Integrity Guard:** We will ensure `settings_control_row.dart` pulls the active `rowPosition` correctly even when grouped. The `ShiftComponentLayout` event will cleanly update just the targeted SQLite row's `rowPosition` integer, and upon the automated BLoC refresh, the `PaletteDashboardPage` will automatically fold it into the horizontal Concertina grouping for that row.

### 4. The Verification & Gate Milestones
* **Milestone 1 (Data Layer):** Verify that multiple items can share a `rowPosition` integer in the `telemetry.db` SQLite file without throwing unique constraint exceptions.
* **Milestone 2 (State Logic):** Programmatically run `dart bin/architecture_audit.dart` to verify no decoupled dependencies were broken during the BLoC cascade removal.
* **Milestone 3 (UI Rendering):** Assign the `ActivityTrendTimeline` and `NutrientConsumptionHistory` to `Row 1` on the Home Canvas. Visually verify the `RowConcertinaContainer` mounts and successfully renders them horizontally with an adaptive overflow collapse mechanism.

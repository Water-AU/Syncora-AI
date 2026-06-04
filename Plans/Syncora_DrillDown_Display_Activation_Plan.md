# Syncora AI: Drill-Down Display Activation Plan

## PART 1: THE DASHBOARD SWITCHER AUDIT

### 1. The Body Render Loop
**Current Behavior:**
In `lib/features/palette/presentation/pages/palette_dashboard_page.dart`, the main `BlocBuilder<LayoutBloc, LayoutState>` unconditionally folds and groups the `state.screenLayouts` list by row index and paints them in a `ListView.builder`. It completely ignores `state.activeDrillDownPaths[widget.activeScreen]`. Thus, when a path is activated by a gesture, the BLoC state accurately records the depth coordinate mutation in the background, but the presentation tree ignores it and continues rendering the top-level chart dashboard.

### 2. The Breadcrumb Placement
**Current Status:**
The `BreadcrumbNavigator` widget was successfully authored in a previous turn, but it is currently **not mounted anywhere** inside the `PaletteDashboardPage` render tree.

---

## PART 2: THE REUSABLE DETAIL VIEW PLAN

### 1. The Dashboard Conditional View Switcher
We will refactor the root `BlocBuilder` inside `PaletteDashboardPage` into a strict conditional rendering branch:
- Extract the active criteria stack: `final activePath = state.activeDrillDownPaths[widget.activeScreen] ?? [];`
- **If `activePath.isNotEmpty` (Drill-Down Mode):**
  - Render a `Column` (or a full-height bounded container).
  - Inject the `BreadcrumbNavigator` at the top of the stack, granting the user a structural UI escape hatch.
  - Beneath it, render a new `GenericDrillDownDetailView` component, passing it the deepest criteria node (`activePath.last`).
- **If `activePath.isEmpty` (Dashboard Mode):**
  - Proceed with the existing `ListView.builder` layout mapping and `RowConcertinaContainer` painting.

### 2. The Generic Terminal Detail Component
**Widget Specification (`generic_drill_down_detail_view.dart`):**
Instead of building custom detailed screens for each graph type, we will author a single universal async table view.

**Implementation Steps:**
1. **Target File:** Create `lib/features/palette/presentation/widgets/generic_drill_down_detail_view.dart`.
2. **Payload Injection:** Accept `final DrillDownCriteria criteria;` via constructor.
3. **Data Hydration (`FutureBuilder`):**
   Wrap the body in a `FutureBuilder<List<Map<String, dynamic>>>` executing:
   ```dart
   DatabaseService.instance.fetchGenericDrillDownData(
     tableName: criteria.tableName, 
     filterColumn: criteria.filterColumn, 
     targetId: criteria.targetId, 
     criteriaType: criteria.criteriaType
   )
   ```
4. **Dynamic Dense Rendering:** 
   - While resolving: Display a themed `CircularProgressIndicator`.
   - On empty result: Display an empty state placeholder.
   - On success: Extract the keys from the first row and dynamically paint a responsive, desktop-density `DataTable` or `ListView` showing all underlying key-value SQLite properties cleanly formatted.

### 3. Execution Target Map
- **Target 1:** `lib/features/palette/presentation/pages/palette_dashboard_page.dart` (Refactor view switcher & mount Breadcrumb)
- **Target 2:** `lib/features/palette/presentation/widgets/generic_drill_down_detail_view.dart` (New File creation)

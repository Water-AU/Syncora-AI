# Syncora AI: Recursive Drill-Down Architecture — Phase 1: Audit & Blueprint

## PART 1: THE RECURSIVE ARCHITECTURE AUDIT

### 1. The Navigation Pipeline Audit (`layout_state.dart`)
**Current State Analysis:**
Presently, `LayoutState` only maps `AppScreen` keys to a flat `List<LayoutManifestItem>` array. It has no structural memory of relational depth or hierarchical traversal.
**Proposed Architecture:**
We will introduce an immutable tracking dictionary: 
```dart
final Map<AppScreen, List<String>> activeDrillDownPaths;
```
This isolates the traversal history *per screen*. If a user drills down three levels deep into a tenant structure on the `Home` screen, but switches to `Profile`, their `Home` depth coordinate is perfectly preserved in the map without interfering with `Profile`'s root-level view.

### 2. The Database Traversal Footprint (`database_service.dart`)
**Current Schema Analysis:**
Currently, `DatabaseService` handles flat reads for `telemetry_logs` and `layout_manifest`. It lacks a relational query pipeline for self-referencing hierarchy exploration.
**Proposed Query Mechanics:**
We will engineer an asynchronous structural lookup method that targets a self-referencing relational schema (where records possess a `parent_id` matching a parent's primary UUID). 
```dart
Future<bool> hasDescendants(String nodeId) async {
  final db = await instance.database;
  final result = await db.rawQuery(
    'SELECT COUNT(*) as child_count FROM entity_hierarchy WHERE parent_id = ?', 
    [nodeId]
  );
  int count = (result.isNotEmpty ? result.first['child_count'] as int? : 0) ?? 0;
  return count > 0;
}
```
This fast boolean check allows the UI to dynamically decide whether to render a "Drill Down" chevron icon (if children exist) or a "View Record Details" terminal action (if it is a granular leaf node).

---

## PART 2: THE RECURSIVE ROUTING IMPLEMENTATION PLAN

### 1. The State Modification
**Event Dispatchers (`layout_event.dart`):**
We will introduce two precise structural mutation events to control depth coordinates safely:
```dart
class PushDrillDownNode extends LayoutEvent {
  final AppScreen activeScreen;
  final String nodeId;
  PushDrillDownNode({required this.activeScreen, required this.nodeId});
}

class PopDrillDownNode extends LayoutEvent {
  final AppScreen activeScreen;
  PopDrillDownNode({required this.activeScreen});
}
```
**State Reducers (`layout_bloc.dart`):**
The BLoC will handle these events by cloning the `activeDrillDownPaths` map, extracting the specific `List<String>` array for the requested screen, and applying standard list mutations (`.add()` or `.removeLast()`). The layout concertinas remain strictly isolated because the `screenLayouts` map is untouched during drill-down events.

### 2. The Contextual Breadcrumb Presentation
**UI Implementation Strategy:**
We will inject a compact, high-density Breadcrumb Row at the top of deep-diving panels.
- It will subscribe to `BlocBuilder<LayoutBloc, LayoutState>` and extract the active screen's path array.
- It will render as a horizontally scrolling `ListView` or `Wrap` with separator chevrons (`Icon(Icons.chevron_right)`).
- **Navigation:** Each intermediate breadcrumb node will be wrapped in an `InkWell`. Clicking an ancestor will calculate the depth delta and sequentially fire `PopDrillDownNode` events until the UI gracefully resurfaces to the targeted ancestor tier.

### 3. The Step-by-Step Files & Lines Target Map
1. **`lib/core/bloc/layout/layout_state.dart`**
   - Inject `activeDrillDownPaths` dictionary, update constructor, and expand `copyWith` parameters.
2. **`lib/core/bloc/layout/layout_event.dart`**
   - Define `PushDrillDownNode` and `PopDrillDownNode` events.
3. **`lib/core/bloc/layout/layout_bloc.dart`**
   - Bind handlers for the new structural events. Execute immutable array manipulation against the specific active screen's path.
4. **`lib/core/database/database_service.dart`**
   - Inject the recursive `hasDescendants(String nodeId)` fast lookup validation method.
5. **`lib/features/palette/presentation/widgets/breadcrumb_navigator.dart` (New Component)**
   - Author a new stateless micro-widget that renders the horizontal path array and dispatches depth-pop operations.

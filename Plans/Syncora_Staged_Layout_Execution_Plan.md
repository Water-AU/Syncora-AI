# Syncora AI: Staged Layout Transactions & Micro-Commit UI — Phase 1: Audit & Blueprint

## PART 1: THE DISCOVERY AUDIT & INTERFACE ANALYSIS

### 1. The Instant-Mutation Ingestion Pass (`settings_control_row.dart`)
**Current Architecture:** 
Inside the `_buildLayoutManager` loop, the active screen and row position are manipulated via `DropdownButton<AppScreen>` and `DropdownButton<int>`. 
Currently, their `onChanged` closures execute:
```dart
context.read<LayoutBloc>().add(ShiftComponentLayout(
  objectUuid: manifestItem.id,
  newScreen: newScreen,
  newRowPosition: currentLayoutItem.rowPosition,
  currentScreen: widget.activeScreen,
));
```
**Forensic Findings:** 
This direct invocation triggers an immediate SQLite transaction and UI cache eviction. Every minor adjustment (e.g., just exploring a different screen option without intending to confirm) instantly shifts the component. This causes a jittery user experience where the UI immediately unmounts the component under adjustment, interrupting the user's flow.

### 2. The Layout Sizing Footprint
**Interface Constraints:**
The matrix engine maps out a `Padding` wrapped `Row` for each component, structured with:
- `Expanded(flex: 2)` for the component's `debugTag` text label.
- `SizedBox(width: 16)` for horizontal breathing room.
- `Expanded(child: DropdownButton<AppScreen>)` for target screen switching.
- `SizedBox(width: 16)` separator.
- `Expanded(child: DropdownButton<int>)` for row target indexing.

**Conclusion:** 
The row currently operates with balanced `Expanded` components. There is ample room at the trailing edge to append an un-expanded `IconButton` or compact `InkWell` to serve as the targeted micro-commit trigger without breaking the responsive `Wrap` thresholds.

---

## PART 2: THE STAGED SANDBOX IMPLEMENTATION PLAN

### 1. The Local Sandbox State Integration
**State Management Patch (`settings_control_row.dart`):**
Because `_SettingsControlRowState` is already a `StatefulWidget`, we will introduce a local sandbox dictionary to stage modifications independently from the BLoC cache.
```dart
// The local sandbox capturing uncommitted layout mutations
final Map<String, LayoutManifestItem> _stagedLayouts = {};
```
- In the `ListView`/`Column` mapper, the dropdown values will derive from `_stagedLayouts[manifestItem.id]` if an active edit exists. If the map misses, it will fallback to reading the `LayoutBloc` state tree.
- The `onChanged` events on the dropdowns will be severed from the BLoC `add()` dispatcher. Instead, they will securely mutate the `_stagedLayouts` cache and trigger a fast local `setState()`, allowing users to adjust properties synchronously.

### 2. The Micro-Commit Button Design
**UI Component Injection:**
We will inject a compact, visually discrete trigger at the trailing edge of each layout configuration row.
```dart
bool hasUnsavedChanges = _stagedLayouts.containsKey(manifestItem.id);

IconButton(
  icon: Icon(
    Icons.check_circle_outline, 
    color: hasUnsavedChanges ? theme.primaryAccent : theme.textPrimary.withValues(alpha: 0.3)
  ),
  onPressed: hasUnsavedChanges ? () {
    final staged = _stagedLayouts[manifestItem.id]!;
    context.read<LayoutBloc>().add(ShiftComponentLayout(
      objectUuid: staged.id,
      newScreen: staged.targetScreen,
      newRowPosition: staged.rowPosition,
      currentScreen: widget.activeScreen,
    ));
    setState(() => _stagedLayouts.remove(manifestItem.id));
  } : null,
  tooltip: 'Commit Layout Shift',
)
```
This forces user confirmation for structural mutations, ensuring a completely stable UX envelope.

### 3. The Global Seeding Fix & Ghost Extinction
**Database Audit Guard (`layout_bloc.dart`):**
Inside `_onLoadLayoutManifest`, before pushing an assumed "missing item" back to the SQLite initialization batch, we will inject a global verification barrier:
```dart
final missingItems = <LayoutManifestItem>[];
for (final defaultItem in defaultForScreen) {
  if (!dbLayouts.any((row) => row['object_uuid'] == defaultItem.id)) {
    // Perform a global check across the whole database
    final db = await DatabaseService.instance.database;
    final globalSearch = await db.query(
      'layout_manifest', 
      where: 'object_uuid = ?', 
      whereArgs: [defaultItem.id],
    );
    if (globalSearch.isEmpty) {
      missingItems.add(defaultItem);
    }
  }
}
```
This strictly enforces data normalization. A component will only be auto-seeded if it is confirmed absolutely devoid across the *entire* schema, permanently closing the ghost duplication loophole.

### 4. The Step-by-Step Files & Lines Target Map
1. **Target 1:** `lib/features/palette/presentation/widgets/settings_control_row.dart`
   - **Boundary:** Inside `_SettingsControlRowState`.
   - **Action:** Add `_stagedLayouts` map. Modify `_buildLayoutManager` dropdown bindings to prioritize reading the local sandbox cache. Reprogram `onChanged` closures to trigger `setState`. Inject the trailing `IconButton`.
2. **Target 2:** `lib/core/bloc/layout/layout_bloc.dart`
   - **Boundary:** Inside `_onLoadLayoutManifest`, immediately preceding the batch initialization loops.
   - **Action:** Refactor the `missingItems` higher-order `.where()` iteration into a dedicated `for` loop housing an async global SQLite `query()` assertion.

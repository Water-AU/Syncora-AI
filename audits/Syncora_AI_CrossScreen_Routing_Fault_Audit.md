# Syncora AI: Cross-Screen Routing Fault Forensic Audit

## SECTION 1: THE EVENT INGESTION MECHANICS (AS-IS DROP-DOWN TRACE)

### 1. The Screen Target Dropdown `onChanged` Block
File: `lib/features/palette/presentation/widgets/settings_control_row.dart` (Lines 220-229)
```dart
                          onChanged: (newScreen) {
                            if (newScreen != null) {
                              context.read<LayoutBloc>().add(ShiftComponentLayout(
                                objectUuid: manifestItem.id,
                                newScreen: newScreen,
                                newRowPosition: currentLayoutItem.rowPosition,
                                currentScreen: widget.activeScreen,
                              ));
                            }
                          },
```

### 2. Parameter Trace Analysis
The ingestion parameters are passed flawlessly. The `newScreen` payload successfully captures the newly selected `AppScreen` enum value from the dropdown, and `targetScreen` is accurately dispatched to the `LayoutBloc`.

---

## SECTION 2: THE BLOC TRANSACTION AND SQL MUTATION TRACE

### 1. The SQLite Transaction Query Builder
File: `lib/core/bloc/layout/layout_bloc.dart` (Lines 147-153)
```dart
    // 4. Save the mutated array back to DB
    final batch = mutatedItems.map((item) => {
      'screen_uuid': item.targetScreen.uuid,
      'object_uuid': item.id,
      'row_position': item.rowPosition,
    }).toList();
    await DatabaseService.instance.saveLayoutBatch(batch);
```

### 2. SQL Execution & Schema Analysis
File: `lib/core/database/database_service.dart` (Lines 180-189)
```dart
    await db.transaction((txn) async {
      // Temporarily remove to avoid unique constraint collisions during the cascade
      for (final item in batch) {
        await txn.delete('layout_manifest', where: 'object_uuid = ?', whereArgs: [item['object_uuid']]);
      }
      for (final item in batch) {
        await txn.insert('layout_manifest', item);
      }
    });
```
**Analysis:** There is no database failure. The `screen_uuid` is being correctly serialized and explicitly written back to the SQLite schema via the transactional `DELETE` and `INSERT` operation. The data is successfully persisting to the new target screen.

---

## SECTION 3: THE MAP HYDRATION STATE RECONCILIATION

### 1. Global Map Re-hydration Logic
File: `lib/core/bloc/layout/layout_bloc.dart` (Line 158)
```dart
    // 5. If we're viewing the screen that was just mutated, or we pulled an item off the current screen, reload!
    // Easiest is to just ask the BLoC to reload whatever screen is currently being displayed.
    // We can fetch the target screen from the current layout state if it has items.
    add(LoadLayoutManifest(event.currentScreen));
```

### 2. State Partitioning Flaw
The BLoC is strictly triggering a database re-fetch **only for the `event.currentScreen` channel**. The target `event.newScreen` is completely neglected during the state emission. As a result, the freshly updated layout for the target screen is never pulled from the database, leaving its memory partition un-hydrated and stale.

---

## SECTION 4: THE ARCHITECTURAL ROOT-CAUSE SENTENCING

### 1. The Exact Failure Point
* **File:** `lib/core/bloc/layout/layout_bloc.dart`
* **Line Number:** 158
* **Faulty Statement:** `add(LoadLayoutManifest(event.currentScreen));`

### 2. Root-Cause Explanation
When a user shifts a component to a different screen, the database successfully records the move. However, because the BLoC only re-hydrates the state of the *current* screen (`event.currentScreen`), the item is wiped from the current screen's memory cache, but the *new* screen's memory cache (`event.newScreen`) is never updated to include it.

When the `SettingsControlRow` rebuilds, it loops through `state.screenLayouts.values` to find the component. Because the component was purged from the active screen's cache but never loaded into the new screen's cache, it cannot be found anywhere in memory. 

As a fallback, the UI logic (`final currentLayoutItem = foundItem ?? manifestItem;`) defaults to reading the hardcoded `defaultManifest`. This causes the dropdown to visually "snap back" to the component's original default screen, making it appear as though the move failed. 

**Why Row Index Shifts Succeed:** Row shifts work perfectly because `newScreen == currentScreen`. When the BLoC re-hydrates `currentScreen`, it successfully pulls the updated row index from the database back into the memory cache, preventing the fallback logic from triggering.

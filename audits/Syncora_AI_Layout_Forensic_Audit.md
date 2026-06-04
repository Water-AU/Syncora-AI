# Syncora AI: Layout Hydration Forensic Audit

This document contains a comprehensive line-by-line verification pass of the layout hydration pipeline to diagnose why the dashboard canvases are rendering completely empty despite a successful database transfer.

## 1. LINE-BY-LINE FILE TRACING

### Database Service (`database_service.dart`)
**Logic Analysis:**
The `DatabaseService` correctly initializes the FFI path, successfully retrieves the `telemetry.db` via `getApplicationSupportDirectory()`, and copies the legacy file. The queries run perfectly on boot, and the physical table contains all valid layout rows. The database layer is **healthy and fully operational**.

### Layout Bloc (`layout_bloc.dart`)
**Logic Analysis:**
In `_onLoadLayoutManifest`, the bloc requests rows from SQLite based on `event.targetScreen.uuid`. 
```dart
final dbLayouts = await DatabaseService.instance.loadLayout(event.targetScreen.uuid);
// ... maps to activeLayout and then emits:
emit(state.copyWith(currentLayout: activeLayout, isLoading: false));
```
Crucially, if a screen has zero default components in `defaultManifest` and zero rows in SQLite (e.g., `AppScreen.profile`), this block successfully completes and correctly emits an **empty array `[]`** as the `currentLayout`.

There is a fatal silent exception trap present:
```dart
} catch (e) {
  emit(state.copyWith(isLoading: false));
}
```
However, this is a red herring. The code isn't actually throwing an SQL exception here; it is running perfectly.

## 2. STATE & TYPE EVALUATION

### Canvas UI Resolver (`palette_dashboard_page.dart`)
**Logic Analysis:**
The mapping block in `_buildManifestComponent` uses strict string `switch` cases that perfectly match the database UUIDs. There are no type-mismatches.

However, the catastrophic failure occurs in the UI State lifecycle:
```dart
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LayoutBloc>().add(LoadLayoutManifest(widget.activeScreen));
    });
  }
```

## 3. LOG CHECK & DEFINITIVE VERDICT

### The Core Failure Point: The Global Singleton Overwrite
The absolute AS-IS state of the layout pipeline reveals a fatal race condition introduced by our recent `IndexedStack` optimization:

1. **The Shared State:** `lib/main.dart` injects exactly **one** global `LayoutBloc` at the root of the app.
2. **The IndexedStack Explosion:** `AppShell` uses an `IndexedStack` which instantiates all 5 `PaletteDashboardPage` instances simultaneously on boot to keep them alive in memory.
3. **The Race Condition:** Because all 5 canvases are built instantly, they **all** fire their `initState()` simultaneously, queuing 5 separate `LoadLayoutManifest` events into the exact same global `LayoutBloc`.
4. **The Last-Writer-Wins Collapse:** The BLoC sequentially resolves Home, Activity, AI, Diet, and finally Profile. 
5. **The Empty Screen:** Because `AppScreen.profile` currently has 0 seed components in `defaultManifest`, the BLoC's final operation is resolving and emitting `currentLayout: []`.
6. **The Result:** All 5 alive canvas screens are listening to the exact same global state variable. They all receive the final state update (`[]`) from the Profile tab, instantly wiping every single canvas blank.

**Verdict:** 
The database migration was a 100% success. The layout engine is failing because a single global BLoC is being concurrently overwritten by an `IndexedStack` mounting 5 parameterized canvases at once. A structural refactoring of how the `LayoutBloc` scopes state per-screen is required.

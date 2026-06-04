# Syncora AI: Dual-Channel Screen Hydration Fix Execution Plan

## Pre-Flight Forensic Audit Confirmation
- Successfully located `layout_bloc.dart` Line 158. The statement is exactly `add(LoadLayoutManifest(event.currentScreen));`.
- Confirmed that there is currently **no** companion dispatch loading the layout manifest for the `event.newScreen` destination.

## Step-by-Step Implementation Plan

### 1. Dual-Channel State Hydration Refactor (layout_bloc.dart)
To correct the cross-screen migration bug, we must explicitly ensure that both the origin (source) and destination (target) screen buckets are refreshed from SQLite following a mutation.

**Code Alteration:**
I will replace the singular event dispatch at the end of `_onShiftComponentLayout` with a dual dispatch:
```dart
    // Dual-Channel State Hydration Refactor
    add(LoadLayoutManifest(event.currentScreen)); // Evicts the component from the source screen map cache
    add(LoadLayoutManifest(event.newScreen));     // Explicitly hydrates the destination screen map cache
```

### 2. Validating Settings UI Map Search Integration (settings_control_row.dart)
The current configuration loop inside `_buildLayoutManager` executes a map iteration over all available screen buckets:
```dart
for (final layouts in state.screenLayouts.values) {
  try {
    foundItem = layouts.firstWhere((item) => item.id == manifestItem.id);
    break;
  } catch (_) {}
}
```
**Assertion Safety Check:** By explicitly hydrating `event.newScreen`, the new array of `LayoutManifestItem` objects will be successfully inserted into `state.screenLayouts`. As the `for` loop dynamically queries `.values`, it will organically find the newly hydrated destination map bucket and retrieve the correct, newly migrated component reference without requiring a structural modification to the UI widget itself. The fallback to the hardcoded `defaultManifest` will be naturally bypassed.

### 3. Verification & Compliance
Following the patches, I will execute `flutter pub run bin/architecture_audit.dart` to verify zero regressions.

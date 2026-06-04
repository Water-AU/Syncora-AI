# Syncora AI: Cross-Screen Layout Routing — Phase 1: Audit & Implementation Blueprint

## PART 1: THE AS-IS DISCOVERY AUDIT

### 1. The State Map Querying Loop (`settings_control_row.dart`)
**Raw Code Snippet:**
```dart
                LayoutManifestItem? foundItem;
                for (final layouts in state.screenLayouts.values) {
                  try {
                    foundItem = layouts.firstWhere((item) => item.id == manifestItem.id);
                    break;
                  } catch (_) {}
                }
                final currentLayoutItem = foundItem ?? manifestItem;
```
**Forensic Analysis:**
The configuration loop blindly searches all hydrated screen maps inside `state.screenLayouts.values` and executes a hard `break` on the very first match it discovers. Because Flutter `Map.values` iteration order is often sequence-dependent based on hydration timing, if a ghost duplicate exists on the `Home` screen, the loop will hit the `Home` map first, find the duplicate, and break. This completely ignores the `widget.activeScreen` context and forces the dropdown to permanently display the ghost instance's original location (e.g., Home Row 6) rather than reflecting the component's true migrated target screen.

### 2. The Database Manifest Seeding Guard (`layout_bloc.dart`)
**Raw Code Snippet:**
```dart
        final defaultForScreen = defaultManifest.where(
          (item) => item.targetScreen == event.targetScreen,
        );
        final missingItems = defaultForScreen
            .where(
              (defaultItem) =>
                  !dbLayouts.any((row) => row['object_uuid'] == defaultItem.id),
            )
            .toList();
```
**Forensic Analysis:**
The BLoC is designed to auto-seed missing widgets (to support OTA UI updates and newly released components). However, its "missing" verification is fiercely localized—it strictly checks if the component is missing from *the current screen's* local `dbLayouts` partition. If a user migrates a component (e.g., from `Home` to `Profile`), the item is intentionally deleted from the `Home` SQLite rows. When the BLoC subsequently re-hydrates `Home`, it correctly notices the default widget is missing from `Home`'s database payload, wrongly flags it as a "new missing item", and forcefully re-inserts a ghost duplicate back into the `Home` database table.

---

## PART 2: THE IS-TO-BE RESOLUTION PLAN

### 1. The Context-Aware Dropdown Fix
**Refactoring Strategy (`settings_control_row.dart`):**
We will rewrite the lookup loop to become context-aware. Instead of instantly executing a global sweep, the logic will first interrogate the active canvas the user is viewing via `state.screenLayouts[widget.activeScreen]`. If the item is present on the active canvas, it will prioritize and lock onto that contextual instance. Only if it is explicitly missing from the active screen will it gracefully fallback to searching sibling screen maps to locate where it was migrated.

### 2. The Clean Migration Transaction
**Refactoring Strategy (`layout_bloc.dart`):**
We will harden the missing item verification inside `_onLoadLayoutManifest`. Before committing a widget to the `missingItems` batch for auto-seeding, we will execute a global SQLite validation query:
```dart
SELECT COUNT(*) FROM layout_manifest WHERE object_uuid = ?
```
If the object ID already exists anywhere in the database (even on a different screen target), the global count will be > 0, and the BLoC will intelligently skip the seeding operation. This guarantees absolute data normalization and completely eradicates ghost duplication loops during cross-screen migrations.

### 3. The Verification & Compliance Gates
1. **Compilation Audit:** Programmatically run `flutter pub run bin/architecture_audit.dart` to verify zero syntactical regressions and achieve a 100% boundary score.
2. **Settings Registry Test:** Manually migrate the "System Administration" block from `Home` to `Profile`.
3. **Database Assertion Check:** Verify the UI dropdown instantly updates to `Profile`. Navigate back to `Home` and confirm the BLoC does not auto-seed a duplicate block. The item must remain safely isolated on the `Profile` canvas without generating a ghost layout on `Home`.

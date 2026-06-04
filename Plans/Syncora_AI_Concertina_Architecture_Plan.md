# Syncora AI: Forensic AS-IS Code Extraction & Concertina Implementation Blueprint

## PHASE 1: THE AS-IS STATE FORENSIC CODE AUDIT

### 1. THE BLOC CASCADE REGULATION ROUTINE
File: `lib/core/bloc/layout/layout_bloc.dart`

```dart
    // 3. Cascade Logic (Push Down)
    // We want to insert movingItem at newRowPosition. If occupied, push the occupier to newRowPosition + 1
    targetScreenItems.sort((a, b) => a.rowPosition.compareTo(b.rowPosition));
    
    int currentInsertionRow = event.newRowPosition;
    List<LayoutManifestItem> mutatedItems = [];
    mutatedItems.add(movingItem!);

    for (final item in targetScreenItems) {
      if (item.rowPosition < currentInsertionRow) {
        mutatedItems.add(item);
      } else if (item.rowPosition == currentInsertionRow) {
        // Collision! Push it down.
        currentInsertionRow++;
        mutatedItems.add(LayoutManifestItem(
          id: item.id,
          debugTag: item.debugTag,
          targetScreen: item.targetScreen,
          rowPosition: currentInsertionRow,
        ));
      } else {
        // Gap exists, we can safely keep its row
        mutatedItems.add(item);
        currentInsertionRow = item.rowPosition;
      }
    }
```

### 2. THE VERTICAL LIST COMPONENT BUILDER
File: `lib/features/palette/presentation/pages/palette_dashboard_page.dart`

```dart
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: homeWidgets.length,
              itemBuilder: (context, index) {
                final item = homeWidgets[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index > 0) const SizedBox(height: 24),
                    _buildManifestComponent(item, index),
                  ],
                );
              },
            );
```

### 3. THE CONTROL REGISTRY ITERATOR
File: `lib/features/palette/presentation/widgets/settings_control_row.dart`

```dart
            return Column(
              children: defaultManifest.map((manifestItem) {
                LayoutManifestItem? foundItem;
                for (final layouts in state.screenLayouts.values) {
                  try {
                    foundItem = layouts.firstWhere((item) => item.id == manifestItem.id);
                    break;
                  } catch (_) {}
                }
                final currentLayoutItem = foundItem ?? manifestItem;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      // ... [other elements] ...
                      Expanded(
                        child: DropdownButton<int>(
                          value: currentLayoutItem.rowPosition,
                          dropdownColor: theme.baseBackground,
                          isExpanded: true,
                          style: TextStyle(color: theme.textPrimary),
                          items: List.generate(10, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Text('Row $index'),
                            );
                          }),
                          onChanged: (newRow) {
                            if (newRow != null) {
                              context.read<LayoutBloc>().add(ShiftComponentLayout(
                                objectUuid: manifestItem.id,
                                newScreen: currentLayoutItem.targetScreen,
                                newRowPosition: newRow,
                                currentScreen: widget.activeScreen,
                              ));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
```

## PHASE 2: THE MULTI-WIDGET CONCERTINA IMPLEMENTATION PLAN

### 1. THE ROW-PARTITIONING ALGORITHM
**Algorithm Details:**
We will modify the state parsing inside `palette_dashboard_page.dart` prior to returning the `ListView.builder`. Instead of passing the flat `homeWidgets` list directly, we will apply a `fold` operation to group widgets by `rowPosition`, resulting in a `Map<int, List<LayoutManifestItem>>`.
```dart
final groupedWidgets = homeWidgets.fold<Map<int, List<LayoutManifestItem>>>(
  {}, 
  (map, item) {
    (map[item.rowPosition] ??= []).add(item);
    return map;
  }
);
final distinctRows = groupedWidgets.keys.toList()..sort();
```
The `ListView.builder` will then iterate over `distinctRows.length`. This maintains compatibility with the existing SQLite schema, natively supporting multiple widgets under a single integer row ID constraint.

### 2. THE CONCERTINA COMPONENT UI LAYOUT
**Structure Details:**
We will introduce a new `RowConcertinaContainer` widget to replace the plain `Column` in the list builder. It will use a `LayoutBuilder` to assess available horizontal constraints. 
- If the width allows (`constraints.maxWidth > THRESHOLD`), items will be rendered side-by-side using a `Wrap` widget.
- If width is constrained, it will employ an `ExpansionTile` acting as an animated accordion. The primary/first item will act as the collapsed state view (or header), and expanding the tile will reveal the sibling widgets vertically without breaking the layout. 

### 3. THE SETTINGS INTEGRITY GUARD
**Modifications:**
In `settings_control_row.dart`, reading `currentLayoutItem.rowPosition` remains safe as the SQLite database natively stores duplicates. However, the cascading shift logic inside `layout_bloc.dart` must be disabled. When a user selects a row from the dropdown UI, the BLoC will simply update the target item's `rowPosition` without enforcing `currentInsertionRow++` upon collision. This seamlessly pools widgets into shared rows.

### 4. THE VERIFICATION & GATE MILESTONES
1. **Compilation Audit**: Execute `dart bin/architecture_audit.dart` to verify no lint or structural errors were introduced during grouping logic injections.
2. **Settings Registry Test**: Assign "Activity Timeline" and "Nutrient History" to the identical row (e.g., Row 2) via the Settings dropdown. Validate that neither is shifted down to Row 3.
3. **Visual Layout Verification (Desktop)**: Observe the side-by-side layout on the `windows` build target.
4. **Concertina Responsive Check**: Resize the Windows application window horizontally below the multi-widget threshold to confirm the fallback to the `ExpansionTile` accordion.

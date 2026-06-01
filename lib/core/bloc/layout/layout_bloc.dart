import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/database/database_service.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';
import 'layout_event.dart';
import 'layout_state.dart';

class LayoutBloc extends Bloc<LayoutEvent, LayoutState> {
  LayoutBloc() : super(const LayoutState(currentLayout: [])) {
    on<LoadLayoutManifest>(_onLoadLayoutManifest);
    on<ShiftComponentLayout>(_onShiftComponentLayout);
  }

  Future<void> _onLoadLayoutManifest(
    LoadLayoutManifest event,
    Emitter<LayoutState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final dbLayouts = await DatabaseService.instance.loadLayout(event.targetScreen.uuid);
      List<LayoutManifestItem> activeLayout;

      if (dbLayouts.isEmpty) {
        // Fallback to defaults for this screen
        activeLayout = defaultManifest
            .where((item) => item.targetScreen == event.targetScreen)
            .toList();
        
        // Save the defaults to DB
        final batch = activeLayout.map((item) => {
          'screen_uuid': item.targetScreen.uuid,
          'object_uuid': item.id,
          'row_position': item.rowPosition,
        }).toList();
        await DatabaseService.instance.saveLayoutBatch(batch);
      } else {
        // 1. Programmatically check for missing items (like the new BiometricStatusHub)
        final defaultForScreen = defaultManifest.where((item) => item.targetScreen == event.targetScreen);
        final missingItems = defaultForScreen.where(
          (defaultItem) => !dbLayouts.any((row) => row['object_uuid'] == defaultItem.id)
        ).toList();
        
        if (missingItems.isNotEmpty) {
          int maxRow = dbLayouts.isEmpty ? -1 : dbLayouts.map((e) => e['row_position'] as int).reduce((a, b) => a > b ? a : b);

          final batch = missingItems.map((item) {
            maxRow++;
            return {
              'screen_uuid': item.targetScreen.uuid,
              'object_uuid': item.id,
              'row_position': maxRow, // Seed safely at the bottom of the stack to avoid PK collisions
            };
          }).toList();
          await DatabaseService.instance.saveLayoutBatch(batch);
        }
        
        // Reload to include newly seeded items
        final finalDbLayouts = missingItems.isNotEmpty 
            ? await DatabaseService.instance.loadLayout(event.targetScreen.uuid)
            : dbLayouts;

        // Map from DB
        activeLayout = finalDbLayouts.map((row) {
          final id = row['object_uuid'] as String;
          // Find debugTag from default manifest if possible
          final defaultItem = defaultManifest.cast<LayoutManifestItem?>().firstWhere(
            (item) => item!.id == id,
            orElse: () => null,
          );
          return LayoutManifestItem(
            id: id,
            debugTag: defaultItem?.debugTag ?? 'Unknown',
            targetScreen: event.targetScreen,
            rowPosition: row['row_position'] as int,
          );
        }).toList();
      }

      activeLayout.sort((a, b) => a.rowPosition.compareTo(b.rowPosition));
      emit(state.copyWith(currentLayout: activeLayout, isLoading: false));
    } catch (e) {
      // Handle error natively, just stop loading for now
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onShiftComponentLayout(
    ShiftComponentLayout event,
    Emitter<LayoutState> emit,
  ) async {
    // We only mutate if we're currently viewing the affected screen, 
    // or if the component is moving away from the active screen.
    // For structural simplicity, we will fetch the target screen elements from DB,
    // apply cascade logic, save to DB, and then trigger a reload of the current screen.
    
    // 1. Fetch the target screen's current list from DB (to handle cross-screen safely)
    final dbLayouts = await DatabaseService.instance.loadLayout(event.newScreen.uuid);
    List<LayoutManifestItem> targetScreenItems = dbLayouts.map((row) {
      final id = row['object_uuid'] as String;
      final defaultItem = defaultManifest.cast<LayoutManifestItem?>().firstWhere(
        (item) => item!.id == id,
        orElse: () => null,
      );
      return LayoutManifestItem(
        id: id,
        debugTag: defaultItem?.debugTag ?? 'Unknown',
        targetScreen: event.newScreen,
        rowPosition: row['row_position'] as int,
      );
    }).toList();

    // 2. Determine if the object is already on this screen
    LayoutManifestItem? movingItem;
    targetScreenItems.removeWhere((item) {
      if (item.id == event.objectUuid) {
        movingItem = item;
        return true;
      }
      return false;
    });

    if (movingItem == null) {
      // It's coming from a different screen! Find its metadata from defaultManifest
      final defaultItem = defaultManifest.firstWhere((item) => item.id == event.objectUuid);
      movingItem = LayoutManifestItem(
        id: event.objectUuid,
        debugTag: defaultItem.debugTag,
        targetScreen: event.newScreen,
        rowPosition: event.newRowPosition,
      );
    } else {
      movingItem = LayoutManifestItem(
        id: event.objectUuid,
        debugTag: movingItem!.debugTag,
        targetScreen: event.newScreen,
        rowPosition: event.newRowPosition,
      );
    }

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

    // 4. Save the mutated array back to DB
    final batch = mutatedItems.map((item) => {
      'screen_uuid': item.targetScreen.uuid,
      'object_uuid': item.id,
      'row_position': item.rowPosition,
    }).toList();
    await DatabaseService.instance.saveLayoutBatch(batch);

    // 5. If we're viewing the screen that was just mutated, or we pulled an item off the current screen, reload!
    // Easiest is to just ask the BLoC to reload whatever screen is currently being displayed.
    // We can fetch the target screen from the current layout state if it has items.
    if (state.currentLayout.isNotEmpty) {
      add(LoadLayoutManifest(state.currentLayout.first.targetScreen));
    }
  }
}

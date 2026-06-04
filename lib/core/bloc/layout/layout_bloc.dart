import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/database/database_service.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';
import 'layout_event.dart';
import 'layout_state.dart';

class LayoutBloc extends Bloc<LayoutEvent, LayoutState> {
  LayoutBloc() : super(const LayoutState(screenLayouts: {}, activeDrillDownPaths: {})) {
    on<LoadLayoutManifest>(_onLoadLayoutManifest);
    on<ShiftComponentLayout>(_onShiftComponentLayout);
    on<PushDrillDownNode>(_onPushDrillDownNode);
    on<PopDrillDownNode>(_onPopDrillDownNode);
  }

  Future<void> _onLoadLayoutManifest(
    LoadLayoutManifest event,
    Emitter<LayoutState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final dbLayouts = await DatabaseService.instance.loadLayout(
        event.targetScreen.uuid,
      );
      List<LayoutManifestItem> activeLayout;

      if (dbLayouts.isEmpty) {
        // Fallback to defaults for this screen
        activeLayout = defaultManifest
            .where((item) => item.targetScreen == event.targetScreen)
            .toList();

        // Save the defaults to DB
        final batch = activeLayout
            .map(
              (item) => {
                'screen_uuid': item.targetScreen.uuid,
                'object_uuid': item.id,
                'row_position': item.rowPosition,
              },
            )
            .toList();
        await DatabaseService.instance.saveLayoutBatch(batch);
      } else {
        // 1. Programmatically check for missing items (like the new BiometricStatusHub)
        final defaultForScreen = defaultManifest.where(
          (item) => item.targetScreen == event.targetScreen,
        );
        final missingItems = <LayoutManifestItem>[];
        for (final defaultItem in defaultForScreen) {
          if (!dbLayouts.any((row) => row['object_uuid'] == defaultItem.id)) {
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

        if (missingItems.isNotEmpty) {
          int maxRow = dbLayouts.isEmpty
              ? -1
              : dbLayouts
                    .map((e) => e['row_position'] as int)
                    .reduce((a, b) => a > b ? a : b);

          final batch = missingItems.map((item) {
            maxRow++;
            return {
              'screen_uuid': item.targetScreen.uuid,
              'object_uuid': item.id,
              'row_position':
                  maxRow, // Seed safely at the bottom of the stack to avoid PK collisions
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
          final defaultItem = defaultManifest
              .cast<LayoutManifestItem?>()
              .firstWhere((item) => item!.id == id, orElse: () => null);
          return LayoutManifestItem(
            id: id,
            debugTag: defaultItem?.debugTag ?? 'Unknown',
            targetScreen: event.targetScreen,
            rowPosition: row['row_position'] as int,
          );
        }).toList();
      }

      activeLayout.sort((a, b) => a.rowPosition.compareTo(b.rowPosition));

      final updatedMap = Map<AppScreen, List<LayoutManifestItem>>.from(
        state.screenLayouts,
      );
      updatedMap[event.targetScreen] = activeLayout;
      emit(state.copyWith(screenLayouts: updatedMap, isLoading: false));
    } catch (e) {
      // Handle error natively, just stop loading for now
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onShiftComponentLayout(
    ShiftComponentLayout event,
    Emitter<LayoutState> emit,
  ) async {
    // 1. Fetch the target screen's current list from DB (to handle cross-screen safely)
    final dbLayouts = await DatabaseService.instance.loadLayout(
      event.newScreen.uuid,
    );
    List<LayoutManifestItem> targetScreenItems = dbLayouts.map((row) {
      final id = row['object_uuid'] as String;
      final defaultItem = defaultManifest
          .cast<LayoutManifestItem?>()
          .firstWhere((item) => item!.id == id, orElse: () => null);
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
      final defaultItem = defaultManifest.firstWhere(
        (item) => item.id == event.objectUuid,
      );
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

    // 3. Update Item (No Cascade)
    List<LayoutManifestItem> mutatedItems = List.from(targetScreenItems);
    mutatedItems.add(movingItem!);

    // 4. Save the mutated array back to DB
    final batch = mutatedItems
        .map(
          (item) => {
            'screen_uuid': item.targetScreen.uuid,
            'object_uuid': item.id,
            'row_position': item.rowPosition,
          },
        )
        .toList();
    await DatabaseService.instance.saveLayoutBatch(batch);

    // 5. If migrating across screens, clear the old record from the source screen layout pool
    if (event.currentScreen != event.newScreen) {
      final db = await DatabaseService.instance.database;
      await db.delete(
        'layout_manifest',
        where: 'screen_uuid = ? AND object_uuid = ?',
        whereArgs: [event.currentScreen.uuid, event.objectUuid],
      );
    }

    // 6. Dual-Channel State Hydration
    add(LoadLayoutManifest(event.currentScreen));
    if (event.currentScreen != event.newScreen) {
      add(LoadLayoutManifest(event.newScreen));
    }
  }

  void _onPushDrillDownNode(PushDrillDownNode event, Emitter<LayoutState> emit) {
    final updatedPaths = Map<AppScreen, List<DrillDownCriteria>>.from(state.activeDrillDownPaths);
    final currentPath = List<DrillDownCriteria>.from(updatedPaths[event.activeScreen] ?? []);
    currentPath.add(event.criteria);
    updatedPaths[event.activeScreen] = currentPath;
    emit(state.copyWith(activeDrillDownPaths: updatedPaths));
  }

  void _onPopDrillDownNode(PopDrillDownNode event, Emitter<LayoutState> emit) {
    final updatedPaths = Map<AppScreen, List<DrillDownCriteria>>.from(state.activeDrillDownPaths);
    final currentPath = List<DrillDownCriteria>.from(updatedPaths[event.activeScreen] ?? []);
    if (currentPath.isNotEmpty) {
      currentPath.removeLast();
    }
    updatedPaths[event.activeScreen] = currentPath;
    emit(state.copyWith(activeDrillDownPaths: updatedPaths));
  }
}

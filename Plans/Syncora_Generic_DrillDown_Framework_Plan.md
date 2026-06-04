# Syncora AI: Generic Polymorphic Drill-Down Framework Plan

## PART 1: THE CORE ARCHITECTURAL & SCHEMATIC AUDIT

### 1. The Polymorphic Criteria Envelope (`layout_event.dart`)
**State Definition:**
Currently, our `PushDrillDownNode` simply accepts a `String nodeId`. This is too rigid for a multi-domain dashboard (e.g., mixing Telemetry, Heart Rate, and Layout nodes). We need a unified polymorphic envelope.
**Architectural Solution:**
We will define a generic configuration object, `DrillDownCriteria`, that completely encapsulates the dynamic parameters needed to resolve any depth traversal query:
```dart
class DrillDownCriteria {
  final String tableName;
  final String filterColumn;
  final String targetId;
  final String? criteriaType;

  const DrillDownCriteria({
    required this.tableName,
    required this.filterColumn,
    required this.targetId,
    this.criteriaType,
  });
}
```
`PushDrillDownNode` will be updated to accept `final DrillDownCriteria criteria;` instead of a flat string.

### 2. The Unified Database Router (`database_service.dart`)
**Query Engineering:**
To avoid hardcoding separate `getTelemetryDetails`, `getLayoutDetails`, etc., we will inject a single, universal data fetcher into the `DatabaseService` that consumes the polymorphic criteria.
```dart
Future<List<Map<String, dynamic>>> fetchGenericDrillDownData({
  required String tableName,
  required String filterColumn,
  required String targetId,
  String? criteriaType,
}) async {
  final db = await instance.database;
  
  String whereClause = '$filterColumn = ?';
  List<dynamic> whereArgs = [targetId];

  // Dynamically append secondary filtering if a criteria type is provided
  if (criteriaType != null && criteriaType.isNotEmpty) {
    whereClause += ' AND category_type = ?';
    whereArgs.add(criteriaType);
  }

  return await db.query(
    tableName,
    where: whereClause,
    whereArgs: whereArgs,
  );
}
```
This safely maps incoming SQL structures while maintaining strict parameter binding constraints against injection.

---

## PART 2: THE REUSABLE COMPONENT WIREUP PLAN

### 1. The Standardized Drill-Down Interface Configuration
**Interface Definition (`drill_down_provider.dart`):**
To ensure standard behavior across all charting components, we will establish an interface that guarantees a widget can explicitly provide its database resolution parameters dynamically.
```dart
abstract class DrillDownProvider {
  DrillDownCriteria get drillDownConfig;
}
```
Existing components like `ArcGauge` or `BiometricStatusHub` can simply implement this contract and return their hardcoded or state-driven criteria payload.

### 2. The Generic UI Tap Ingestion Loop
**Interactive Wrapper (`generic_drill_down_wrapper.dart`):**
Instead of manually wiring `GestureDetector` logic deep inside every specific component's painter or list, we will author a single wrapper widget that intercepts taps.
```dart
class GenericDrillDownWrapper extends StatelessWidget {
  final Widget child;
  final DrillDownProvider provider;
  final AppScreen activeScreen;

  const GenericDrillDownWrapper({
    Key? key,
    required this.child,
    required this.provider,
    required this.activeScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<LayoutBloc>().add(PushDrillDownNode(
          activeScreen: activeScreen,
          criteria: provider.drillDownConfig,
        ));
      },
      child: child,
    );
  }
}
```

### 3. The Step-by-Step Files & Lines Target Map
1. **Target 1:** `lib/core/bloc/layout/layout_event.dart`
   - Define `DrillDownCriteria` class.
   - Refactor `PushDrillDownNode` to accept the `criteria` envelope instead of `nodeId`.
2. **Target 2:** `lib/core/bloc/layout/layout_state.dart` & `layout_bloc.dart`
   - Update `activeDrillDownPaths` tracking from `List<String>` to `List<DrillDownCriteria>` to retain full coordinate tracking history.
   - Update reducer loops to match the new envelope type.
3. **Target 3:** `lib/core/database/database_service.dart`
   - Inject the `fetchGenericDrillDownData` asynchronous database query method.
4. **Target 4:** `lib/core/interfaces/drill_down_provider.dart` (New File)
   - Define the `DrillDownProvider` abstract class.
5. **Target 5:** `lib/features/palette/presentation/widgets/generic_drill_down_wrapper.dart` (New File)
   - Author the `GenericDrillDownWrapper` interactive component.

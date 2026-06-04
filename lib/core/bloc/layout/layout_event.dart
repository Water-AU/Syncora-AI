import 'package:syncora_ai/core/layout/layout_manifest.dart';

// 1. The Polymorphic Criteria Envelope
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

abstract class LayoutEvent {
  const LayoutEvent();
}

class LoadLayoutManifest extends LayoutEvent {
  final AppScreen targetScreen;
  const LoadLayoutManifest(this.targetScreen);
}

class ShiftComponentLayout extends LayoutEvent {
  final String objectUuid;
  final AppScreen newScreen;
  final int newRowPosition;
  final AppScreen currentScreen;

  const ShiftComponentLayout({
    required this.objectUuid,
    required this.newScreen,
    required this.newRowPosition,
    required this.currentScreen,
  });
}

// 2. Fixed Recursive Event Closures
class PushDrillDownNode extends LayoutEvent {
  final AppScreen activeScreen;
  final DrillDownCriteria criteria;

  const PushDrillDownNode({
    required this.activeScreen,
    required this.criteria,
  });
}

class PopDrillDownNode extends LayoutEvent {
  final AppScreen activeScreen;

  const PopDrillDownNode({
    required this.activeScreen,
  });
}

import 'package:flutter/foundation.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';

@immutable
abstract class LayoutEvent {}

class LoadLayoutManifest extends LayoutEvent {
  final AppScreen targetScreen;
  LoadLayoutManifest(this.targetScreen);
}

class ShiftComponentLayout extends LayoutEvent {
  final String objectUuid;
  final AppScreen newScreen;
  final int newRowPosition;

  ShiftComponentLayout({
    required this.objectUuid,
    required this.newScreen,
    required this.newRowPosition,
  });
}

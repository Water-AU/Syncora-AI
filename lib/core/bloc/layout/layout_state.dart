import 'package:flutter/foundation.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';

@immutable
class LayoutState {
  final List<LayoutManifestItem> currentLayout;
  final bool isLoading;

  const LayoutState({
    required this.currentLayout,
    this.isLoading = false,
  });

  LayoutState copyWith({
    List<LayoutManifestItem>? currentLayout,
    bool? isLoading,
  }) {
    return LayoutState(
      currentLayout: currentLayout ?? this.currentLayout,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

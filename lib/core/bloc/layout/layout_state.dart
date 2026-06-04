import 'package:syncora_ai/core/layout/layout_manifest.dart';
import 'layout_event.dart'; // Crucial missing link for DrillDownCriteria visibility

class LayoutState {
  final Map<AppScreen, List<LayoutManifestItem>> screenLayouts;
  final Map<AppScreen, List<DrillDownCriteria>> activeDrillDownPaths;
  final bool isLoading;

  const LayoutState({
    required this.screenLayouts,
    this.activeDrillDownPaths = const {},
    this.isLoading = false,
  });

  LayoutState copyWith({
    Map<AppScreen, List<LayoutManifestItem>>? screenLayouts,
    Map<AppScreen, List<DrillDownCriteria>>? activeDrillDownPaths,
    bool? isLoading,
  }) {
    return LayoutState(
      screenLayouts: screenLayouts ?? this.screenLayouts,
      activeDrillDownPaths: activeDrillDownPaths ?? this.activeDrillDownPaths,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

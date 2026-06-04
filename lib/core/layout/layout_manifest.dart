enum AppScreen { home, activity, ai, diet, profile }

extension AppScreenExtension on AppScreen {
  String get uuid {
    switch (this) {
      case AppScreen.home: return '11111111-aaaa-bbbb-cccc-000000000000';
      case AppScreen.activity: return '22222222-aaaa-bbbb-cccc-000000000000';
      case AppScreen.ai: return '33333333-aaaa-bbbb-cccc-000000000000';
      case AppScreen.diet: return '44444444-aaaa-bbbb-cccc-000000000000';
      case AppScreen.profile: return '55555555-aaaa-bbbb-cccc-000000000000';
    }
  }
}

class LayoutManifestItem {
  final String id;
  final String debugTag;
  final AppScreen targetScreen;
  final int rowPosition;

  const LayoutManifestItem({
    required this.id,
    required this.debugTag,
    required this.targetScreen,
    required this.rowPosition,
  });
}

const List<LayoutManifestItem> defaultManifest = [
  LayoutManifestItem(
    id: 'c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f',
    debugTag: 'BiometricStatusHub',
    targetScreen: AppScreen.home,
    rowPosition: 1,
  ),
  LayoutManifestItem(
    id: 'f7b8c9d0-1e2f-3a4b-5c6d-7e8f9a0b1c2d',
    debugTag: 'InterceptBanner',
    targetScreen: AppScreen.home,
    rowPosition: 1,
  ),
  LayoutManifestItem(
    id: 'e1b2c3d4-5e6f-7a8b-9c0d-1e2f3a4b5c6d',
    debugTag: 'ArcGauge',
    targetScreen: AppScreen.home,
    rowPosition: 3,
  ),
  LayoutManifestItem(
    id: 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
    debugTag: 'SettingsControl',
    targetScreen: AppScreen.home,
    rowPosition: 2,
  ),
  LayoutManifestItem(
    id: 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e',
    debugTag: 'SQLAnalytics',
    targetScreen: AppScreen.home,
    rowPosition: 0,
  ),
  LayoutManifestItem(
    id: 'd4e5f6a7-b8c9-0d1e-2f3a-4b5c6d7e8f9a',
    debugTag: 'DietCustomCard',
    targetScreen: AppScreen.diet,
    rowPosition: 0,
  ),
  LayoutManifestItem(
    id: 'e5f6a7b8-c9d0-1e2f-3a4b-5c6d7e8f9a0b',
    debugTag: 'ActivityLoggerRegistry',
    targetScreen: AppScreen.activity,
    rowPosition: 0,
  ),
  LayoutManifestItem(
    id: 'a2b3c4d5-e6f7-8a9b-0c1d-2e3f4a5b6c7d',
    debugTag: 'ActivityTrendTimeline',
    targetScreen: AppScreen.activity,
    rowPosition: 1,
  ),
  LayoutManifestItem(
    id: 'd5c4b3a2-f7e6-9b8a-1c0d-3e2f5a4b6c7d',
    debugTag: 'NutrientConsumptionHistory',
    targetScreen: AppScreen.diet,
    rowPosition: 1,
  ),
];

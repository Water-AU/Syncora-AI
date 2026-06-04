import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/bloc/theme_bloc.dart';
import 'package:syncora_ai/core/bloc/theme_event.dart';
import 'package:syncora_ai/core/bloc/layout/layout_bloc.dart';
import 'package:syncora_ai/core/bloc/layout/layout_event.dart';
import 'package:syncora_ai/core/bloc/layout/layout_state.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';
import 'package:syncora_ai/core/theme/syncora_theme.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/glass_panel.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/arc_gauge.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/intercept_banner.dart';
import 'package:syncora_ai/core/audience/syncora_audience.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/settings_control_row.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/historical_analytics_panel.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/biometric_status_hub.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/activity_trend_timeline.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/nutrient_consumption_history.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/row_concertina_container.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/breadcrumb_navigator.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/generic_drill_down_detail_view.dart';

class PaletteDashboardPage extends StatefulWidget {
  final AppScreen activeScreen;
  final AudienceProfile initialAudience;

  const PaletteDashboardPage({
    super.key,
    required this.activeScreen,
    this.initialAudience = AudienceProfile.whiteCollar,
  });

  @override
  State<PaletteDashboardPage> createState() => _PaletteDashboardPageState();
}

class _PaletteDashboardPageState extends State<PaletteDashboardPage> {
  late AudienceProfile _activeAudience;

  @override
  void initState() {
    super.initState();
    _activeAudience = widget.initialAudience;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LayoutBloc>().add(LoadLayoutManifest(widget.activeScreen));
    });
  }

  @override
  void didUpdateWidget(covariant PaletteDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeScreen != widget.activeScreen) {
      context.read<LayoutBloc>().add(LoadLayoutManifest(widget.activeScreen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SyncoraTheme.of(context);

    return AudienceScope(
      profile: _activeAudience,
      child: AnimatedTheme(
        data: theme.themeData,
        duration: theme.themeTransitionDuration,
        child: Scaffold(
          backgroundColor: theme.baseBackground,
          appBar: AppBar(
        title: Text('${widget.activeScreen.name[0].toUpperCase()}${widget.activeScreen.name.substring(1)} Canvas'),
        actions: [
          PopupMenuButton<ThemeProfile>(
            onSelected: (profile) {
              context.read<ThemeBloc>().add(ThemeToggleEvent(profile));
            },
            itemBuilder: (context) => syncoraThemeProfiles.map((p) => PopupMenuItem(
              value: p,
              child: Text(p.displayName),
            )).toList(),
          )
        ],
      ),
      body: AnimatedDefaultTextStyle(
        duration: theme.themeTransitionDuration,
        style: TextStyle(color: theme.textPrimary),
        child: BlocBuilder<LayoutBloc, LayoutState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: theme.primaryAccent),
              );
            }
            
            final activePath = state.activeDrillDownPaths[widget.activeScreen] ?? [];
            if (activePath.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BreadcrumbNavigator(activeScreen: widget.activeScreen),
                  Expanded(
                    child: GenericDrillDownDetailView(criteria: activePath.last),
                  ),
                ],
              );
            }

            final homeWidgets = state.screenLayouts[widget.activeScreen] ?? [];
            
            final groupedWidgets = homeWidgets.fold<Map<int, List<LayoutManifestItem>>>(
              {}, 
              (map, item) {
                (map[item.rowPosition] ??= []).add(item);
                return map;
              }
            );
            final distinctRows = groupedWidgets.keys.toList()..sort();
            
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: distinctRows.length,
              itemBuilder: (context, index) {
                final rowIndex = distinctRows[index];
                final components = groupedWidgets[rowIndex]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index > 0) const SizedBox(height: 24),
                    RowConcertinaContainer(
                      components: components,
                      activeScreen: widget.activeScreen,
                      componentBuilder: (item) => _buildManifestComponent(item, rowIndex),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      ),
      ),
    );
  }

  Widget _buildManifestComponent(LayoutManifestItem item, int displayIndex) {
    debugPrint('Resolving Layout Manifest Block -> ID: ${item.id} | Row Index: $displayIndex');
    switch (item.id) {
      case 'c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Row $displayIndex: Biometric Status Hub'),
            BiometricStatusHub(activeScreen: widget.activeScreen),
          ],
        );
      case 'e1b2c3d4-5e6f-7a8b-9c0d-1e2f3a4b5c6d':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Row $displayIndex: Telemetry Gauge'),
            GlassPanel(
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: ArcGauge(activeScreen: widget.activeScreen),
              ),
            ),
          ],
        );
      case 'f7b8c9d0-1e2f-3a4b-5c6d-7e8f9a0b1c2d':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Row $displayIndex: System Banners & Intercepts'),
            const InterceptBanner(),
          ],
        );
      case 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Row $displayIndex: System Administration & Control Settings'),
            SettingsControlRow(activeScreen: widget.activeScreen),
          ],
        );
      case 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Row $displayIndex: Telemetry Trends & Historical Vault Analytics'),
            const HistoricalAnalyticsPanel(),
          ],
        );
      case 'a2b3c4d5-e6f7-8a9b-0c1d-2e3f4a5b6c7d':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Row $displayIndex: Activity Trend Timeline'),
            ActivityTrendTimeline(component: item),
          ],
        );
      case 'd5c4b3a2-f7e6-9b8a-1c0d-3e2f5a4b6c7d':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Row $displayIndex: Nutrient Consumption History'),
            NutrientConsumptionHistory(component: item),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});
  
  @override
  Widget build(BuildContext context) {
    final theme = SyncoraTheme.of(context);
    return AnimatedContainer(
      duration: theme.themeTransitionDuration,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      margin: const EdgeInsets.only(bottom: 16.0, top: 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: AnimatedDefaultTextStyle(
        duration: theme.themeTransitionDuration,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Text(title),
      ),
    );
  }
}

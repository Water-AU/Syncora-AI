import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/audience/syncora_audience.dart';
import 'package:syncora_ai/core/bloc/theme_bloc.dart';
import 'package:syncora_ai/core/bloc/theme_event.dart';
import 'package:syncora_ai/core/bloc/telemetry/telemetry_bloc.dart';
import 'package:syncora_ai/core/bloc/telemetry/telemetry_event.dart';
import 'package:syncora_ai/core/bloc/layout/layout_bloc.dart';
import 'package:syncora_ai/core/bloc/layout/layout_event.dart';
import 'package:syncora_ai/core/bloc/layout/layout_state.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';
import 'package:syncora_ai/core/theme/syncora_theme.dart';
import 'package:syncora_ai/features/palette/presentation/widgets/glass_panel.dart';

class SettingsControlRow extends StatefulWidget {
  final AppScreen activeScreen;
  const SettingsControlRow({super.key, required this.activeScreen});

  @override
  State<SettingsControlRow> createState() => _SettingsControlRowState();
}

class _SettingsControlRowState extends State<SettingsControlRow> {
  late AudienceProfile activeAudience;
  final Map<String, LayoutManifestItem> _stagedLayouts = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    activeAudience = AudienceConfiguration.of(context).profile;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SyncoraTheme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassPanel(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildAudienceGroup(theme),
              ),
              const SizedBox(width: 24.0),
              Expanded(
                child: _buildDurationGroup(context, theme),
              ),
              const SizedBox(width: 24.0),
              Expanded(
                child: _buildThemeGroup(context, theme),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        GlassPanel(
          padding: const EdgeInsets.all(20.0),
          child: _buildLayoutManager(context, theme),
        ),
      ],
    );
  }

  Widget _buildAudienceGroup(SyncoraTheme theme) {
    return RadioGroup<AudienceProfile>(
      groupValue: activeAudience,
      onChanged: (val) {
        if (val != null) {
          setState(() => activeAudience = val);
          AudienceConfiguration.saveProfile(val);
          context.read<TelemetryBloc>().add(UpdateAudienceTelemetry(val));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Target Audience',
            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12.0),
          ...AudienceProfile.values.map((profile) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<AudienceProfile>(
                  value: profile,
                  activeColor: theme.primaryAccent,
                ),
                Expanded(
                  child: Text(
                    profile.name,
                    style: TextStyle(color: theme.textPrimary),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDurationGroup(BuildContext context, SyncoraTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Transition Timeline (${theme.themeTransitionDuration.inMilliseconds} ms)',
          style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        Slider(
          value: theme.themeTransitionDuration.inMilliseconds.toDouble(),
          min: 200,
          max: 1200,
          divisions: 10,
          activeColor: theme.primaryAccent,
          onChanged: (val) {
            context.read<ThemeBloc>().add(
              ThemeDurationChangedEvent(Duration(milliseconds: val.toInt()))
            );
          },
        ),
      ],
    );
  }

  Widget _buildThemeGroup(BuildContext context, SyncoraTheme theme) {
    return RadioGroup<ThemeProfile>(
      groupValue: theme.profile,
      onChanged: (val) {
        if (val != null) {
          context.read<ThemeBloc>().add(ThemeToggleEvent(val));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Active Design Profile',
            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12.0),
          ...syncoraThemeProfiles.map((profile) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<ThemeProfile>(
                  value: profile,
                  activeColor: theme.primaryAccent,
                ),
                Expanded(
                  child: Text(
                    profile.displayName,
                    style: TextStyle(color: theme.textPrimary),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLayoutManager(BuildContext context, SyncoraTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Dynamic Manifest Matrix Engine',
          style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16.0),
        BlocBuilder<LayoutBloc, LayoutState>(
          builder: (context, state) {
            if (state.isLoading) return CircularProgressIndicator(color: theme.primaryAccent);
            
            return Column(
              children: defaultManifest.map((manifestItem) {
                LayoutManifestItem? foundItem;
                for (final layouts in state.screenLayouts.values) {
                  try {
                    foundItem = layouts.firstWhere((item) => item.id == manifestItem.id);
                    break;
                  } catch (_) {}
                }
                final baseLayoutItem = foundItem ?? manifestItem;
                final currentLayoutItem = _stagedLayouts[manifestItem.id] ?? baseLayoutItem;
                final hasUnsavedChanges = _stagedLayouts.containsKey(manifestItem.id);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(manifestItem.debugTag, style: TextStyle(color: theme.textPrimary)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<AppScreen>(
                          value: currentLayoutItem.targetScreen,
                          dropdownColor: theme.baseBackground,
                          isExpanded: true,
                          style: TextStyle(color: theme.textPrimary),
                          items: AppScreen.values.map((screen) {
                            return DropdownMenuItem(
                              value: screen,
                              child: Text(screen.name),
                            );
                          }).toList(),
                          onChanged: (newScreen) {
                            if (newScreen != null) {
                              setState(() {
                                _stagedLayouts[manifestItem.id] = LayoutManifestItem(
                                  id: manifestItem.id,
                                  debugTag: manifestItem.debugTag,
                                  targetScreen: newScreen,
                                  rowPosition: currentLayoutItem.rowPosition,
                                );
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
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
                              setState(() {
                                _stagedLayouts[manifestItem.id] = LayoutManifestItem(
                                  id: manifestItem.id,
                                  debugTag: manifestItem.debugTag,
                                  targetScreen: currentLayoutItem.targetScreen,
                                  rowPosition: newRow,
                                );
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.check_circle_outline,
                          color: hasUnsavedChanges 
                              ? theme.primaryAccent 
                              : theme.textPrimary.withValues(alpha: 0.3),
                        ),
                        tooltip: 'Commit Layout Shift',
                        onPressed: hasUnsavedChanges ? () {
                          final staged = _stagedLayouts[manifestItem.id]!;
                          context.read<LayoutBloc>().add(ShiftComponentLayout(
                            objectUuid: staged.id,
                            newScreen: staged.targetScreen,
                            newRowPosition: staged.rowPosition,
                            currentScreen: widget.activeScreen,
                          ));
                          setState(() => _stagedLayouts.remove(manifestItem.id));
                        } : null,
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

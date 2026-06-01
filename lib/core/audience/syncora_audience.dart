import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AudienceProfile { whiteCollar, educator, blueCollar }

class AudienceConfiguration {
  final AudienceProfile profile;
  final String audienceName;
  final List<String> baselineActivitySuggestions;
  final String primaryMetricFocus;

  const AudienceConfiguration({
    required this.profile,
    required this.audienceName,
    required this.baselineActivitySuggestions,
    required this.primaryMetricFocus,
  });

  factory AudienceConfiguration.fromProfile(AudienceProfile profile) {
    switch (profile) {
      case AudienceProfile.whiteCollar:
        return const AudienceConfiguration(
          profile:
              AudienceProfile.blueCollar, //-- whiteCollar, blueCollar, educator
          audienceName: 'Corporate Professional',
          baselineActivitySuggestions: [
            'Desk Mobility',
            'Screen Rest Intervals',
            'Ergonomic Posture Checks',
          ],
          primaryMetricFocus: 'Cognitive Fatigue Mitigation',
        );
      case AudienceProfile.educator:
        return const AudienceConfiguration(
          profile: AudienceProfile.educator,
          audienceName: 'Academic Educator',
          baselineActivitySuggestions: [
            'Vocal Cord Rest',
            'Dynamic Stance Shifts',
            'Micro-Mindfulness Transitions',
          ],
          primaryMetricFocus: 'Sensory Overload Recovery',
        );
      case AudienceProfile.blueCollar:
        return const AudienceConfiguration(
          profile: AudienceProfile.blueCollar,
          audienceName: 'Field & Trade Operative',
          baselineActivitySuggestions: [
            'Asymmetric Strain Reset',
            'Joint Decompression',
            'Load Bearing Warmups',
          ],
          primaryMetricFocus: 'Physical Strain Recovery',
        );
    }
  }

  /// Lightweight read-only structural hook.
  /// Simulates fetching the globally configured tenant identity.
  static AudienceConfiguration of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AudienceScope>();
    return AudienceConfiguration.fromProfile(scope?.profile ?? AudienceProfile.whiteCollar);
  }

  /// Auto-commits the selected profile index to disk.
  static Future<void> saveProfile(AudienceProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('audience_profile_index', profile.index);
  }
}

class AudienceScope extends InheritedWidget {
  final AudienceProfile profile;

  const AudienceScope({
    super.key,
    required this.profile,
    required super.child,
  });

  @override
  bool updateShouldNotify(AudienceScope oldWidget) => profile != oldWidget.profile;
}

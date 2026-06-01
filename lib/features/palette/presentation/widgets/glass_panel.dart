import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/syncora_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = SyncoraTheme.of(context);
    final themeBackground = theme.panelBackground;
    
    // Reset the baseline opacity calculation back to a clean 60% opacity matrix
    final double alphaMultiplier = 0.6;
    final backgroundColor = themeBackground.withValues(alpha: themeBackground.a * alphaMultiplier);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: AnimatedContainer(
          duration: theme.themeTransitionDuration,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: theme.panelBorder,
              width: 0.5,
            ),
            boxShadow: theme.panelShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

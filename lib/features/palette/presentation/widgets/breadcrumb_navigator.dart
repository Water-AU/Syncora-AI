import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/bloc/layout/layout_bloc.dart';
import 'package:syncora_ai/core/bloc/layout/layout_event.dart';
import 'package:syncora_ai/core/bloc/layout/layout_state.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';
import 'package:syncora_ai/core/theme/syncora_theme.dart';

class BreadcrumbNavigator extends StatelessWidget {
  final AppScreen activeScreen;

  const BreadcrumbNavigator({super.key, required this.activeScreen});

  @override
  Widget build(BuildContext context) {
    final theme = SyncoraTheme.of(context);
    
    return BlocBuilder<LayoutBloc, LayoutState>(
      builder: (context, state) {
        final paths = state.activeDrillDownPaths[activeScreen] ?? [];
        if (paths.isEmpty) {
          return const SizedBox.shrink();
        }

        final List<Widget> breadcrumbs = [];
        // Add root element
        breadcrumbs.add(
          InkWell(
            onTap: () {
              // Pop all nodes to go back to root
              for (int i = 0; i < paths.length; i++) {
                context.read<LayoutBloc>().add(PopDrillDownNode(activeScreen: activeScreen));
              }
            },
            child: Text(
              activeScreen.name, 
              style: TextStyle(
                color: theme.primaryAccent, 
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        );

        for (int i = 0; i < paths.length; i++) {
          breadcrumbs.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.chevron_right, 
                size: 16, 
                color: theme.textPrimary.withValues(alpha: 0.5),
              ),
            )
          );
          
          final isLast = i == paths.length - 1;
          final displayLabel = paths[i].targetId.isEmpty ? 'Root Node' : paths[i].targetId;
          breadcrumbs.add(
            InkWell(
              onTap: isLast ? null : () {
                // Calculate how many times we need to pop to reach this index
                final popsNeeded = paths.length - 1 - i;
                for (int p = 0; p < popsNeeded; p++) {
                  context.read<LayoutBloc>().add(PopDrillDownNode(activeScreen: activeScreen));
                }
              },
              child: Text(
                displayLabel,
                style: TextStyle(
                  color: isLast ? theme.textPrimary : theme.primaryAccent,
                  fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            )
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: theme.baseBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: breadcrumbs,
            ),
          ),
        );
      },
    );
  }
}

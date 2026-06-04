import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncora_ai/core/bloc/layout/layout_bloc.dart';
import 'package:syncora_ai/core/bloc/layout/layout_event.dart';
import 'package:syncora_ai/core/interfaces/drill_down_provider.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';

class GenericDrillDownWrapper extends StatelessWidget {
  final Widget child;
  final DrillDownProvider provider;
  final AppScreen activeScreen;

  const GenericDrillDownWrapper({
    super.key,
    required this.child,
    required this.provider,
    required this.activeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<LayoutBloc>().add(PushDrillDownNode(
          activeScreen: activeScreen,
          criteria: provider.drillDownConfig,
        ));
      },
      child: child,
    );
  }
}

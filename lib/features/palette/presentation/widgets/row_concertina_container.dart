import 'package:flutter/material.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';
import 'package:syncora_ai/core/theme/syncora_theme.dart';

class RowConcertinaContainer extends StatefulWidget {
  final List<LayoutManifestItem> components;
  final AppScreen activeScreen;
  final Widget Function(LayoutManifestItem) componentBuilder;

  const RowConcertinaContainer({
    super.key,
    required this.components,
    required this.activeScreen,
    required this.componentBuilder,
  });

  @override
  State<RowConcertinaContainer> createState() => _RowConcertinaContainerState();
}

class _RowConcertinaContainerState extends State<RowConcertinaContainer> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.components.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900 || widget.components.length == 1) {
          // Render side-by-side using Wrap
          return Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: widget.components.map((item) {
              return SizedBox(
                // Use a bounded width if more than one item, else take full width
                width: widget.components.length > 1 
                    ? (constraints.maxWidth - (16.0 * (widget.components.length - 1))) / widget.components.length 
                    : constraints.maxWidth,
                child: widget.componentBuilder(item),
              );
            }).toList(),
          );
        } else {
          // Render Concertina Mechanics
          final primaryComponent = widget.componentBuilder(widget.components.first);
          final siblingComponents = widget.components.skip(1).map((item) => widget.componentBuilder(item)).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primaryComponent,
              if (siblingComponents.isNotEmpty) ...[
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16.0),
                            ...siblingComponents.map((child) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: child,
                                )),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 12.0),
                _buildExpanderButton(context),
              ],
            ],
          );
        }
      },
    );
  }

  Widget _buildExpanderButton(BuildContext context) {
    final theme = SyncoraTheme.of(context);
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: theme.primaryAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: theme.primaryAccent.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            _isExpanded 
                ? '═══ [ Hide Sibling Components ] ═══'
                : '═══ [ View Sibling Components (${widget.components.length - 1}) ] ═══',
            style: TextStyle(
              color: theme.primaryAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

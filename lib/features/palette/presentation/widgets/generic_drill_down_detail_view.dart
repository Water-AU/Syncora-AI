import 'package:flutter/material.dart';
import 'package:syncora_ai/core/bloc/layout/layout_event.dart';
import 'package:syncora_ai/core/database/database_service.dart';

class GenericDrillDownDetailView extends StatelessWidget {
  final DrillDownCriteria criteria;

  const GenericDrillDownDetailView({
    Key? key,
    required this.criteria,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseService.instance.fetchGenericDrillDownData(
        tableName: criteria.tableName,
        filterColumn: criteria.filterColumn,
        targetId: criteria.targetId,
        criteriaType: criteria.criteriaType,
      ),
      builder: (context, snapshot) {
        // 1. CATCH AND DISPLAY EXPLICIT RUNTIME BLIND ERRORS
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.gpp_bad_rounded, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Database Query Execution Failed',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        'Error: ${snapshot.error}\n\n'
                        'Attempted Query Context:\n'
                        'Table: ${criteria.tableName}\n'
                        'Filter Column: ${criteria.filterColumn}\n'
                        'Target ID: ${criteria.targetId}\n'
                        'Criteria Type: ${criteria.criteriaType}',
                        style: const TextStyle(fontFamily: 'Courier', color: Colors.greenAccent, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 2. SHOW LOADING INDICATOR
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          );
        }

        final data = snapshot.data;

        // 3. HANDLE EMPTY DATA GRACEFULLY
        if (data == null || data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open_rounded, color: theme.hintColor.withValues(alpha: 0.5), size: 48),
                const SizedBox(height: 16),
                Text(
                  'Scope Empty',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.hintColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'No records found matching target: "${criteria.targetId}"\n'
                  'in table: "${criteria.tableName}".',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
              ],
            ),
          );
        }

        // 4. SAFELY BUILD THE RESPONSIVE DATA MATRIX
        try {
          final columns = data.first.keys.map((key) {
            return DataColumn(
              label: Text(
                key.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            );
          }).toList();

          final rows = data.map((row) {
            return DataRow(
              cells: data.first.keys.map((col) {
                final value = row[col];
                return DataCell(
                  Container(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      value?.toString() ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: columns,
                rows: rows,
                columnSpacing: 24,
                headingRowHeight: 40,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 48,
              ),
            ),
          );
        } catch (e) {
          return Center(
            child: Text('Table Assembly Exception: $e', style: const TextStyle(color: Colors.orangeAccent)),
          );
        }
      },
    );
  }
}

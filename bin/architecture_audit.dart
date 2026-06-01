// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  print('====================================================');
  print('          SYNCORA AI: ARCHITECTURAL AUDIT           ');
  print('====================================================\n');

  bool auditPassed = true;

  // Strict Token Inspection Regex: Flags presentation files attempting hardcoded style conditional switches
  final uiRegex = RegExp(r"(ThemeProfile\.\w+|==\s*['\u0022]\w+['\u0022])");

  // Strict Material/Widget Import Isolation Regex: Flags core/domain layers importing presentation assets
  final stateRegex = RegExp(r"import\s+['\u0022]package:flutter/material\.dart['\u0022]");

  // Define target scanning tracks safely
  final uiPaths = [
    'lib/features/palette/presentation/widgets',
    'lib/features/palette/presentation/pages',
  ];

  final corePaths = [
    'lib/core/bloc',
    'lib/core/utils',
  ];

  print('--- RUNNING RULE 1: UI PURE PRESENTATION AUDIT ---');
  for (var path in uiPaths) {
    final dir = Directory(path);
    if (!dir.existsSync()) continue;

    final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (var file in files) {
      final content = file.readAsStringSync();
      if (uiRegex.hasMatch(content)) {
        print('[FAILED] ${file.path} -> Violates structural isolation: contains hardcoded style conditional evaluations.');
        auditPassed = false;
      } else {
        print('[PASSED] ${file.path}');
      }
    }
  }

  print('\n--- RUNNING RULE 2: STATE ISOLATION AUDIT ---');
  for (var path in corePaths) {
    final dir = Directory(path);
    if (!dir.existsSync()) continue;

    final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (var file in files) {
      final content = file.readAsStringSync();
      if (stateRegex.hasMatch(content)) {
        print('[FAILED] ${file.path} -> Leaks UI Presentation Layer components into pure logical files.');
        auditPassed = false;
      } else {
        print('[PASSED] ${file.path}');
      }
    }
  }

  print('\n====================================================');
  if (auditPassed) {
    print('  AUDIT STATUS: [SUCCESS] ALL ARCHITECTURAL GATES PASSED');
    print('====================================================');
    exit(0);
  } else {
    print('  AUDIT STATUS: [CRITICAL FAILURE] VIOLATIONS DETECTED');
    print('====================================================');
    exit(1);
  }
}

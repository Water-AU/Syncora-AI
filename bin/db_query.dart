// ignore_for_file: avoid_print
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  
  final docsDir = '${Platform.environment['USERPROFILE']}\\Documents';
  final path = join(docsDir, 'SyncoraAI', 'telemetry.db');
  
  if (!File(path).existsSync()) {
    print('Database not found at $path');
    return;
  }
  
  final db = await databaseFactory.openDatabase(path);
  
  print('--- SCHEMA ---');
  final schema = await db.rawQuery('PRAGMA table_info(layout_manifest);');
  for (var row in schema) {
    print(row);
  }
  
  print('--- ROWS ---');
  final rows = await db.query('layout_manifest');
  for (var row in rows) {
    print(row);
  }
  
  await db.close();
  exit(0);
}

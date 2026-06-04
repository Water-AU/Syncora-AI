import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncora_ai/core/layout/layout_manifest.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('telemetry.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final directory = await getApplicationSupportDirectory();
    final path = join(directory.path, 'SyncoraAI', filePath);

    // Ensure directory exists
    final dir = Directory(dirname(path));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    try {
      final legacyFile = File("C:\\Users\\a428037\\OneDrive - ATOS\\Documents - Atos\\SyncoraAI\\telemetry.db");
      final targetFile = File(path);

      if (await legacyFile.exists()) {
        debugPrint('DEBUG: Legacy OneDrive file detected.');
        // Force create the entire nested AppData local subdirectory structure first
        await targetFile.parent.create(recursive: true);
        
        // Use a standard stream copy or a direct overwrite copy to move the bytes
        await legacyFile.copy(targetFile.path);
        debugPrint('DEBUG: File successfully copied to AppData: ${await targetFile.exists()}');
      } else {
        debugPrint('DEBUG: Legacy OneDrive file was not found at the hardcoded path.');
      }
    } catch (e, stackTrace) {
      debugPrint('CRITICAL DATABASE COPY ERROR: $e');
      debugPrint('STACKTRACE: $stackTrace');
    }

    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ),
    );

    await db.execute('''
      UPDATE layout_manifest 
      SET screen_uuid = '11111111-aaaa-bbbb-cccc-000000000000' 
      WHERE screen_uuid = 'home' OR screen_uuid = 'AppScreen.home'
    ''');

    for (final screen in AppScreen.values) {
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM layout_manifest WHERE screen_uuid = ?', 
        [screen.uuid]
      );
      final count = (countResult.isNotEmpty ? countResult.first['count'] as int? : 0) ?? 0;
      
      if (count == 0) {
        final defaultForScreen = defaultManifest.where((item) => item.targetScreen == screen).toList();
        if (defaultForScreen.isNotEmpty) {
          int maxRow = -1;
          for (final item in defaultForScreen) {
            maxRow++;
            await db.insert('layout_manifest', {
              'screen_uuid': screen.uuid,
              'object_uuid': item.id,
              'row_position': maxRow,
            });
          }
        }
      }
    }

    return db;
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
CREATE TABLE IF NOT EXISTS layout_manifest (
  screen_uuid TEXT NOT NULL,
  object_uuid TEXT NOT NULL UNIQUE,
  row_position INTEGER NOT NULL,
  PRIMARY KEY (screen_uuid, row_position)
)
''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE telemetry_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL,
  audience_profile TEXT NOT NULL,
  metric_value REAL NOT NULL,
  heart_rate INTEGER NOT NULL
)
''');

    await db.execute('''
CREATE TABLE layout_manifest (
  screen_uuid TEXT NOT NULL,
  object_uuid TEXT NOT NULL UNIQUE,
  row_position INTEGER NOT NULL,
  PRIMARY KEY (screen_uuid, row_position)
)
''');
  }

  Future<void> insertLog(String profile, double metric, int hr) async {
    final db = await instance.database;
    await db.insert('telemetry_logs', {
      'timestamp': DateTime.now().toIso8601String(),
      'audience_profile': profile,
      'metric_value': metric,
      'heart_rate': hr,
    });
  }

  Future<Map<String, dynamic>> getHistoricalAggregates() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_records,
        AVG(metric_value) as average_metric,
        AVG(heart_rate) as average_hr
      FROM telemetry_logs
    ''');

    if (result.isNotEmpty) {
      return result.first;
    }
    return {'total_records': 0, 'average_metric': 0.0, 'average_hr': 0.0};
  }

  Future<void> purgeAllLogs() async {
    final db = await instance.database;
    await db.delete('telemetry_logs');
  }

  Future<List<Map<String, dynamic>>> getRawTelemetryLogs({int limit = 50}) async {
    final db = await instance.database;
    return await db.query(
      'telemetry_logs',
      orderBy: 'timestamp ASC',
      limit: limit,
    );
  }

  Future<bool> hasDescendants(String nodeId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as child_count FROM layout_manifest WHERE screen_uuid = ?',
      [nodeId]
    );
    final count = (result.isNotEmpty ? result.first['child_count'] as int? : 0) ?? 0;
    return count > 0;
  }

  Future<List<Map<String, dynamic>>> fetchGenericDrillDownData({
    required String tableName,
    required String filterColumn,
    required String targetId,
    String? criteriaType,
  }) async {
    final db = await instance.database;
    
    String whereClause = '$filterColumn = ?';
    List<dynamic> whereArgs = [targetId];

    // Dynamically append secondary filtering if a criteria type is provided
    if (criteriaType != null && criteriaType.isNotEmpty) {
      whereClause += ' AND category_type = ?';
      whereArgs.add(criteriaType);
    }

    return await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  Future<List<Map<String, dynamic>>> loadLayout(String screenUuid) async {
    final db = await instance.database;
    return await db.query(
      'layout_manifest',
      where: 'screen_uuid = ?',
      whereArgs: [screenUuid],
      orderBy: 'row_position ASC',
    );
  }

  Future<void> saveLayoutBatch(List<Map<String, dynamic>> batch) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // Temporarily remove to avoid unique constraint collisions during the cascade
      for (final item in batch) {
        await txn.delete('layout_manifest', where: 'object_uuid = ?', whereArgs: [item['object_uuid']]);
      }
      for (final item in batch) {
        await txn.insert('layout_manifest', item);
      }
    });
  }
}

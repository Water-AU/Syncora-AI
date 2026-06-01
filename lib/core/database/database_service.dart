import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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

    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'SyncoraAI', filePath);

    // Ensure directory exists
    final dir = Directory(dirname(path));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ),
    );
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

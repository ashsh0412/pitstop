import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'pitstop.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 차량 프로필 테이블
    await db.execute('''
      CREATE TABLE vehicles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        vin TEXT,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 진단 코드 이력 테이블
    await db.execute('''
      CREATE TABLE dtc_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        code TEXT NOT NULL,
        description TEXT NOT NULL,
        severity TEXT NOT NULL,
        possible_causes TEXT NOT NULL,
        solutions TEXT NOT NULL,
        detected_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        cleared_at TIMESTAMP,
        FOREIGN KEY(vehicle_id) REFERENCES vehicles(id)
      )
    ''');

    // 유지보수 일정 테이블
    await db.execute('''
      CREATE TABLE maintenance_schedules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date DATE,
        due_mileage INTEGER,
        is_completed BOOLEAN NOT NULL DEFAULT 0,
        completed_at TIMESTAMP,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(vehicle_id) REFERENCES vehicles(id)
      )
    ''');

    // 운행 기록 테이블
    await db.execute('''
      CREATE TABLE trip_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        start_time TIMESTAMP NOT NULL,
        end_time TIMESTAMP,
        start_mileage REAL NOT NULL,
        end_mileage REAL,
        average_speed REAL,
        max_speed REAL,
        fuel_consumed REAL,
        FOREIGN KEY(vehicle_id) REFERENCES vehicles(id)
      )
    ''');

    // 센서 데이터 테이블
    await db.execute('''
      CREATE TABLE sensor_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id INTEGER NOT NULL,
        timestamp TIMESTAMP NOT NULL,
        rpm INTEGER,
        speed REAL,
        engine_temp REAL,
        throttle_pos REAL,
        voltage REAL,
        FOREIGN KEY(trip_id) REFERENCES trip_logs(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 데이터베이스 스키마 업그레이드 로직
  }

  // 차량 프로필 관련 메서드
  Future<int> insertVehicle(Map<String, dynamic> vehicle) async {
    Database db = await database;
    return await db.insert('vehicles', vehicle);
  }

  Future<List<Map<String, dynamic>>> getVehicles() async {
    Database db = await database;
    return await db.query('vehicles', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getVehicle(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateVehicle(Map<String, dynamic> vehicle) async {
    Database db = await database;
    return await db.update(
      'vehicles',
      vehicle,
      where: 'id = ?',
      whereArgs: [vehicle['id']],
    );
  }

  Future<int> deleteVehicle(int id) async {
    Database db = await database;
    return await db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DTC 이력 관련 메서드
  Future<int> insertDTC(Map<String, dynamic> dtc) async {
    Database db = await database;
    return await db.insert('dtc_history', dtc);
  }

  Future<List<Map<String, dynamic>>> getDTCHistory(int vehicleId) async {
    Database db = await database;
    return await db.query(
      'dtc_history',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'detected_at DESC',
    );
  }

  Future<void> clearDTC(int dtcId) async {
    Database db = await database;
    await db.update(
      'dtc_history',
      {'cleared_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [dtcId],
    );
  }

  // 유지보수 일정 관련 메서드
  Future<int> insertMaintenanceSchedule(Map<String, dynamic> schedule) async {
    Database db = await database;
    return await db.insert('maintenance_schedules', schedule);
  }

  Future<List<Map<String, dynamic>>> getMaintenanceSchedules(
      int vehicleId) async {
    Database db = await database;
    return await db.query(
      'maintenance_schedules',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'due_date ASC',
    );
  }

  Future<void> completeMaintenanceTask(int taskId) async {
    Database db = await database;
    await db.update(
      'maintenance_schedules',
      {
        'is_completed': 1,
        'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<int> updateMaintenanceSchedule(Map<String, dynamic> schedule) async {
    Database db = await database;
    return await db.update(
      'maintenance_schedules',
      schedule,
      where: 'id = ?',
      whereArgs: [schedule['id']],
    );
  }

  Future<int> deleteMaintenanceSchedule(int id) async {
    Database db = await database;
    return await db.delete(
      'maintenance_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 운행 기록 관련 메서드
  Future<int> startTrip(Map<String, dynamic> trip) async {
    Database db = await database;
    return await db.insert('trip_logs', trip);
  }

  Future<void> endTrip(int tripId, Map<String, dynamic> endData) async {
    Database db = await database;
    await db.update(
      'trip_logs',
      endData,
      where: 'id = ?',
      whereArgs: [tripId],
    );
  }

  Future<List<Map<String, dynamic>>> getTripLogs(int vehicleId) async {
    Database db = await database;
    return await db.query(
      'trip_logs',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'start_time DESC',
    );
  }

  // 센서 데이터 관련 메서드
  Future<void> insertSensorLog(Map<String, dynamic> log) async {
    Database db = await database;
    await db.insert('sensor_logs', log);
  }

  Future<List<Map<String, dynamic>>> getSensorLogs(int tripId) async {
    Database db = await database;
    return await db.query(
      'sensor_logs',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'timestamp ASC',
    );
  }
}

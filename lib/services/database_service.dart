import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databaseDirectory = await getDatabasesPath();
    final databasePath = join(databaseDirectory, 'alertxband_history.db');

    return openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) async {
        await _createSensorHistoryTable(db);
        await _createEmergencyContactsTable(db);
        await _createEmergencyEventsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createEmergencyContactsTable(db);
          await _createEmergencyEventsTable(db);
        }
      },
    );
  }

  // --------------------------------------------------
  // DATABASE TABLE CREATION
  // --------------------------------------------------

  Future<void> _createSensorHistoryTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE sensor_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        temperature REAL,
        humidity REAL,
        heart_rate INTEGER,
        spo2 INTEGER,
        mq2_raw_adc INTEGER,
        acceleration_g REAL,
        gyro_dps REAL,
        device_connected INTEGER NOT NULL,
        gps_available INTEGER NOT NULL,
        fall_detected INTEGER NOT NULL,
        temperature_valid INTEGER NOT NULL,
        humidity_valid INTEGER NOT NULL,
        health_signal_valid INTEGER NOT NULL,
        mq2_available INTEGER NOT NULL,
        motion_available INTEGER NOT NULL,
        recorded_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_sensor_history_recorded_at
      ON sensor_history(recorded_at)
    ''');
  }

  Future<void> _createEmergencyContactsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS emergency_contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        relationship TEXT NOT NULL,
        is_primary INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_emergency_contacts_primary
      ON emergency_contacts(is_primary)
    ''');
  }

  Future<void> _createEmergencyEventsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS emergency_events (
        event_id TEXT PRIMARY KEY,
        device_id TEXT NOT NULL,
        event_type TEXT NOT NULL,
        severity TEXT NOT NULL,
        description TEXT,
        timestamp TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        gps_valid INTEGER NOT NULL DEFAULT 0,
        wifi_status TEXT NOT NULL DEFAULT 'PENDING',
        gsm_status TEXT NOT NULL DEFAULT 'PENDING',
        acknowledgement_status TEXT NOT NULL DEFAULT 'PENDING',
        is_resolved INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_emergency_events_timestamp
      ON emergency_events(timestamp)
    ''');
  }

  // --------------------------------------------------
  // SENSOR HISTORY - EXISTING FUNCTIONALITY
  // --------------------------------------------------

  Future<int> insertSensorReading(Map<String, dynamic> reading) async {
    final db = await database;

    return db.insert(
      'sensor_history',
      reading,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getSensorHistory({int limit = 100}) async {
    final db = await database;

    return db.query(
      'sensor_history',
      orderBy: 'recorded_at DESC',
      limit: limit,
    );
  }

  Future<int> deleteAllHistory() async {
    final db = await database;
    return db.delete('sensor_history');
  }

  // --------------------------------------------------
  // EMERGENCY CONTACTS
  // --------------------------------------------------

  Future<int> insertEmergencyContact(Map<String, dynamic> contact) async {
    final db = await database;

    final data = Map<String, dynamic>.from(contact);

    data['created_at'] ??= DateTime.now().toIso8601String();
    data['is_primary'] = data['is_primary'] == true || data['is_primary'] == 1
        ? 1
        : 0;

    return db.transaction((txn) async {
      if (data['is_primary'] == 1) {
        await txn.update('emergency_contacts', {'is_primary': 0});
      }

      return txn.insert(
        'emergency_contacts',
        data,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    final db = await database;

    return db.query(
      'emergency_contacts',
      orderBy: 'is_primary DESC, name COLLATE NOCASE ASC',
    );
  }

  Future<Map<String, dynamic>?> getPrimaryEmergencyContact() async {
    final db = await database;

    final result = await db.query(
      'emergency_contacts',
      where: 'is_primary = ?',
      whereArgs: [1],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  Future<int> updateEmergencyContact(
    String id,
    Map<String, dynamic> contact,
  ) async {
    final db = await database;
    final data = Map<String, dynamic>.from(contact);

    data.remove('id');
    data.remove('created_at');

    final isPrimary = data['is_primary'] == true || data['is_primary'] == 1;

    data['is_primary'] = isPrimary ? 1 : 0;

    return db.transaction((txn) async {
      if (isPrimary) {
        await txn.update('emergency_contacts', {'is_primary': 0});
      }

      return txn.update(
        'emergency_contacts',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<int> setPrimaryEmergencyContact(String id) async {
    final db = await database;

    return db.transaction((txn) async {
      final contact = await txn.query(
        'emergency_contacts',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (contact.isEmpty) return 0;

      await txn.update('emergency_contacts', {'is_primary': 0});

      return txn.update(
        'emergency_contacts',
        {'is_primary': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<int> deleteEmergencyContact(String id) async {
    final db = await database;

    return db.delete('emergency_contacts', where: 'id = ?', whereArgs: [id]);
  }

  // --------------------------------------------------
  // EMERGENCY EVENTS
  // --------------------------------------------------

  Future<int> insertEmergencyEvent(Map<String, dynamic> event) async {
    final db = await database;

    return db.insert(
      'emergency_events',
      event,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Map<String, dynamic>>> getEmergencyEvents({
    int limit = 100,
  }) async {
    final db = await database;

    return db.query(
      'emergency_events',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  Future<Map<String, dynamic>?> getEmergencyEvent(String eventId) async {
    final db = await database;

    final result = await db.query(
      'emergency_events',
      where: 'event_id = ?',
      whereArgs: [eventId],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  Future<int> updateEmergencyEvent(
    String eventId,
    Map<String, dynamic> updates,
  ) async {
    const allowedFields = {
      'wifi_status',
      'gsm_status',
      'acknowledgement_status',
      'is_resolved',
    };

    final safeUpdates = Map<String, dynamic>.fromEntries(
      updates.entries.where((entry) => allowedFields.contains(entry.key)),
    );

    if (safeUpdates.isEmpty) return 0;

    final db = await database;

    return db.update(
      'emergency_events',
      safeUpdates,
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
  }

  Future<int> resolveEmergencyEvent(String eventId) async {
    final db = await database;

    return db.update(
      'emergency_events',
      {'is_resolved': 1},
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
  }

  Future<int> deleteEmergencyEvent(String eventId) async {
    final db = await database;

    return db.delete(
      'emergency_events',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
  }

  Future<int> deleteAllEmergencyEvents() async {
    final db = await database;
    return db.delete('emergency_events');
  }
}

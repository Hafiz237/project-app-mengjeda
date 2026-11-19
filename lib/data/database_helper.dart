import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../models/jadwal_model.dart';
import 'dummy_alarms.dart';
import 'dummy_jadwal.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mengjeda.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          nama TEXT,
          email TEXT UNIQUE,
          password TEXT,
          salt TEXT
        )
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarms (
        id TEXT PRIMARY KEY,
        label TEXT,
        hour INTEGER,
        minute INTEGER,
        tone TEXT,
        isActive INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE jadwals (
        id TEXT PRIMARY KEY,
        label TEXT,
        hour INTEGER,
        minute INTEGER,
        kategoriId TEXT,
        isActive INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE medias (
        id TEXT PRIMARY KEY,
        nama TEXT,
        filePath TEXT,
        assetPath TEXT,
        isActive INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE audios (
        id TEXT PRIMARY KEY,
        nama TEXT,
        filePath TEXT,
        assetPath TEXT,
        isActive INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        nama TEXT,
        email TEXT UNIQUE,
        password TEXT,
        salt TEXT
      )
    ''');

    for (var alarm in dummyAlarms) {
      await db.insert('alarms', {
        'id': alarm.id,
        'label': alarm.label,
        'hour': alarm.time.hour,
        'minute': alarm.time.minute,
        'tone': alarm.tone,
        'isActive': alarm.isActive ? 1 : 0,
      });
    }

    for (var jadwal in dummyJadwal) {
      await db.insert('jadwals', {
        'id': jadwal.id,
        'label': jadwal.label,
        'hour': jadwal.time.hour,
        'minute': jadwal.time.minute,
        'kategoriId': jadwal.kategoriId,
        'isActive': jadwal.isActive ? 1 : 0,
      });
    }
  }

  Future<void> insertAlarm(AlarmModel alarm) async {
    final db = await instance.database;
    await db.insert('alarms', {
      'id': alarm.id,
      'label': alarm.label,
      'hour': alarm.time.hour,
      'minute': alarm.time.minute,
      'tone': alarm.tone,
      'isActive': alarm.isActive ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AlarmModel>> getAlarms() async {
    final db = await instance.database;
    final result = await db.query('alarms');
    return result.map((json) => AlarmModel(
      id: json['id'] as String,
      label: json['label'] as String,
      time: TimeOfDay(hour: json['hour'] as int, minute: json['minute'] as int),
      tone: json['tone'] as String,
      isActive: (json['isActive'] as int) == 1,
    )).toList();
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    final db = await instance.database;
    await db.update('alarms', {
      'label': alarm.label,
      'hour': alarm.time.hour,
      'minute': alarm.time.minute,
      'tone': alarm.tone,
      'isActive': alarm.isActive ? 1 : 0,
    }, where: 'id = ?', whereArgs: [alarm.id]);
  }

  Future<void> deleteAlarm(String id) async {
    final db = await instance.database;
    await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertJadwal(JadwalModel jadwal) async {
    final db = await instance.database;
    await db.insert('jadwals', {
      'id': jadwal.id,
      'label': jadwal.label,
      'hour': jadwal.time.hour,
      'minute': jadwal.time.minute,
      'kategoriId': jadwal.kategoriId,
      'isActive': jadwal.isActive ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<JadwalModel>> getJadwals() async {
    final db = await instance.database;
    final result = await db.query('jadwals');
    return result.map((json) => JadwalModel(
      id: json['id'] as String,
      label: json['label'] as String,
      time: TimeOfDay(hour: json['hour'] as int, minute: json['minute'] as int),
      kategoriId: json['kategoriId'] as String,
      isActive: (json['isActive'] as int) == 1,
    )).toList();
  }

  Future<void> updateJadwal(JadwalModel jadwal) async {
    final db = await instance.database;
    await db.update('jadwals', {
      'label': jadwal.label,
      'hour': jadwal.time.hour,
      'minute': jadwal.time.minute,
      'kategoriId': jadwal.kategoriId,
      'isActive': jadwal.isActive ? 1 : 0,
    }, where: 'id = ?', whereArgs: [jadwal.id]);
  }

  Future<void> deleteJadwal(String id) async {
    final db = await instance.database;
    await db.delete('jadwals', where: 'id = ?', whereArgs: [id]);
  }
}
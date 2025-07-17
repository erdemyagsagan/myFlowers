import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'users.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> deleteScanHistoryItem(int id) async {
    final db = await database;
    await db.delete('scan_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _onCreate(Database db, int version) async {
    // users tablosu
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // scan_history tablosu
    await db.execute('''
      CREATE TABLE scan_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        flower_name TEXT NOT NULL,
        confidence REAL NOT NULL,
        image_path TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Eğer önceki versiyon 1 ise, scan_history tablosunu ekle
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE scan_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL,
          flower_name TEXT NOT NULL,
          confidence REAL NOT NULL,
          image_path TEXT NOT NULL,
          timestamp TEXT NOT NULL
        )
      ''');
    }
  }

  /// Yeni kullanıcı ekler
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.insert('users', user);
  }

  /// Email ile kullanıcı sorgular
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Tahmin geçmişini ekler
  Future<void> insertPrediction(
    String email,
    String flowerName,
    double confidence,
    String imagePath,
  ) async {
    final db = await database;
    await db.insert('scan_history', {
      'email': email,
      'flower_name': flowerName,
      'confidence': confidence,
      'image_path': imagePath,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Kullanıcının tüm tahmin geçmişini döner
  Future<List<Map<String, dynamic>>> getScanHistory(String email) async {
    final db = await database;
    return db.query(
      'scan_history',
      where: 'email = ?',
      whereArgs: [email],
      orderBy: 'timestamp DESC',
    );
  }
}

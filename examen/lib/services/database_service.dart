import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/character_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'favorites.db');
    return await openDatabase(
      path,
      version: 2, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER,
        username TEXT,
        name TEXT,
        image TEXT,
        PRIMARY KEY (id, username)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS favorites');
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER,
        username TEXT,
        name TEXT,
        image TEXT,
        PRIMARY KEY (id, username)
      )
    ''');
  }

  Future<void> addFavorite(Character character, String username) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'id': character.id,
        'username': username,
        'name': character.name,
        'image': character.imageUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(int id, String username) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ? AND username = ?',
      whereArgs: [id, username],
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites(String username) async {
    final db = await database;
    return await db.query(
      'favorites',
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<bool> isFavorite(int id, String username) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'id = ? AND username = ?',
      whereArgs: [id, username],
    );
    return result.isNotEmpty;
  }
}
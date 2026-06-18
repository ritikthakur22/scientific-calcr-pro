import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('scientific_calcr_pro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. History Table
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expression TEXT NOT NULL,
        result TEXT NOT NULL,
        mode TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // 2. Formulas Table
    await db.execute('''
      CREATE TABLE formulas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        formula TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // 3. Notes Table
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    // 4. Indexes for optimization
    await db.execute('CREATE INDEX idx_history_timestamp ON history (timestamp)');
    await db.execute('CREATE INDEX idx_history_mode ON history (mode)');
    await db.execute('CREATE INDEX idx_formulas_favorite ON formulas (is_favorite)');

    // Prepopulate some essential equations in the formula vault
    await _prepopulateFormulas(db);
  }

  Future _prepopulateFormulas(Database db) async {
    final List<Map<String, dynamic>> initialFormulas = [
      {
        'name': 'Quadratic Formula',
        'formula': 'x = (-b ± √(b² - 4ac)) / (2a)',
        'description': 'Solves ax² + bx + c = 0',
        'category': 'Algebra',
        'is_favorite': 1,
      },
      {
        'name': 'Euler\'s Identity',
        'formula': 'e^(iπ) + 1 = 0',
        'description': 'Relates five fundamental mathematical constants',
        'category': 'Complex Math',
        'is_favorite': 0,
      },
      {
        'name': 'Ohm\'s Law',
        'formula': 'V = I * R',
        'description': 'Voltage = Current * Resistance',
        'category': 'Physics / Engineering',
        'is_favorite': 1,
      },
      {
        'name': 'Einstein\'s Mass-Energy Equivalence',
        'formula': 'E = m * c²',
        'description': 'Relates energy, mass, and the speed of light',
        'category': 'Physics',
        'is_favorite': 0,
      },
      {
        'name': 'Area of Circle',
        'formula': 'A = π * r²',
        'description': 'Calculates area from radius r',
        'category': 'Geometry',
        'is_favorite': 0,
      },
    ];

    for (var f in initialFormulas) {
      await db.insert('formulas', f);
    }
  }

  // --- History CRUD Operations ---
  Future<int> insertHistory(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('history', row);
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await instance.database;
    return await db.query('history', orderBy: 'id DESC');
  }

  Future<int> clearHistory() async {
    final db = await instance.database;
    return await db.delete('history');
  }

  // --- Formulas CRUD Operations ---
  Future<int> insertFormula(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('formulas', row);
  }

  Future<List<Map<String, dynamic>>> getFormulas() async {
    final db = await instance.database;
    return await db.query('formulas', orderBy: 'name ASC');
  }

  Future<int> updateFormulaFavorite(int id, bool isFavorite) async {
    final db = await instance.database;
    return await db.update(
      'formulas',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFormula(int id) async {
    final db = await instance.database;
    return await db.delete('formulas', where: 'id = ?', whereArgs: [id]);
  }

  // --- Notes CRUD Operations ---
  Future<int> insertNote(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('notes', row);
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await instance.database;
    return await db.query('notes', orderBy: 'timestamp DESC');
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}

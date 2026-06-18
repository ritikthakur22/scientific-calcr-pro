import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite ffi for tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('Database Query Speed Benchmark (With and Without Indexes)', () async {
    // 1. Create database without indexes
    final dbWithout = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            expression TEXT NOT NULL,
            result TEXT NOT NULL,
            mode TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
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
      },
    );

    // 2. Create database with indexes
    final dbWith = await openDatabase(
      'with_indexes.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            expression TEXT NOT NULL,
            result TEXT NOT NULL,
            mode TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
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
        // Add indexes
        await db.execute('CREATE INDEX idx_history_timestamp ON history (timestamp)');
        await db.execute('CREATE INDEX idx_history_mode ON history (mode)');
        await db.execute('CREATE INDEX idx_formulas_favorite ON formulas (is_favorite)');
      },
    );

    // 3. Populate databases with 2,000 rows each
    const int recordCount = 2000;
    final batchWithout = dbWithout.batch();
    final batchWith = dbWith.batch();

    for (int i = 0; i < recordCount; i++) {
      final historyRow = {
        'expression': '2 + $i',
        'result': '${2 + i}',
        'mode': i % 2 == 0 ? 'COMPLEX' : 'STANDARD',
        'timestamp': DateTime.now().subtract(Duration(minutes: i)).toIso8601String(),
      };
      batchWithout.insert('history', historyRow);
      batchWith.insert('history', historyRow);

      final formulaRow = {
        'name': 'Formula $i',
        'formula': 'x + $i',
        'description': 'Description $i',
        'category': 'Algebra',
        'is_favorite': i % 5 == 0 ? 1 : 0,
      };
      batchWithout.insert('formulas', formulaRow);
      batchWith.insert('formulas', formulaRow);
    }

    await batchWithout.commit(noResult: true);
    await batchWith.commit(noResult: true);

    // 4. Benchmark without indexes
    final watchWithout = Stopwatch()..start();
    for (int i = 0; i < 100; i++) {
      await dbWithout.query('history', orderBy: 'timestamp DESC', limit: 50);
      await dbWithout.query('history', where: 'mode = ?', whereArgs: ['COMPLEX']);
      await dbWithout.query('formulas', where: 'is_favorite = ?', whereArgs: [1]);
    }
    watchWithout.stop();
    final double timeWithoutMs = watchWithout.elapsedMicroseconds / 1000.0;

    // 5. Benchmark with indexes
    final watchWith = Stopwatch()..start();
    for (int i = 0; i < 100; i++) {
      await dbWith.query('history', orderBy: 'timestamp DESC', limit: 50);
      await dbWith.query('history', where: 'mode = ?', whereArgs: ['COMPLEX']);
      await dbWith.query('formulas', where: 'is_favorite = ?', whereArgs: [1]);
    }
    watchWith.stop();
    final double timeWithMs = watchWith.elapsedMicroseconds / 1000.0;

    print("BENCHMARK_RESULT: SQLite queries WITHOUT indexes = ${timeWithoutMs.toStringAsFixed(2)} ms");
    print("BENCHMARK_RESULT: SQLite queries WITH indexes = ${timeWithMs.toStringAsFixed(2)} ms");

    await dbWithout.close();
    await dbWith.close();
  });
}

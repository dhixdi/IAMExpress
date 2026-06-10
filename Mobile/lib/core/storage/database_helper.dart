import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/packages/domain/package_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('iamexpress_offline.db');
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE packages (
        package_id INTEGER PRIMARY KEY,
        resi TEXT NOT NULL,
        nama_paket TEXT NOT NULL,
        alamat_pengirim TEXT,
        alamat_tujuan TEXT,
        no_hp_pengirim TEXT,
        no_hp_penerima TEXT,
        deskripsi_barang TEXT,
        berat REAL,
        jenis_layanan TEXT,
        ongkos_kirim REAL,
        receiver_lat REAL,
        receiver_lng REAL,
        current_status TEXT NOT NULL,
        current_warehouse_id INTEGER,
        current_warehouse_name TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertPackages(List<PackageModel> packages) async {
    final db = await instance.database;
    final batch = db.batch();

    for (var pkg in packages) {
      batch.insert(
        'packages',
        pkg.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<PackageModel>> getPackages({String? statusFilter, String? query}) async {
    final db = await instance.database;
    
    String where = '1=1';
    List<dynamic> whereArgs = [];

    if (statusFilter != null && statusFilter.isNotEmpty) {
      where += ' AND current_status = ?';
      whereArgs.add(statusFilter);
    }

    if (query != null && query.isNotEmpty) {
      where += ' AND (resi LIKE ? OR nama_paket LIKE ? OR alamat_tujuan LIKE ?)';
      whereArgs.addAll(['%\$query%', '%\$query%', '%\$query%']);
    }

    final result = await db.query(
      'packages',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return result.map((json) => PackageModel.fromMap(json)).toList();
  }

  Future<void> clearPackages() async {
    final db = await instance.database;
    await db.delete('packages');
  }
}

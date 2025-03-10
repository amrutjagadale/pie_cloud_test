import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  // Increase the version to trigger onUpgrade
  static final _databaseVersion = 2;
  static final table = 'images';
  static final columnId = '_id';
  static final columnImagePath = 'imagePath'; // new column name
  static final columnDate = 'date'; // e.g., 'dd/MM/yyyy'
  static final columnTime = 'time'; // e.g., 'HH:mm:ss'

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnImagePath TEXT NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnTime TEXT NOT NULL
      )
    ''');
  }

  // This onUpgrade method simply drops the table and re-creates it.
  // In a production app, consider migrating data instead.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute("DROP TABLE IF EXISTS $table");
    await _onCreate(db, newVersion);
  }

  Future<int> insertImage(String imagePath, String date, String time) async {
    Database db = await instance.database;
    Map<String, dynamic> row = {
      columnImagePath: imagePath,
      columnDate: date,
      columnTime: time,
    };
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> getImages() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  /// Copies the [imageFile] into the app's documents directory and returns the new file path.
  Future<String> saveImageToFileSystem(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.uri.pathSegments.last}';
    String filePath = join(directory.path, fileName);
    final savedFile = await imageFile.copy(filePath);
    return savedFile.path;
  }
}

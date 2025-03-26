import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/folder.dart';

// Folder Database Helper
// This class handles all database operations for folders
// It uses SQLite to store the data permanently on the device
class FolderDatabase {
  // Singleton pattern - only one instance of the database
  static final FolderDatabase instance = FolderDatabase._init();
  static Database? _database;
  
  // Private constructor
  FolderDatabase._init();
  
  // Get database - creates it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('folders.db');
    return _database!;
  }
  
  // Initialize the database
  Future<Database> _initDB(String filePath) async {
    // Get the path to the database file
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    // Open the database (creates it if it doesn't exist)
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  
  // Create the folders table
  Future _createDB(Database db, int version) async {
    // Define column types
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    
    // Create the folders table with simple structure
    await db.execute('''
    CREATE TABLE folders (
      id $idType,
      name $textType UNIQUE
    )
    ''');
    
    // Add the Default folder (always exists)
    await db.insert('folders', {'name': 'Default'});
  }
  
  // ===== CRUD OPERATIONS =====
  
  // Create: Add a new folder to database
  Future<int> insertFolder(Folder folder) async {
    final db = await database;
    
    // Try to insert, but ignore if the folder name already exists
    try {
      return await db.insert(
        'folders', 
        folder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore, // Skip if folder exists
      );
    } catch (e) {
      return -1; // Return -1 if insertion fails
    }
  }
  
  // Read: Get all folders from database
  Future<List<Folder>> getAllFolders() async {
    final db = await database;
    
    // Get all rows from the folders table
    final List<Map<String, dynamic>> maps = await db.query('folders');
    
    // Convert List<Map> to List<Folder>
    return List.generate(maps.length, (i) {
      return Folder.fromMap(maps[i]);
    });
  }
  
  // Check if a folder with this name exists
  Future<bool> folderExists(String folderName) async {
    final db = await database;
    
    final List<Map<String, dynamic>> result = await db.query(
      'folders',
      where: 'name = ?',
      whereArgs: [folderName],
    );
    
    return result.isNotEmpty;
  }
  
  // Update: Rename a folder
  Future<int> renameFolder(String oldName, String newName) async {
    final db = await database;
    
    // Don't allow renaming the Default folder
    if (oldName == 'Default') return 0;
    
    // Check if new name already exists
    if (await folderExists(newName)) return 0;
    
    return await db.update(
      'folders',
      {'name': newName},
      where: 'name = ?',
      whereArgs: [oldName],
    );
  }
  
  // Delete: Remove a folder
  Future<int> deleteFolder(String folderName) async {
    final db = await database;
    
    // Don't allow deleting the Default folder
    if (folderName == 'Default') return 0;
    
    return await db.delete(
      'folders',
      where: 'name = ?',
      whereArgs: [folderName],
    );
  }
  
  // Reset folders to just Default
  Future<void> resetToDefault() async {
    final db = await database;
    
    // Delete all folders except Default
    await db.delete(
      'folders',
      where: 'name != ?',
      whereArgs: ['Default'],
    );
  }
  
  // Close the database
  Future close() async {
    final db = await database;
    db.close();
  }
}

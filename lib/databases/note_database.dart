import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

// Note Database Helper
// This class handles all database operations for notes
// It uses SQLite to store the data permanently on the device
class NoteDatabase {
  // Singleton pattern - only one instance of the database
  static final NoteDatabase instance = NoteDatabase._init();
  static Database? _database;
  
  // Private constructor
  NoteDatabase._init();
  
  // Get database - creates it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
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
  
  // Create the notes table
  Future _createDB(Database db, int version) async {
    // Define column types
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL'; // SQLite has no boolean, so we use INTEGER (0 or 1)
    
    // Create the notes table
    await db.execute('''
    CREATE TABLE notes (
      id $idType,
      title $textType,
      content TEXT,
      isPinned $boolType,
      folder $textType,
      lastModified $textType
    )
    ''');
  }
  
  // ===== CRUD OPERATIONS =====
  
  // Create: Add a new note to database
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }
  
  // Read: Get all notes from database
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    
    // Get all rows from the notes table
    final List<Map<String, dynamic>> maps = await db.query('notes');
    
    // Convert List<Map> to List<Note>
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
  
  // Read: Get notes by folder
  Future<List<Note>> getNotesByFolder(String folderName) async {
    final db = await database;
    
    // Get notes matching the folder name
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'folder = ?',
      whereArgs: [folderName],
    );
    
    // Convert List<Map> to List<Note>
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
  
  // Update: Modify existing note
  Future<int> updateNote(int id, Note note) async {
    final db = await database;
    
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Delete: Remove a note
  Future<int> deleteNote(int id) async {
    final db = await database;
    
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Delete all notes in a folder
  Future<int> deleteNotesInFolder(String folderName) async {
    final db = await database;
    
    return await db.delete(
      'notes',
      where: 'folder = ?',
      whereArgs: [folderName],
    );
  }
  
  // Update notes folder when a folder is deleted
  Future<int> moveNotesToFolder(String oldFolder, String newFolder) async {
    final db = await database;
    
    return await db.update(
      'notes',
      {'folder': newFolder},
      where: 'folder = ?',
      whereArgs: [oldFolder],
    );
  }
  
  // Close the database
  Future close() async {
    final db = await database;
    db.close();
  }
}

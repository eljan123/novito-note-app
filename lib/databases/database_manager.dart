import 'note_database.dart';
import 'folder_database.dart';

// Database Manager
// This class provides easy access to all the database helpers in one place
// It initializes all databases and ensures they're ready to use
class DatabaseManager {
  // Singleton pattern - only one instance
  static final DatabaseManager instance = DatabaseManager._init();
  
  // Database helpers
  final NoteDatabase noteDB = NoteDatabase.instance;
  final FolderDatabase folderDB = FolderDatabase.instance;
  
  // Private constructor
  DatabaseManager._init();
  
  // Initialize all databases
  Future<void> initializeAll() async {
    // Access each database to ensure it's initialized
    await noteDB.database;
    await folderDB.database;
    
    //print('All databases initialized');
  }
  
  // Close all databases
  Future<void> closeAll() async {
    await noteDB.close();
    await folderDB.close();
    
    //print('All databases closed');
  }
} 
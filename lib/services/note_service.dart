import '../models/note.dart';
import '../models/folder.dart';
import '../databases/note_database.dart';
import '../databases/folder_database.dart';

// This class manages all notes and folders in the app
// It's a "singleton" which means there's only one instance throughout the app
class NoteService {
  // SINGLETON PATTERN START
  // This creates a single instance that all screens will share
  // We only want one list of notes shared everywhere!
  
  // The one and only instance of NoteService
  static final NoteService _instance = NoteService._internal();
  
  // Database helpers
  final NoteDatabase _noteDB = NoteDatabase.instance;
  final FolderDatabase _folderDB = FolderDatabase.instance;
  
  // In-memory cache
  List<Note> _notes = [];
  List<Folder> _folders = [];
  
  // When someone calls NoteService(), return the existing instance
  factory NoteService() {
    return _instance;
  }
  
  // Private constructor - only called once by _instance
  NoteService._internal() {
    // Load data from database when service is created
    _loadFromDatabase();
  }
  
  // Load data from database into memory
  Future<void> _loadFromDatabase() async {
    try {
      // Load notes
      _notes = await _noteDB.getAllNotes();
      
      // Load folders
      _folders = await _folderDB.getAllFolders();
      
      // Make sure we have at least a Default folder
      if (_folders.isEmpty) {
        final defaultFolder = Folder(name: 'Default');
        await _folderDB.insertFolder(defaultFolder);
        _folders = await _folderDB.getAllFolders();
      }
    } catch (e) {
      //print('Error loading from database: $e');
      // Initialize with empty data if we can't load
      _notes = [];
      _folders = [Folder(name: 'Default')];
    }
  }
  
  // ===== FOLDER METHODS =====
  
  // Get a list of all folders
  List<Folder> getFolders() {
    return _folders;
  }
  
  // Add a new folder if the name doesn't already exist
  Future<void> addFolder(Folder folder) async {
    // Check if a folder with this name already exists
    bool folderExists = false;
    for (var existingFolder in _folders) {
      if (existingFolder.name == folder.name) {
        folderExists = true;
        break;
      }
    }
    
    // Only add if the folder doesn't exist yet
    if (!folderExists) {
      // Add to database first
      final id = await _folderDB.insertFolder(folder);
      if (id > 0) {
        // If successful, add to memory cache
        folder.id = id; // Set the ID from database
        _folders.add(folder);
      }
    }
  }
  
  // Delete a folder and move its notes to Default
  Future<void> deleteFolder(String folderName) async {
    // Can't delete the Default folder
    if (folderName == 'Default') return;
    
    // Move all notes from this folder to Default in database
    await _noteDB.moveNotesToFolder(folderName, 'Default');
    
    // Update notes in memory
    for (var note in _notes) {
      if (note.folder == folderName) {
        note.folder = 'Default';
        // We don't need to update the database again since we've already done it
      }
    }
    
    // Delete the folder from database
    await _folderDB.deleteFolder(folderName);
    
    // Update memory cache
    _folders.removeWhere((folder) => folder.name == folderName);
  }

  // ===== NOTE METHODS =====
  
  // Get all notes
  List<Note> getNotes() {
    return _notes;
  }
  
  // Get notes in a specific folder
  List<Note> getNotesByFolder(String folderName) {
    // Filter notes that belong to the specified folder
    List<Note> folderNotes = [];
    for (var note in _notes) {
      if (note.folder == folderName) {
        folderNotes.add(note);
      }
    }
    return folderNotes;
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    // Add to database first
    final id = await _noteDB.insertNote(note);
    if (id > 0) {
      // If successful, add to memory cache
      note.id = id; // Set the ID from database
      _notes.add(note);
    }
  }

  // Edit an existing note
  Future<void> editNote(int index, Note updatedNote) async {
    if (index >= 0 && index < _notes.length) {
      // Get the note to update
      final note = _notes[index];
      
      // Make sure the ID is preserved
      updatedNote.id = note.id;
      
      // Update the last modified time
      updatedNote.lastModified = DateTime.now();
      
      // Update in database first
      if (note.id != null) {
        await _noteDB.updateNote(note.id!, updatedNote);
      }
      
      // Update in memory
      _notes[index] = updatedNote;
    }
  }

  // Toggle a note's pinned status
  Future<void> togglePinStatus(int index) async {
    if (index >= 0 && index < _notes.length) {
      // Get the note to update
      final note = _notes[index];
      
      // Flip the pin status (true becomes false, false becomes true)
      note.isPinned = !note.isPinned;
      
      // Update in database
      if (note.id != null) {
        await _noteDB.updateNote(note.id!, note);
      }
    }
  }
  
  // Move a note to a different folder
  Future<void> moveNoteToFolder(int index, String folderName) async {
    if (index >= 0 && index < _notes.length) {
      // Get the note to update
      final note = _notes[index];
      
      // Update folder
      note.folder = folderName;
      
      // Update in database
      if (note.id != null) {
        await _noteDB.updateNote(note.id!, note);
      }
    }
  }

  // Delete a note
  Future<void> deleteNote(int index) async {
    if (index >= 0 && index < _notes.length) {
      // Get the note to delete
      final note = _notes[index];
      
      // Delete from database first
      if (note.id != null) {
        await _noteDB.deleteNote(note.id!);
      }
      
      // Delete from memory
      _notes.removeAt(index);
    }
  }
  
  // Reload all data from database (useful if database was modified elsewhere)
  Future<void> refreshData() async {
    await _loadFromDatabase();
  }
} 
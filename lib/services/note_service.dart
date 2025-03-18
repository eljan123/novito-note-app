import '../models/note.dart';
import '../models/folder.dart';

// This class manages all notes and folders in the app
// It's a "singleton" which means there's only one instance throughout the app
class NoteService {
  // SINGLETON PATTERN START
  // This creates a single instance that all screens will share
  // We only want one list of notes shared everywhere!
  
  // The one and only instance of NoteService
  static final NoteService _instance = NoteService._internal();
  
  // When someone calls NoteService(), return the existing instance
  factory NoteService() {
    return _instance;
  }
  
  // Private constructor - only called once by _instance
  NoteService._internal();
  // SINGLETON PATTERN END
  
  // List to store all notes in the app
  final List<Note> _notes = [];
  
  // List to store all folders
  final List<Folder> _folders = [
    Folder(name: 'Default'), // Always start with a Default folder
  ];

  // ===== FOLDER METHODS =====
  
  // Get a list of all folders
  List<Folder> getFolders() {
    return _folders;
  }
  
  // Add a new folder if the name doesn't already exist
  void addFolder(Folder folder) {
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
      _folders.add(folder);
    }
  }
  
  // Delete a folder and move its notes to Default
  void deleteFolder(String folderName) {
    // Can't delete the Default folder
    if (folderName != 'Default') {
      // Remove the folder
      _folders.removeWhere((folder) => folder.name == folderName);
      
      // Move all notes from this folder to Default
      for (var note in _notes) {
        if (note.folder == folderName) {
          note.folder = 'Default';
        }
      }
    }
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
  void addNote(Note note) {
    _notes.add(note);
  }

  // Edit an existing note
  void editNote(int index, Note updatedNote) {
    if (index >= 0 && index < _notes.length) {
      // Update the last modified time
      updatedNote.lastModified = DateTime.now();
      // Replace the note at the specified index
      _notes[index] = updatedNote;
    }
  }

  // Toggle a note's pinned status
  void togglePinStatus(int index) {
    if (index >= 0 && index < _notes.length) {
      // Flip the pin status (true becomes false, false becomes true)
      _notes[index].isPinned = !_notes[index].isPinned;
    }
  }
  
  // Move a note to a different folder
  void moveNoteToFolder(int index, String folderName) {
    if (index >= 0 && index < _notes.length) {
      _notes[index].folder = folderName;
    }
  }

  // Delete a note
  void deleteNote(int index) {
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index);
    }
  }
} 
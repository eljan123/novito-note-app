import '../models/note.dart';

class NoteService {
  // List to store notes
  final List<Note> _notes = [];

  // Get all notes
  List<Note> getNotes() {
    return _notes;
  }

  // Add a new note
  void addNote(Note note) {
    _notes.add(note);
  }

  // Edit a note
  void editNote(int index, Note updatedNote) {
    if (index >= 0 && index < _notes.length) {
      updatedNote.lastModified = DateTime.now();
      _notes[index] = updatedNote;
    }
  }

  // Toggle pin status
  void togglePinStatus(int index) {
    if (index >= 0 && index < _notes.length) {
      _notes[index].isPinned = !_notes[index].isPinned;
      _notes[index].lastModified = DateTime.now();
    }
  }

  // Delete a note
  void deleteNote(int index) {
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index);
    }
  }
} 
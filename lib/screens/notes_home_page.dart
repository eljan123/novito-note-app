import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'note_add_page.dart';
import 'note_edit_page.dart';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  // Create an instance of NoteService
  final NoteService _noteService = NoteService();

  // Function to add a new note
  void _addNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteAddPage(
          onAdd: (Note newNote) {
            setState(() {
              _noteService.addNote(newNote);
            });
          },
        ),
      ),
    );
  }

  // Function to edit a note
  void _editNote(int index) {
    Note currentNote = _noteService.getNotes()[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditPage(
          note: currentNote,
          index: index,
          onSave: (int idx, Note updatedNote) {
            setState(() {
              _noteService.editNote(idx, updatedNote);
            });
          },
        ),
      ),
    );
  }

  // Function to toggle pin status
  void _togglePinStatus(int index) {
    setState(() {
      _noteService.togglePinStatus(index);
    });
  }

  // Function to delete a note
  void _deleteNote(int index) {
    setState(() {
      _noteService.deleteNote(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Note> notes = _noteService.getNotes();
    
    // Sort notes: pinned notes first, then by index
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // Remove leading drawer menu button
        title: const Text(
          'Novito',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 30,
            color: Colors.white, 
          ),
        ),
        // Add menu button to actions (top right)
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      body: notes.isEmpty
          ? const Center(
              child: Text(
                'No notes yet. Tap the + button to add one.',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  color: notes[index].isPinned ? Colors.orange : const Color(0xFF212121),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      notes[index].title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: notes[index].isPinned ? Colors.black : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      notes[index].content.isEmpty ? 'No content yet' : notes[index].content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins', 
                        color: notes[index].isPinned ? Colors.black54 : Colors.white70,
                      ),
                    ),
                    onTap: () => _editNote(index), // Edit note on tap
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            notes[index].isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            color: notes[index].isPinned ? Colors.black : Colors.white70,
                          ),
                          onPressed: () => _togglePinStatus(index),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: notes[index].isPinned ? Colors.black54 : Colors.red,
                          ),
                          onPressed: () => _deleteNote(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _addNote,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
} 
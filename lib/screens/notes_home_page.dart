import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'note_add_page.dart';
import 'note_edit_page.dart';
import 'dart:async';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final NoteService _noteService = NoteService();
  Timer _timer = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();
    // Update the UI every minute to refresh relative timestamps
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

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
    
    // This will sort the notes... pinned notes first, then by index
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Novito',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Colors.white, 
          ),
        ),
        // Add menu button to actions (para dito nakalagay yung notes pati to-do list)
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet.\nTap the + button to add one.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Hero(
                  tag: 'note_${notes[index].title}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Card(
                      color: notes[index].isPinned ? Colors.orange : const Color(0xFF212121),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => _editNote(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notes[index].title,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: notes[index].isPinned ? Colors.black : Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      notes[index].isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                      color: notes[index].isPinned ? Colors.black : Colors.white70,
                                      size: 22,
                                    ),
                                    onPressed: () => _togglePinStatus(index),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: notes[index].isPinned ? Colors.black54 : Colors.red,
                                      size: 22,
                                    ),
                                    onPressed: () => _deleteNote(index),
                                  ),
                                ],
                              ),
                              if (notes[index].content.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  notes[index].content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    height: 1.3,
                                    color: notes[index].isPinned ? Colors.black54 : Colors.white70,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                'Last modified: ${_formatDateTime(notes[index].lastModified)}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: notes[index].isPinned ? Colors.black38 : Colors.white38,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: _addNote,
          child: const Icon(Icons.my_library_add, color: Colors.black),
        ),
      ),
    );
  }

  // Helper function to format DateTime
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
} 
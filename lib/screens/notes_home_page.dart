import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'note_add_page.dart';
import 'note_edit_page.dart';
import 'dart:async';

// ========== NOTES HOME PAGE ==========
// This is the main page of the app which shows all notes regardless of folder
// It lets users:
// 1. See all their notes in one place
// 2. Add new notes
// 3. Edit, pin, and delete notes
// 4. See which folder each note belongs to
//
// KEY CONCEPTS:
// - Notes are sorted with pinned notes at the top
// - Each note shows its title, content preview, and when it was last modified
// - Non-Default folders are shown with folder badges
// - Time formatting shows relative times like "5m ago" or "Yesterday"

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  // Get access to the note service which stores all our data
  final NoteService _noteService = NoteService();
  // Timer used to update the relative timestamps
  Timer _timer = Timer(Duration.zero, () {});
  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Refresh data when page loads
    _refreshData();

    // Update the UI every minute to refresh relative timestamps
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  // Refresh data from database
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Wait for data to refresh
    await _noteService.refreshData();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ===== NOTE MANAGEMENT METHODS =====
  // These methods handle adding, editing, and deleting notes

  // Function to add a new note
  void _addNote() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NoteAddPage(
              onAdd: (Note newNote) async {
                await _noteService.addNote(newNote);
              },
            ),
      ),
    );

    // Check if the widget is still in the tree before using setState
    if (!mounted) return;

    // Refresh the notes list after returning
    setState(() {});
  }

  // Function to edit a note
  void _editNote(int index) async {
    Note currentNote = _noteService.getNotes()[index];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NoteEditPage(
              note: currentNote,
              index: index,
              onSave: (int idx, Note updatedNote) async {
                await _noteService.editNote(idx, updatedNote);
              },
            ),
      ),
    );

    // Check if the widget is still in the tree before using setState
    if (!mounted) return;

    // Refresh the notes list after returning
    setState(() {});
  }

  // Function to toggle pin status
  void _togglePinStatus(int index) async {
    await _noteService.togglePinStatus(index);

    // Check if widget is still mounted before updating state
    if (!mounted) return;

    setState(() {}); // Refresh the UI
  }

  // Function to delete a note with confirmation
  void _deleteNote(int index) {
    // Get the actual note to display its title
    Note noteToDelete = _noteService.getNotes()[index];
    final currentContext = context;

    // Show confirmation dialog before deleting
    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF303030),
          title: const Text(
            'Delete Note',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${noteToDelete.title}"?',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                // Close the dialog first
                Navigator.pop(context);

                // Delete the note
                await _noteService.deleteNote(index);

                // Check if the widget is still in the tree before using BuildContext
                if (!mounted) return;

                // Update the UI
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  // ===== HELPER METHODS =====

  // Helper function to format DateTime in a user-friendly way
  // This converts timestamps to relative time descriptions
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

  @override
  Widget build(BuildContext context) {
    // Get all notes from the service
    List<Note> notes = _noteService.getNotes();

    // Sort the notes: pinned notes first, then by most recent
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.lastModified.compareTo(a.lastModified); // Most recent first
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
        // Only menu button
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () {
              final scaffold = Scaffold.of(context);
              scaffold.openEndDrawer();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : notes.isEmpty
              // Empty state - show a helpful message when there are no notes
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_add_outlined,
                      size: 64,
                      color: Colors.white.withAlpha(179),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No notes yet.\nTap the + button to add one.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              // Note list - show all notes in a scrollable list
              : RefreshIndicator(
                onRefresh: _refreshData,
                color: Colors.orange,
                child: ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: 'note_${notes[index].title}_${notes[index].id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Card(
                          color:
                              notes[index].isPinned
                                  ? Colors.orange
                                  : const Color(0xFF212121),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => _editNote(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Note header row with title, folder badge, and action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notes[index].title,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                notes[index].isPinned
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                        ),
                                      ),
                                      // Show folder indicator badge if not in Default folder
                                      if (notes[index].folder != 'Default') ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                notes[index].isPinned
                                                    ? Colors.black12
                                                    : Colors.orange.withAlpha(
                                                      51,
                                                    ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.folder,
                                                size: 14,
                                                color:
                                                    notes[index].isPinned
                                                        ? Colors.black54
                                                        : Colors.orange,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                notes[index].folder,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      notes[index].isPinned
                                                          ? Colors.black54
                                                          : Colors.orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      // Pin button
                                      IconButton(
                                        icon: Icon(
                                          notes[index].isPinned
                                              ? Icons.push_pin
                                              : Icons.push_pin_outlined,
                                          color:
                                              notes[index].isPinned
                                                  ? Colors.black
                                                  : Colors.white70,
                                          size: 22,
                                        ),
                                        tooltip:
                                            notes[index].isPinned
                                                ? 'Unpin'
                                                : 'Pin to top',
                                        onPressed:
                                            () => _togglePinStatus(index),
                                      ),
                                      // Delete button
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color:
                                              notes[index].isPinned
                                                  ? Colors.black54
                                                  : Colors.red,
                                          size: 22,
                                        ),
                                        tooltip: 'Delete note',
                                        onPressed: () => _deleteNote(index),
                                      ),
                                    ],
                                  ),
                                  // Note content preview (if there is content)
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
                                        color:
                                            notes[index].isPinned
                                                ? Colors.black54
                                                : Colors.white70,
                                      ),
                                    ),
                                  ],
                                  // Last modified timestamp
                                  const SizedBox(height: 8),
                                  Text(
                                    'Last modified: ${_formatDateTime(notes[index].lastModified)}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color:
                                          notes[index].isPinned
                                              ? Colors.black38
                                              : Colors.white38,
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
              ),
      // Add button in the bottom right
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _addNote,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

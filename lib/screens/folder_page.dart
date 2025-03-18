import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'note_edit_page.dart';
import 'note_add_page.dart';

// This page shows notes organized by folders
// It lets users:
// 1. Create and manage folders
// 2. See notes in each folder
// 3. Add new notes directly to a folder
// 4. Edit, pin, and delete notes

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final NoteService _noteService = NoteService();
  String _selectedFolder = 'Default';

  // FOLDER MANAGEMENT METHODS

  // Create a new folder with a dialog
  void _addFolder() {
    final TextEditingController folderNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF303030),
          title: const Text(
            'Create New Folder',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: folderNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter folder name',
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (folderNameController.text.isNotEmpty) {
                  setState(() {
                    _noteService.addFolder(Folder(name: folderNameController.text));
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
  
  // Delete a folder after confirmation
  void _deleteFolder(String folderName) {
    // Confirm before deleting
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF303030),
          title: const Text(
            'Delete Folder',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "$folderName"?\n\nAll notes will be moved to Default folder.',
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
              onPressed: () {
                setState(() {
                  _noteService.deleteFolder(folderName);
                  if (_selectedFolder == folderName) {
                    _selectedFolder = 'Default';
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Show options when long-pressing a folder
  void _showFolderOptions(Folder folder) {
    if (folder.name == 'Default') {
      // Can't delete Default folder
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF303030),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Folder',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteFolder(folder.name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text(
                'Rename Folder',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _renameFolderDialog(folder);
              },
            ),
          ],
        );
      },
    );
  }
  
  // Show dialog to rename a folder
  void _renameFolderDialog(Folder folder) {
    final TextEditingController folderNameController = TextEditingController(text: folder.name);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF303030),
          title: const Text(
            'Rename Folder',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: folderNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter new folder name',
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Rename'),
              onPressed: () {
                if (folderNameController.text.isNotEmpty && 
                    folderNameController.text != folder.name) {
                  setState(() {
                    // Create new folder with new name
                    final newFolder = Folder(name: folderNameController.text);
                    _noteService.addFolder(newFolder);
                    
                    // Move notes from old to new folder
                    List<Note> notes = _noteService.getNotesByFolder(folder.name);
                    for (var note in notes) {
                      note.folder = newFolder.name;
                    }
                    
                    // Delete old folder
                    _noteService.deleteFolder(folder.name);
                    
                    // Update selected folder if needed
                    if (_selectedFolder == folder.name) {
                      _selectedFolder = newFolder.name;
                    }
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // NOTE MANAGEMENT METHODS

  // Add a new note to the current folder
  void _addNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteAddPage(
          onAdd: (Note newNote) {
            // Make sure it's added to the current folder
            newNote.folder = _selectedFolder;
            setState(() {
              _noteService.addNote(newNote);
            });
          },
        ),
      ),
    ).then((_) => setState(() {}));
  }

  // Edit an existing note (opens note edit page)
  void _editNote(int index, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditPage(
          note: note,
          index: index,
          onSave: (int idx, Note updatedNote) {
            setState(() {
              _noteService.editNote(idx, updatedNote);
            });
          },
        ),
      ),
    ).then((_) => setState(() {}));
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

  // HELPER METHOD - Format dates in a human-readable way  
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
    // Get data we need to display
    List<Folder> folders = _noteService.getFolders();
    List<Note> notes = _noteService.getNotesByFolder(_selectedFolder);
    
    // Sort notes - pinned first, then by most recent
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.lastModified.compareTo(a.lastModified); // Most recent first
    });
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Folder: $_selectedFolder',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white, 
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, color: Colors.orange),
            onPressed: _addFolder,
          ),
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () {
              // Open the end drawer
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // TOP SECTION: Horizontal scrolling folder chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: folders.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onLongPress: () => _showFolderOptions(folders[index]),
                    child: ChoiceChip(
                      label: Text(folders[index].name),
                      selected: _selectedFolder == folders[index].name,
                      selectedColor: Colors.orange,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFolder = folders[index].name;
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          // BOTTOM SECTION: List of notes in selected folder
          Expanded(
            child: notes.isEmpty
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
                          'No notes in "$_selectedFolder" folder.\nTap the + button to add one.',
                          style: const TextStyle(
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
                      return Card(
                        color: notes[index].isPinned ? Colors.orange : const Color(0xFF212121),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () => _editNote(
                            _noteService.getNotes().indexOf(notes[index]), 
                            notes[index]
                          ),
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
                                      onPressed: () => _togglePinStatus(
                                        _noteService.getNotes().indexOf(notes[index])
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: notes[index].isPinned ? Colors.black54 : Colors.red,
                                        size: 22,
                                      ),
                                      onPressed: () => _deleteNote(
                                        _noteService.getNotes().indexOf(notes[index])
                                      ),
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
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _addNote,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
} 
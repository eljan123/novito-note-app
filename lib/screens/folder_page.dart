import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'note_edit_page.dart';
import 'note_add_page.dart';

// ========== FOLDER PAGE ==========
// This page shows notes organized by folders
// It lets users:
// 1. Create and manage folders
// 2. See notes in each folder
// 3. Add new notes directly to a folder
// 4. Edit, pin, and delete notes
//
// KEY CONCEPTS:
// - Folders are shown as chips at the top that you can tap to select
// - Long-pressing a folder lets you rename or delete it
// - The Default folder can't be deleted or renamed
// - All notes have a folder, with Default being the starting folder
// - When a folder is deleted, its notes move to the Default folder

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  // This is the service that manages all notes and folders
  final NoteService _noteService = NoteService();
  // This keeps track of which folder is currently selected
  String _selectedFolder = 'Default';

  // Helper method to safely get a ScaffoldMessenger even after async gaps
  ScaffoldMessengerState _getScaffoldMessenger() {
    assert(mounted, 'Cannot use BuildContext when widget is not mounted');
    return ScaffoldMessenger.of(context);
  }

  // ===== FOLDER MANAGEMENT METHODS =====
  // These methods handle creating, renaming, and deleting folders

  // Create a new folder with a dialog
  void _addFolder() async {
    final TextEditingController folderNameController = TextEditingController();
    final capturedContext = context;
    
    await showDialog<void>(
      context: capturedContext,
      builder: (dialogContext) {
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
                Navigator.pop(dialogContext);
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (folderNameController.text.isNotEmpty) {
                  // Create folder and close dialog - no async operation inside dialog
                  _noteService.addFolder(Folder(name: folderNameController.text));
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        );
      },
    );
    
    // UI update after dialog is closed
    if (!mounted) return;
    setState(() {});
  }
  
  // Delete a folder after confirmation
  void _deleteFolder(String folderName) {
    // Can't delete Default folder - add a friendly check
    if (folderName == 'Default') {
      // Show a simple message explaining why Default can't be deleted
      final scaffoldMessenger = _getScaffoldMessenger();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('The Default folder cannot be deleted.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Store the BuildContext in a local variable before async operation
    final buildContext = context;
    
    // Confirm before deleting
    showDialog<void>(
      context: buildContext,
      builder: (dialogContext) {
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
                Navigator.pop(dialogContext);
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                // Save data we need for the message
                final int notesToMove = _noteService.getNotesByFolder(folderName).length;
                final String folderNameCopy = folderName;
                
                // Close dialog first using the captured context
                Navigator.pop(dialogContext);
                
                // Do the actual deletion
                await _noteService.deleteFolder(folderNameCopy);
                
                // Check if widget is still mounted before updating UI
                if (!mounted) return;
                
                // Update the UI
                setState(() {
                  if (_selectedFolder == folderNameCopy) {
                    _selectedFolder = 'Default';
                  }
                });
                
                // Show feedback message
                String message = 'Folder "$folderNameCopy" deleted.';
                if (notesToMove > 0) {
                  message += ' $notesToMove note${notesToMove == 1 ? '' : 's'} moved to Default folder.';
                }
                
                // Get a new scaffoldMessenger as we're after an async gap
                if (!mounted) return;
                
                final currentScaffoldMessenger = _getScaffoldMessenger();
                currentScaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
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
      final scaffoldMessenger = _getScaffoldMessenger();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('The Default folder cannot be modified or deleted.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF303030),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            // Header with folder name
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Folder: ${folder.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            // Delete option
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Folder',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Notes will be moved to Default folder',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteFolder(folder.name);
              },
            ),
            // Rename option
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text(
                'Rename Folder',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Change the folder name while keeping all notes',
                style: TextStyle(color: Colors.white70, fontSize: 12),
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Explanation text for students
              const Text(
                'Enter a new name for this folder:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              // Text field for new folder name
              TextField(
                controller: folderNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter new folder name',
                  hintStyle: TextStyle(color: Colors.white70),
                  // Add a border for better visibility
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                // Auto-focus the text field and select all text
                autofocus: true,
                onSubmitted: (_) => _performRename(folder, folderNameController.text),
              ),
            ],
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
              onPressed: () => _performRename(folder, folderNameController.text),
            ),
          ],
        );
      },
    );
  }
  
  // Helper method to perform the actual rename operation
  void _performRename(Folder folder, String newName) async {
    // Handle empty name
    if (newName.isEmpty) {
      final scaffoldMessenger = _getScaffoldMessenger();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Folder name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Handle same name
    if (newName == folder.name) {
      Navigator.pop(context);
      return;
    }
    
    // Check if a folder with this name already exists
    bool folderExists = false;
    for (var existingFolder in _noteService.getFolders()) {
      if (existingFolder.name == newName) {
        folderExists = true;
        break;
      }
    }
    
    if (folderExists) {
      // Show error for duplicate folder name
      final scaffoldMessenger = _getScaffoldMessenger();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('A folder with this name already exists'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Save old folder name in case we need it later
    final String oldFolderName = folder.name;
    
    // Close the dialog first
    Navigator.pop(context);
    
    // All checks passed, do the rename
    // Create new folder with new name
    final newFolder = Folder(name: newName);
    await _noteService.addFolder(newFolder);
    
    // Get notes from old folder
    List<Note> notes = _noteService.getNotesByFolder(oldFolderName);
    
    // Move notes to new folder - done one by one to ensure database updates
    for (var note in notes) {
      note.folder = newName;
      if (note.id != null) {
        await _noteService.editNote(_noteService.getNotes().indexOf(note), note);
      }
    }
    
    // Delete old folder
    await _noteService.deleteFolder(oldFolderName);
    
    // Check if widget is still mounted
    if (!mounted) return;
    
    // Update selected folder if needed
    setState(() {
      if (_selectedFolder == oldFolderName) {
        _selectedFolder = newName;
      }
    });
    
    // Show success message
    final scaffoldMessenger = _getScaffoldMessenger();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Folder renamed to "$newName"'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ===== NOTE MANAGEMENT METHODS =====
  // These methods handle adding, editing, and deleting notes

  // Add a new note to the current folder
  void _addNote() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteAddPage(
          onAdd: (Note newNote) async {
            // Make sure it's added to the current folder
            newNote.folder = _selectedFolder;
            await _noteService.addNote(newNote);
          },
        ),
      ),
    );
    
    // Check if widget is still mounted before updating state
    if (!mounted) return;
    
    // Refresh UI
    setState(() {});
  }

  // Edit an existing note (opens note edit page)
  void _editNote(int index, Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditPage(
          note: note,
          index: index,
          onSave: (int idx, Note updatedNote) async {
            await _noteService.editNote(idx, updatedNote);
          },
        ),
      ),
    );
    
    // Check if widget is still mounted before updating state
    if (!mounted) return;
    
    // Refresh UI
    setState(() {});
  }

  // Function to toggle pin status
  void _togglePinStatus(int index) async {
    await _noteService.togglePinStatus(index);
    
    // Check if widget is still mounted before updating state
    if (!mounted) return;
    
    setState(() {});
  }

  // Function to delete a note
  void _deleteNote(int index) {
    // Get the actual note to display its title
    Note noteToDelete = _noteService.getNotes()[index];
    
    // Store the BuildContext in a local variable before async operation
    final buildContext = context;
    
    // Show confirmation dialog
    showDialog<void>(
      context: buildContext,
      builder: (dialogContext) {
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
                Navigator.pop(dialogContext);
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                // Store title before closing dialog
                final String noteTitle = noteToDelete.title;
                
                // Close dialog first using the captured context
                Navigator.pop(dialogContext);
                
                // Delete the note
                await _noteService.deleteNote(index);
                
                // Check if widget is still mounted before updating UI
                if (!mounted) return;
                
                // Update UI
                setState(() {});
                
                // Get a new scaffoldMessenger as we're after an async gap
                if (!mounted) return;
                
                final currentScaffoldMessenger = _getScaffoldMessenger();
                currentScaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Note "$noteTitle" deleted'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'OK',
                      textColor: Colors.white,
                      onPressed: () {
                        currentScaffoldMessenger.hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
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
              final scaffold = Scaffold.of(context);
              scaffold.openEndDrawer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // TOP SECTION: Horizontal scrolling folder chips
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Folder tip text for new users
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
                  child: Text(
                    'Tap to select a folder, long-press for options',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                // Scrollable folder chips
                // ignore: sized_box_for_whitespace
                Container(
                  height: 40,
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
              ],
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
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
} 
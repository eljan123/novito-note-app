import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../services/note_service.dart';

class NoteAddPage extends StatefulWidget {
  final Function(Note) onAdd;

  const NoteAddPage({
    super.key,
    required this.onAdd,
  });

  @override
  State<NoteAddPage> createState() => _NoteAddPageState();
}

class _NoteAddPageState extends State<NoteAddPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  // Default folder
  String _selectedFolder = 'Default'; 
  final NoteService _noteService = NoteService();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.isNotEmpty) {
      final newNote = Note(
        title: _titleController.text,
        content: _contentController.text,
        folder: _selectedFolder,
      );
      widget.onAdd(newNote);
      Navigator.pop(context);
    } else {
      // Show error if title is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
    }
  }
  
  // Show folder selection dialog
  void _showFolderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF303030),
          title: const Text(
            'Select Folder',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // List of existing folders
                ...List.generate(
                  _noteService.getFolders().length,
                  (index) {
                    final folder = _noteService.getFolders()[index];
                    return ListTile(
                      leading: const Icon(Icons.folder, color: Colors.orange),
                      title: Text(
                        folder.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      selected: _selectedFolder == folder.name,
                      onTap: () {
                        setState(() {
                          _selectedFolder = folder.name;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
                
                // Option to create new folder
                ListTile(
                  leading: const Icon(Icons.create_new_folder, color: Colors.orange),
                  title: const Text(
                    'Create New Folder',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showNewFolderDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Show dialog to create a new folder
  void _showNewFolderDialog() {
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
                  // Create new folder and select it
                  final newFolder = Folder(name: folderNameController.text);
                  _noteService.addFolder(newFolder);
                  setState(() {
                    _selectedFolder = newFolder.name;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Add New Note',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        actions: [
          // Folder button
          IconButton(
            icon: const Icon(Icons.folder, color: Colors.orange),
            onPressed: _showFolderDialog,
          ),
          // Save button
          IconButton(
            icon: const Icon(Icons.save_outlined, color: Colors.orange),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF212121),
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current folder indicator
            Row(
              children: [
                const Icon(Icons.folder, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Text(
                  _selectedFolder,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Title field
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: 'Note Title',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
            const Divider(color: Colors.white24),
            // Content field
            Expanded(
              child: TextField(
                controller: _contentController,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write your note here...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
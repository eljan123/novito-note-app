import 'package:flutter/material.dart';
import '../models/note.dart';

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
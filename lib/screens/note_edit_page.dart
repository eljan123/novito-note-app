import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteEditPage extends StatefulWidget {
  final Note note;
  final int index;
  final Function(int, Note) onSave;

  const NoteEditPage({
    super.key,
    required this.note,
    required this.index,
    required this.onSave,
  });

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _isPinned = widget.note.isPinned;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.isNotEmpty) {
      final updatedNote = Note(
        title: _titleController.text,
        content: _contentController.text,
        isPinned: _isPinned,
      );
      widget.onSave(widget.index, updatedNote);
      Navigator.pop(context);
    } else {
      // Show error if title is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
    }
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Edit Note',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? const Color(0xFF212121) : Colors.white,
            ),
            onPressed: _togglePin,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.orange),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Container(
        color: _isPinned ? const Color(0xFF212121) : const Color(0xFF212121),
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title field
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isPinned ? Colors.white : Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Note Title',
                hintStyle: TextStyle(
                  color: _isPinned ? Colors.white70 : Colors.white70,
                ),
                border: InputBorder.none,
              ),
            ),
            Divider(color: _isPinned ? Colors.white24 : Colors.white24),
            // Content field
            Expanded(
              child: TextField(
                controller: _contentController,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: _isPinned ? Colors.white : Colors.white,
                ),
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Write your note here...',
                  hintStyle: TextStyle(
                    color: _isPinned ? Colors.white54 : Colors.white70,
                  ),
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
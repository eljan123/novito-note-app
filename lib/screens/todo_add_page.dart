import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoAddPage extends StatefulWidget {
  final Function(Todo) onAdd;

  const TodoAddPage({
    super.key,
    required this.onAdd,
  });

  @override
  State<TodoAddPage> createState() => _TodoAddPageState();
}

class _TodoAddPageState extends State<TodoAddPage> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _saveTodo() async {
    if (_taskController.text.isNotEmpty) {
      final newTodo = Todo(
        task: _taskController.text,
      );
      await widget.onAdd(newTodo);
      
      // Check if widget is still mounted before navigation
      if (!mounted) return;
      
      Navigator.pop(context);
    } else {
      // Show error if task is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task cannot be empty')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Add New Task',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.orange),
            onPressed: _saveTodo,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF212121),
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Task field
            TextField(
              controller: _taskController,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter your task here...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
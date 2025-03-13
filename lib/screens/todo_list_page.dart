import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import 'todo_add_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  // Create an instance of TodoService
  final TodoService _todoService = TodoService();

  // Function to add a new todo
  void _addTodo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoAddPage(
          onAdd: (Todo newTodo) {
            setState(() {
              _todoService.addTodo(newTodo);
            });
          },
        ),
      ),
    );
  }

  // Function to toggle completion status
  void _toggleCompletionStatus(int index) {
    setState(() {
      _todoService.toggleCompletionStatus(index);
    });
  }

  // Function to delete a todo
  void _deleteTodo(int index) {
    setState(() {
      _todoService.deleteTodo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> todos = _todoService.getTodos();
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // Remove leading drawer menu button
        title: const Text(
          'To-Do List',
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
      body: todos.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet. Tap the + button to add one.',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color(0xFF212121),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      todos[index].task,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: todos[index].isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    leading: Checkbox(
                      value: todos[index].isCompleted,
                      onChanged: (_) => _toggleCompletionStatus(index),
                      activeColor: Colors.orange,
                      checkColor: Colors.black,
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteTodo(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _addTodo,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
} 
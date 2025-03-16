import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import 'todo_add_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> with SingleTickerProviderStateMixin {
  final TodoService _todoService = TodoService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  // Function to toggle completion status with animation
  void _toggleCompletionStatus(int index) {
    _animationController.forward(from: 0.0).then((_) {
      setState(() {
        _todoService.toggleCompletionStatus(index);
      });
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
        title: const Text(
          'To-Do List',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Colors.white, 
          ),
        ),
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet.\nTap the + button to add one.',
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
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  color: const Color(0xFF212121),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Checkbox(
                          value: todos[index].isCompleted,
                          onChanged: (_) => _toggleCompletionStatus(index),
                          activeColor: Colors.orange,
                          checkColor: Colors.black,
                          side: const BorderSide(
                            color: Colors.orange,
                            width: 1.5,
                          ),
                          fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.orange;
                            }
                            return Colors.transparent;
                          }),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            todos[index].task,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              height: 1.3,
                              fontWeight: todos[index].isCompleted ? FontWeight.normal : FontWeight.w500,
                              color: todos[index].isCompleted 
                                  ? Colors.white
                                  : Colors.white,
                              decoration: todos[index].isCompleted 
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 22,
                          ),
                          onPressed: () => _deleteTodo(index),
                        ),
                      ],
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
          onPressed: _addTodo,
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
} 
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
    
    // No need to load from database anymore
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Function to add a new todo
  void _addTodo() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoAddPage(
          onAdd: (Todo newTodo) async {
            await _todoService.addTodo(newTodo);
          },
        ),
      ),
    );
    
    // Check if the widget is still in the tree before using setState
    if (!mounted) return;
    
    // Refresh the UI to show the new todo
    setState(() {});
  }

  // Function to toggle completion status with animation
  void _toggleCompletionStatus(int index) async {
    await _animationController.forward(from: 0.0);
    
    // Now perform the actual toggle
    await _todoService.toggleCompletionStatus(index);
    
    // Check if widget is still mounted before updating state
    if (!mounted) return;
    
    // Update UI
    setState(() {});
  }

  // Function to delete a todo
  void _deleteTodo(int index) async {
    // Delete the todo
    await _todoService.deleteTodo(index);
    
    // Check if widget is still mounted before updating state
    if (!mounted) return;
    
    // Update UI
    setState(() {});
  }  
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    // Get todos synchronously - the service handles initialization
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
              final scaffold = Scaffold.of(context);
              scaffold.openEndDrawer();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : todos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_outlined,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.6),
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
                                  fontWeight: FontWeight.normal,
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
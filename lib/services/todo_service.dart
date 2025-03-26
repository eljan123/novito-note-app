import '../models/todo.dart';

// Simple Todo Service without database storage
// This class manages all to-do items in the app using in-memory storage
class TodoService {
  // SINGLETON PATTERN START
  // The one and only instance of TodoService
  static final TodoService _instance = TodoService._internal();
  
  // In-memory cache
  final List<Todo> _todos = [];
  
  // When someone calls TodoService(), return the existing instance
  factory TodoService() {
    return _instance;
  }
  
  // Private constructor - only called once by _instance
  TodoService._internal();
  
  // Get all todos
  List<Todo> getTodos() {
    return _todos;
  }

  // Add a new todo
  Future<void> addTodo(Todo todo) async {
    // Generate a simple ID
    todo.id = _todos.length + 1;
    _todos.add(todo);
    //print('Added todo: ${todo.task}');
  }

  // Toggle completion status
  Future<void> toggleCompletionStatus(int index) async {
    if (index >= 0 && index < _todos.length) {
      // Get the todo to update
      final todo = _todos[index];
      
      // Toggle completion status
      todo.isCompleted = !todo.isCompleted;
      //print('Toggled todo completion: ${todo.task} is now ${todo.isCompleted ? "completed" : "incomplete"}');
    }
  }

  // Delete a todo
  Future<void> deleteTodo(int index) async {
    if (index >= 0 && index < _todos.length) {
      //print('Deleted todo: ${_todos[index].task}');
      _todos.removeAt(index);
    }
  }
  
  // Refresh data - just a placeholder to keep the API consistent
  Future<void> refreshData() async {
    // No database to refresh, but we keep the function for API compatibility
    //print('Todo service refreshed (in-memory only)');
  }
} 
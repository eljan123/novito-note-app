import '../models/todo.dart';

class TodoService {
  static final TodoService _instance = TodoService._internal();
  final List<Todo> _todos = [];
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
    }
  }

  // Delete a todo
  Future<void> deleteTodo(int index) async {
    if (index >= 0 && index < _todos.length) {
      _todos.removeAt(index);
    }
  }

  Future<void> refreshData() async {}
}

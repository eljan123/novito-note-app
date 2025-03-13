import '../models/todo.dart';

class TodoService {
  // List to store todos
  final List<Todo> _todos = [];

  // Get all todos
  List<Todo> getTodos() {
    return _todos;
  }

  // Add a new todo
  void addTodo(Todo todo) {
    _todos.add(todo);
  }

  // Toggle completion status
  void toggleCompletionStatus(int index) {
    if (index >= 0 && index < _todos.length) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
    }
  }

  // Delete a todo
  void deleteTodo(int index) {
    if (index >= 0 && index < _todos.length) {
      _todos.removeAt(index);
    }
  }
} 
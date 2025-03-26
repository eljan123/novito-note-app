// Todo Model
// This class represents a task in the todo list
// Each todo has a task description and completion status

class Todo {
  // SQLite database ID (null for new todos)
  int? id;
  // The text description of the task (required)
  String task;
  // Whether the task is completed
  bool isCompleted;

  // Constructor - creates a new Todo
  Todo({
    this.id,
    required this.task, 
    this.isCompleted = false
  });

  // Convert Todo to Map for storage
  // This is used for saving to SQLite database
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'task': task,
      'isCompleted': isCompleted ? 1 : 0, // Convert boolean to int for SQLite
    };
    
    // Include ID only if it's not null (for updates)
    if (id != null) {
      map['id'] = id!;
    }
    
    return map;
  }

  // Create Todo from Map
  // This is used when loading from SQLite database
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      task: map['task'] ?? '',
      // Convert int to boolean from SQLite
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true,
    );
  }
} 
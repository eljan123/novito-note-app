class Todo {
  String task;
  bool isCompleted;

  Todo({required this.task, this.isCompleted = false});

  // Convert Todo to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'isCompleted': isCompleted,
    };
  }

  // Create Todo from Map
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      task: map['task'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
} 
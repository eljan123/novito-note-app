class Note {
  String title;
  String content;
  bool isPinned;

  Note({required this.title, this.content = '', this.isPinned = false});

  // Convert Note to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'isPinned': isPinned,
    };
  }

  // Create Note from Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      isPinned: map['isPinned'] ?? false,
    );
  }
} 
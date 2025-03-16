class Note {
  String title;
  String content;
  bool isPinned;
  DateTime lastModified;

  Note({
    required this.title, 
    this.content = '', 
    this.isPinned = false,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  // Convert Note to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'isPinned': isPinned,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  // Create Note from Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      isPinned: map['isPinned'] ?? false,
      lastModified: map['lastModified'] != null 
          ? DateTime.parse(map['lastModified'])
          : DateTime.now(),
    );
  }
} 
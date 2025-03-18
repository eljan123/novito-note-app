class Note {
  String title;
  String content;
  bool isPinned;
  DateTime lastModified;
  String folder;

  Note({
    required this.title, 
    this.content = '', 
    this.isPinned = false,
    this.folder = 'Default',
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  // Convert Note to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'isPinned': isPinned,
      'folder': folder,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  // Create Note from Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      isPinned: map['isPinned'] ?? false,
      folder: map['folder'] ?? 'Default',
      lastModified: map['lastModified'] != null 
          ? DateTime.parse(map['lastModified'])
          : DateTime.now(),
    );
  }
} 
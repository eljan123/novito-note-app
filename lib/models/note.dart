// Note Model
// This class represents a single note in the app
// Each note has a title, content, and belongs to a folder

class Note {
  // SQLite database ID (null for new notes)
  int? id;
  // The title of the note (required)
  String title;
  // The content/body of the note
  String content;
  // Whether the note is pinned to the top of the list
  bool isPinned;
  // When the note was last modified
  DateTime lastModified;
  // The folder this note belongs to
  String folder;

  // Constructor - creates a new Note
  Note({
    this.id,
    required this.title, 
    this.content = '', 
    this.isPinned = false,
    this.folder = 'Default',
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  // Convert Note to Map for storage
  // This is used for saving to SQLite database
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'isPinned': isPinned ? 1 : 0, // Convert boolean to int for SQLite
      'folder': folder,
      'lastModified': lastModified.toIso8601String(),
    };
    
    // Include ID only if it's not null (for updates)
    if (id != null) {
      map['id'] = id!;
    }
    
    return map;
  }

  // Create Note from Map
  // This is used when loading from SQLite database
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      // Convert int to boolean from SQLite
      isPinned: map['isPinned'] == 1 || map['isPinned'] == true,
      folder: map['folder'] ?? 'Default',
      lastModified: map['lastModified'] != null 
          ? DateTime.parse(map['lastModified'])
          : DateTime.now(),
    );
  }
} 
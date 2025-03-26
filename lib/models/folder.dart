// Folder Model
// This class represents a folder that can contain multiple notes
// Each folder has a unique name that identifies it

class Folder {
  // SQLite database ID (null for new folders)
  int? id;
  // The name of the folder (required)
  String name;
  
  // Constructor - creates a new Folder
  // The name parameter is required
  Folder({
    this.id,
    required this.name,
  });
  
  // Convert Folder to Map for storage
  // This is used when saving folders to device storage
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
    };
    
    // Include ID only if it's not null (for updates)
    if (id != null) {
      map['id'] = id!;
    }
    
    return map;
  }
  
  // Create Folder from Map
  // This is used when loading folders from device storage
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as int?,
      name: map['name'] ?? 'Unnamed Folder',
    );
  }
} 
// Folder Model
// This class represents a folder that can contain multiple notes
// Each folder has a unique name that identifies it

class Folder {
  // The name of the folder (required)
  String name;
  
  // Constructor - creates a new Folder
  // The name parameter is required
  Folder({
    required this.name,
  });
  
  // Convert Folder to Map for storage
  // This is used when saving folders to device storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
  
  // Create Folder from Map
  // This is used when loading folders from device storage
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      name: map['name'] ?? 'Unnamed Folder',
    );
  }
} 
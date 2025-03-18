class Folder {
  String name;
  String color; // Store as a hex string for simplicity
  
  Folder({
    required this.name,
    this.color = "#FFA500", // Default orange color
  });
  
  // Convert Folder to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
    };
  }
  
  // Create Folder from Map
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      name: map['name'] ?? '',
      color: map['color'] ?? "#FFA500",
    );
  }
} 
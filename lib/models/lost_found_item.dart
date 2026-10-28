class LostFoundItem {
  final String? itemId;
  final String title;
  final String description;
  final String location;
  final String category;
  final String type;
  final String imageUrl;
  final String status;

  LostFoundItem({
    this.itemId,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.type,
    required this.imageUrl,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      if (itemId != null && itemId!.isNotEmpty) 'itemId': itemId,
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'type': type,
      'imageUrl': imageUrl,
      'status': status,
    };
  }

  factory LostFoundItem.fromMap(Map<String, dynamic> map, String documentId) {
    return LostFoundItem(
      itemId: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      category: map['category'] ?? '',
      type: map['type'] ?? 'Lost',
      imageUrl: map['imageUrl'] ?? '',
      status: map['status'] ?? 'active',
    );
  }
}
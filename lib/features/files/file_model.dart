class FileItem {
  final String name;
  final int size;
  final DateTime? createdAt;

  FileItem({
    required this.name,
    required this.size,
    this.createdAt,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      name: json['name'],
      size: json['size'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
class CategoryModel {
  String id;
  String name;
  String? userId;
  String description;
  CategoryModel({
    required this.id,
    this.userId,
    required this.name,
    required this.description,
  });

  // CategoryModel copyWith({
  //   String? id,
  //   String? name,
  //   String? description,
  // }) {
  //   return CategoryModel(
  //     id: id ?? this.id,
  //     name: name ?? this.name,
  //     description: description ?? this.description,
  //   );
  // }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'description': description,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

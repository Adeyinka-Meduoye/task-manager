class CategoryModel {
  final String id;
  final String name;
  final String color;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'description': description,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] as String,
        description: json['description'] as String?,
      );
}
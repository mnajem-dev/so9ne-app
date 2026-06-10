class Category {
  final int id;
  final String libelle;
  final String? imageUrl;

  Category({
    required this.id,
    required this.libelle,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      libelle: json['libelle'],
      imageUrl: json['image_url'],
    );
  }
}

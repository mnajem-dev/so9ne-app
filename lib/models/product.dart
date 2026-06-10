class Product {
  final int id;
  final int? idCat;
  final String nom;
  final double prix;
  final List<String> taille;
  final int stock;
  final String? img;

  Product({
    required this.id,
    this.idCat,
    required this.nom,
    required this.prix,
    required this.taille,
    required this.stock,
    this.img,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      idCat: json['id_cat'],
      nom: json['nom'],
      prix: (json['prix'] as num).toDouble(),
      taille: List<String>.from(json['taille'] ?? []),
      stock: json['stock'] ?? 0,
      img: json['img'],
    );
  }
}

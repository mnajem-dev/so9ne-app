import 'product.dart';

class OrderDetail {
  final int id;
  final int idOrder;
  final int idProduct;
  final int quantite;
  final double prixUnit;
  final String tailleChoisie;
  final Product? product; // Optional eager-loaded product

  OrderDetail({
    required this.id,
    required this.idOrder,
    required this.idProduct,
    required this.quantite,
    required this.prixUnit,
    required this.tailleChoisie,
    this.product,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      idOrder: json['id_order'],
      idProduct: json['id_product'],
      quantite: json['quantite'],
      prixUnit: (json['prix_unit'] as num).toDouble(),
      tailleChoisie: json['taille_choisie'],
      product: json['products'] != null ? Product.fromJson(json['products']) : null,
    );
  }
}

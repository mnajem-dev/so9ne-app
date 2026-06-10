class Order {
  final int id;
  final String idUser;
  final DateTime dateCommande;
  final double total;
  final String statut;

  Order({
    required this.id,
    required this.idUser,
    required this.dateCommande,
    required this.total,
    required this.statut,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      idUser: json['id_user'],
      dateCommande: DateTime.parse(json['date_commande']),
      total: (json['total'] as num).toDouble(),
      statut: json['statut'],
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/order_detail.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(Supabase.instance.client);
});

final userOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.read(orderRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];
  return repository.getUserOrders(userId);
});

final allOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.read(orderRepositoryProvider);
  return repository.getAllOrders();
});

class OrderRepository {
  final SupabaseClient _client;

  OrderRepository(this._client);

  // Client: Create Order (Checkout simulation)
  Future<void> createOrder({
    required String userId,
    required double total,
    required List<Map<String, dynamic>> items, // Map containing id_product, quantite, prix_unit, taille_choisie
  }) async {
    // 1. Insert order
    final orderResponse = await _client.from('orders').insert({
      'id_user': userId,
      'date_commande': DateTime.now().toIso8601String(),
      'total': total,
      'statut': 'en cours', // Initial status
    }).select().single();

    final int orderId = orderResponse['id'];

    // 2. Insert order details
    final orderDetails = items.map((item) {
      return {
        'id_order': orderId,
        'id_product': item['id_product'],
        'quantite': item['quantite'],
        'prix_unit': item['prix_unit'],
        'taille_choisie': item['taille_choisie'],
      };
    }).toList();

    await _client.from('order_details').insert(orderDetails);
    
    // Note: In a production app, you would also decrease the product stock here
    // by iterating over items and updating the products table.
  }

  // Client: Get their own orders
  Future<List<Order>> getUserOrders(String userId) async {
    final response = await _client
        .from('orders')
        .select()
        .eq('id_user', userId)
        .order('date_commande', ascending: false);
    return (response as List).map((json) => Order.fromJson(json)).toList();
  }

  // Admin: Get all orders
  Future<List<Order>> getAllOrders() async {
    final response = await _client
        .from('orders')
        .select()
        .order('date_commande', ascending: false);
    return (response as List).map((json) => Order.fromJson(json)).toList();
  }

  // Client/Admin: Get order details (invoices)
  Future<List<OrderDetail>> getOrderDetails(int orderId) async {
    final response = await _client
        .from('order_details')
        .select('*, products(*)')
        .eq('id_order', orderId);
    return (response as List).map((json) => OrderDetail.fromJson(json)).toList();
  }

  // Admin: Total Sales Stats
  Future<double> getTotalSales() async {
    final response = await _client
        .from('orders')
        .select('total')
        .inFilter('statut', ['payée', 'livrée', 'en cours']); // Exclude 'annulée'
    
    double total = 0;
    for (var row in response) {
      total += (row['total'] as num).toDouble();
    }
    return total;
  }

  // Admin: Update order status
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    await _client
        .from('orders')
        .update({'statut': newStatus})
        .eq('id', orderId);
  }
}

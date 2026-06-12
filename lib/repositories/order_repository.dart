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
    required List<Map<String, dynamic>> items,
  }) async {
    await _client.rpc('place_order', params: {
      'p_user_id': userId,
      'p_total': total,
      'p_items': items,
    });
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
    final response = await _client.rpc('get_total_sales');
    return (response as num).toDouble();
  }

  // Admin: Update order status
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    await _client
        .from('orders')
        .update({'statut': newStatus})
        .eq('id', orderId);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../repositories/order_repository.dart';
import '../../theme/app_theme.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrdersAsyncValue = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Orders', style: Theme.of(context).textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: allOrdersAsyncValue.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order.id}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: order.statut == 'en cours' ? Colors.orange.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              order.statut.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: order.statut == 'en cours' ? Colors.orange.shade900 : Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${DateFormat.yMMMd().format(order.dateCommande)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.outlineColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'User ID: ${order.idUser}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.outlineColor),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Total: \$${order.total.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 38), // Flexible width, fixed height
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () async {
                              final statuses = ['en cours', 'payée', 'livrée', 'annulée'];
                              final selectedStatus = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Update Status'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: statuses.map((status) => ListTile(
                                        title: Text(status.toUpperCase()),
                                        onTap: () => Navigator.pop(context, status),
                                        trailing: order.statut == status ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                                      )).toList(),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                                    ],
                                  );
                                },
                              );

                              if (selectedStatus != null && selectedStatus != order.statut) {
                                try {
                                  await ref.read(orderRepositoryProvider).updateOrderStatus(order.id, selectedStatus);
                                  ref.invalidate(allOrdersProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Status updated successfully!')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error updating status: $e'), backgroundColor: AppTheme.errorColor),
                                    );
                                  }
                                }
                              }
                            },
                            child: const Text('Update Status'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

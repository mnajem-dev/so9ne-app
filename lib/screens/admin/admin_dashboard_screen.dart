import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/order_repository.dart';

final totalSalesProvider = FutureProvider<double>((ref) async {
  return ref.read(orderRepositoryProvider).getTotalSales();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProvider);
    final allOrdersAsyncValue = ref.watch(allOrdersProvider);
    final totalSalesAsyncValue = ref.watch(totalSalesProvider);
    final authRepo = ref.read(authRepositoryProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    final inventoryCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text('Inventory', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            productsAsyncValue.when(
              data: (products) => Text('${products.length} Products', style: Theme.of(context).textTheme.bodyLarge),
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => const Text('Error'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go('/admin/inventory'),
              child: const Text('Manage'),
            ),
          ],
        ),
      ),
    );

    final ordersCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 48, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text('Orders', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            allOrdersAsyncValue.when(
              data: (orders) {
                final active = orders.where((o) => o.statut == 'en cours').length;
                return Text('$active Active / ${orders.length} Total', style: Theme.of(context).textTheme.bodyLarge);
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => const Text('Error'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go('/admin/orders'),
              child: const Text('Manage'),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.primaryColor),
            onPressed: () => authRepo.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: isMobile ? 16 : 32),
            if (isMobile)
              Column(
                children: [
                  SizedBox(width: double.infinity, child: inventoryCard),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: ordersCard),
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: inventoryCard),
                  const SizedBox(width: 32),
                  Expanded(child: ordersCard),
                ],
              ),
            SizedBox(height: isMobile ? 16 : 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total Sales', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text('Based on completed/active orders', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.outlineColor)),
                      ],
                    ),
                    totalSalesAsyncValue.when(
                      data: (total) => Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.secondaryColor)),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, _) => const Text('Error fetching stats'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

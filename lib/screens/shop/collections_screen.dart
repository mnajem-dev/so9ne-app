import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/product_repository.dart';
import '../../theme/app_theme.dart';
import '../../repositories/auth_repository.dart';

class SelectedCategoryNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  void select(int? id) => state = id;
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, int?>(() {
  return SelectedCategoryNotifier();
});

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProvider);
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Collections', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: AppTheme.primaryColor),
            onPressed: () => context.go('/orders'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryColor),
            onPressed: () => context.go('/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.primaryColor),
            onPressed: () => authRepo.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories Filter
          SizedBox(
            height: 60,
            child: categoriesAsyncValue.when(
              data: (categories) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = selectedCategoryId == null;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: const Text('All'),
                          selected: isSelected,
                          onSelected: (_) => ref.read(selectedCategoryProvider.notifier).select(null),
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.primaryColor),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                            side: BorderSide(color: isSelected ? AppTheme.primaryColor : AppTheme.outlineColor),
                          ),
                        ),
                      );
                    }
                    
                    final category = categories[index - 1];
                    final isSelected = selectedCategoryId == category.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category.libelle),
                        selected: isSelected,
                        onSelected: (_) => ref.read(selectedCategoryProvider.notifier).select(category.id),
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.primaryColor),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide(color: isSelected ? AppTheme.primaryColor : AppTheme.outlineColor),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const SizedBox.shrink(),
            ),
          ),
          // Products Grid
          Expanded(
            child: productsAsyncValue.when(
              data: (allProducts) {
                final products = selectedCategoryId == null 
                  ? allProducts 
                  : allProducts.where((p) => p.idCat == selectedCategoryId).toList();

                if (products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () => context.go('/product/${product.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(8),
                                image: product.img != null
                                    ? DecorationImage(
                                        image: NetworkImage(product.img!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: product.img == null
                                  ? const Center(child: Icon(Icons.image_not_supported))
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.nom,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${product.prix.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.outlineColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      )
    );
  }
}

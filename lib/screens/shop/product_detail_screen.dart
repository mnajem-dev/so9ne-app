import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/product_repository.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedSize;

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryColor),
            onPressed: () => context.go('/cart'),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: productsAsyncValue.when(
        data: (products) {
          final productIndex = products.indexWhere((p) => p.id == widget.productId);
          if (productIndex == -1) {
            return const Center(child: Text('Product not found'));
          }
          final product = products[productIndex];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.img != null)
                  Image.network(
                    product.img!,
                    width: double.infinity,
                    height: 500,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 500,
                    color: AppTheme.surfaceColor,
                    child: const Icon(Icons.image_not_supported, size: 64),
                  ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nom,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '\$${product.prix.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.outlineColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Select Size',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.taille.map((size) {
                          final isSelected = _selectedSize == size;
                          return ChoiceChip(
                            label: Text(size),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSize = selected ? size : null;
                              });
                            },
                            selectedColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.primaryColor,
                            ),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primaryColor : AppTheme.outlineColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor, // Champagne Gold for checkout
                        ),
                        onPressed: _selectedSize == null ? null : () {
                          ref.read(cartProvider.notifier).addItem(product, _selectedSize!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.nom} added to cart!')),
                          );
                        },
                        child: const Text('ADD TO CART'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

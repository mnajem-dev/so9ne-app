import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../repositories/product_repository.dart';
import '../../models/product.dart';

class AdminInventoryScreen extends ConsumerWidget {
  const AdminInventoryScreen({super.key});

  void _showProductDialog(BuildContext context, WidgetRef ref, {Product? product}) {
    final nomController = TextEditingController(text: product?.nom);
    final prixController = TextEditingController(text: product?.prix.toString());
    final stockController = TextEditingController(text: product?.stock.toString());
    final imgController = TextEditingController(text: product?.img);
    // Hardcoding taille for simplicity in this dialog, ideally use chips
    final tailleController = TextEditingController(text: product?.taille.join(', '));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nomController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: prixController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
                TextField(controller: tailleController, decoration: const InputDecoration(labelText: 'Sizes (comma separated)')),
                TextField(controller: imgController, decoration: const InputDecoration(labelText: 'Image URL')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(productRepositoryProvider);
                final nom = nomController.text;
                final prix = double.tryParse(prixController.text) ?? 0.0;
                final stock = int.tryParse(stockController.text) ?? 0;
                final img = imgController.text.isEmpty ? null : imgController.text;
                final taille = tailleController.text.split(',').map((e) => e.trim()).toList();

                if (product == null) {
                  await repo.createProduct(nom: nom, prix: prix, taille: taille, stock: stock, img: img);
                } else {
                  await repo.updateProduct(product.id, nom: nom, prix: prix, taille: taille, stock: stock, img: img);
                }
                
                ref.invalidate(productsProvider); // Refresh list
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory', style: Theme.of(context).textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: () => _showProductDialog(context, ref),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: productsAsyncValue.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: product.img != null 
                    ? Image.network(product.img!, width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported),
                title: Text(product.nom, style: Theme.of(context).textTheme.bodyLarge),
                subtitle: Text('\$${product.prix.toStringAsFixed(2)} - Stock: ${product.stock}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showProductDialog(context, ref, product: product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Product?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                            ],
                          )
                        );
                        if (confirm == true) {
                          await ref.read(productRepositoryProvider).deleteProduct(product.id);
                          ref.invalidate(productsProvider);
                        }
                      },
                    ),
                  ],
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/category.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(Supabase.instance.client);
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getProducts();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getCategories();
});

class ProductRepository {
  final SupabaseClient _client;

  ProductRepository(this._client);

  Future<List<Product>> getProducts() async {
    final response = await _client.from('products').select();
    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Category>> getCategories() async {
    final response = await _client.from('categories').select();
    return (response as List).map((json) => Category.fromJson(json)).toList();
  }
  
  Future<Product> getProductById(int id) async {
    final response = await _client.from('products').select().eq('id', id).single();
    return Product.fromJson(response);
  }

  // Admin: Create Product
  Future<void> createProduct({
    required String nom,
    required double prix,
    required List<String> taille,
    required int stock,
    int? idCat,
    String? img,
  }) async {
    final Map<String, dynamic> data = {
      'nom': nom,
      'prix': prix,
      'taille': taille,
      'stock': stock,
    };
    if (idCat != null) data['id_cat'] = idCat;
    if (img != null) data['img'] = img;
    await _client.from('products').insert(data);
  }

  // Admin: Update Product
  Future<void> updateProduct(int id, {
    String? nom,
    double? prix,
    List<String>? taille,
    int? stock,
    int? idCat,
    String? img,
  }) async {
    final Map<String, dynamic> updates = {};
    if (nom != null) updates['nom'] = nom;
    if (prix != null) updates['prix'] = prix;
    if (taille != null) updates['taille'] = taille;
    if (stock != null) updates['stock'] = stock;
    if (idCat != null) updates['id_cat'] = idCat;
    if (img != null) updates['img'] = img;

    await _client.from('products').update(updates).eq('id', id);
  }

  // Admin: Delete Product
  Future<void> deleteProduct(int id) async {
    await _client.from('products').delete().eq('id', id);
  }

  // Admin/System: Update Stock
  Future<void> updateStock(int id, int quantityChange) async {
    // In a real app, you might use an RPC for atomic increment/decrement to prevent race conditions.
    // For now, we fetch current stock and update.
    final currentProduct = await getProductById(id);
    final newStock = currentProduct.stock + quantityChange;
    await _client.from('products').update({'stock': newStock}).eq('id', id);
  }
}

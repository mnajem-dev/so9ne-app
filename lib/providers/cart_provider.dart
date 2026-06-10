import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  final String selectedSize;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedSize,
    this.quantity = 1,
  });

  double get totalPrice => product.prix * quantity;
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(Product product, String size, {int quantity = 1}) {
    // Check if item with same size already exists
    final index = state.indexWhere(
        (item) => item.product.id == product.id && item.selectedSize == size);

    if (index >= 0) {
      // Increase quantity
      final List<CartItem> newState = [...state];
      newState[index].quantity += quantity;
      state = newState;
    } else {
      // Add new item
      state = [...state, CartItem(product: product, selectedSize: size, quantity: quantity)];
    }
  }

  void removeItem(Product product, String size) {
    state = state.where((item) => !(item.product.id == product.id && item.selectedSize == size)).toList();
  }

  void clearCart() {
    state = [];
  }

  double get totalCartPrice {
    return state.fold(0, (total, item) => total + item.totalPrice);
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

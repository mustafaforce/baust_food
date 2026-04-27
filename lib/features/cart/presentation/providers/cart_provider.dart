import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../menu/data/models/food_item_model.dart';
import '../../data/models/cart_item_model.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(FoodItem foodItem) {
    final existingIndex = state.indexWhere(
      (item) => item.foodItem.id == foodItem.id,
    );

    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existingItem.copyWith(quantity: existingItem.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(foodItem: foodItem, quantity: 1)];
    }
  }

  void removeItem(String foodItemId) {
    state = state.where((item) => item.foodItem.id != foodItemId).toList();
  }

  void updateQuantity(String foodItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(foodItemId);
      return;
    }

    final index = state.indexWhere((item) => item.foodItem.id == foodItemId);
    if (index >= 0) {
      final existingItem = state[index];
      state = [
        ...state.sublist(0, index),
        existingItem.copyWith(quantity: quantity),
        ...state.sublist(index + 1),
      ];
    }
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (total, item) => total + item.totalPrice);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (count, item) => count + item.quantity);
});

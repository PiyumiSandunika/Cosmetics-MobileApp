import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  // Internal list of items in the cart
  final List<Product> _items = [];

  // Getter to access the list from outside
  List<Product> get items => _items;

  // Getter for total price
  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.price);
  }

  // Add item
  void addToCart(Product product) {
    _items.add(product);
    // This magic function tells Flutter to redraw the UI!
    notifyListeners(); 
  }

  // Remove item
  void removeFromCart(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  // Clear cart (after purchase)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
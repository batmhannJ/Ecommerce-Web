import 'package:flutter/cupertino.dart';

import '../model/product.dart';

class CartViewModel with ChangeNotifier {
  final Map<Product, int> _items = {};

  List<MapEntry<Product, int>> get items => _items.entries.toList();

  int itemCount(Product item) => _items.containsKey(item) ? _items[item]! : 0;

  double getSubtotal() {
    double subtotal = 0;

    for (Product product in _items.keys) {
      subtotal += totalItemPrice(product);
    }

    return subtotal;
  }

  double totalItemPrice(Product item) {
    if (!_items.containsKey(item)) return 0;

    double discountedPrice = item.price - (item.price * item.discount);

    return discountedPrice * _items[item]!;
  }

  void addItem(Product item) {
    if (_items.containsKey(item)) {
      _items[item] = _items[item]! + 1;
    } else {
      _items[item] = 1;
    }

    notifyListeners();
  }

  void subtractItem(Product item) {
    if (_items.containsKey(item)) {
      if (_items[item]! > 1) {
        _items[item] = _items[item]! - 1;
      } else {
        _items.remove(item);
      }
    }
    notifyListeners();
  }
}

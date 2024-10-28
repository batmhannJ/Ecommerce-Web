import 'package:flutter/cupertino.dart';
import 'package:indigitech_shop/core/constant/enum/product_size.dart';

import '../model/product.dart';

class CartViewModel with ChangeNotifier {
    final Map<Product, double> _itemPrices = {}; // Store adjusted prices
  Map<Product, ProductSize> selectedSizes = {};

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
    double price = _itemPrices[item] ?? item.new_price; // Get adjusted price if available

        return price * _items[item]!;

  }

  void addItem(Product item, {ProductSize? size}) {
    if (_items.containsKey(item)) {
      _items[item] = _items[item]! + 1;
    } else {
      _items[item] = 1; // Save adjusted price
    if (size != null) {
      selectedSizes[item] = size; // Set selected size for the new item
            _itemPrices[item] = item.new_price; // Initialize adjusted price if needed
      print("Saving size: ${size} for product: ${item.name}");

    }
    }

    notifyListeners();
  }

  void subtractItem(Product item) {
    if (_items.containsKey(item)) {
      if (_items[item]! > 1) {
        _items[item] = _items[item]! - 1;
      } else {
        _items.remove(item);
                _itemPrices.remove(item); // Remove adjusted price entry
      selectedSizes.remove(item); // Remove size entry

      }
    }
    notifyListeners();
    
  }
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> logins() async {
    // Simulate a login process (e.g., API call)
    await Future.delayed(Duration(seconds: 2)); // Simulate a delay
    _isLoggedIn = true; // Set logged in state after a successful login
    notifyListeners(); // Notify listeners of the change
  }

   void setSelectedSize(Product product, ProductSize size) {
      print("Setting size for ${product.name}: $size");

    selectedSizes[product] = size;
    notifyListeners();
  }

  ProductSize? getSelectedSize(Product product) {
     ProductSize? size = selectedSizes[product];
  print("Retrieving size for ${product.name}: $size");
  return size;
  }
}

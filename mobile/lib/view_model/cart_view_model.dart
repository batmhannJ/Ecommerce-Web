import 'package:flutter/cupertino.dart';
import 'package:indigitech_shop/core/constant/enum/product_size.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../model/product.dart';

class CartViewModel with ChangeNotifier {
  final Map<Product, double> _itemPrices = {}; // Store adjusted prices
  Map<Product, ProductSize> selectedSizes = {};
  double _shippingFee = 0.0;

  double get shippingFee => _shippingFee;
  Map<Product, Map<String, dynamic>> cartItems =
      {}; // Store quantity and selectedSize
  void addToCart(Product product, int quantity, String selectedSize) {
    cartItems[product] = {
      'quantity': quantity,
      'selectedSize': selectedSize,
    };
    notifyListeners();
  }

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
    double price =
        _itemPrices[item] ?? item.new_price; // Get adjusted price if available

    return price * _items[item]!;
  }

  void addItem(Product item, {ProductSize? size}) {
    if (_items.containsKey(item)) {
      _items[item] = _items[item]! + 1;
    } else {
      _items[item] = 1; // Save adjusted price
      if (size != null) {
        selectedSizes[item] = size; // Set selected size for the new item
        _itemPrices[item] =
            item.new_price; // Initialize adjusted price if needed
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

  void reduceStock(Product product) {
    ProductSize? selectedSize = getSelectedSize(product);
    if (selectedSize == ProductSize.S && product.s_stock > 0) {
      product.s_stock -= 1;
    } else if (selectedSize == ProductSize.M && product.m_stock > 0) {
      product.m_stock -= 1;
    } else if (selectedSize == ProductSize.L && product.l_stock > 0) {
      product.l_stock -= 1;
    } else if (selectedSize == ProductSize.L && product.xl_stock > 0) {
      product.xl_stock -= 1;
    }
    notifyListeners();
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

  void calculateShippingFee(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadiusKm * c;
    print("Calculated distance: $distance km");

    // Calculate the shipping fee based on distance
    _shippingFee = _calculateShippingRate(distance);
    print("Calculated shipping fee: ₱$shippingFee");

    notifyListeners(); // Ensure UI updates
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double _calculateShippingRate(double distance) {
    if (distance < 5) return 50; // Example: ₱50 for <5 km
    if (distance < 20) return 100; // Example: ₱100 for 5-20 km
    return 200; // Example: ₱200 for >20 km
  }
}

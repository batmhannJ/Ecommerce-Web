import 'package:flutter/cupertino.dart';
import 'package:indigitech_shop/core/constant/enum/product_size.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../model/product.dart';

class CartViewModel with ChangeNotifier {
  String _stockErrorMessage = '';

  // Correct getter for stockErrorMessage
  String get stockErrorMessage => _stockErrorMessage;

  final Map<Product, double> _itemPrices = {}; // Store adjusted prices
  Map<Product, ProductSize> selectedSizes = {};
  double _shippingFee = 0.0;

  double get shippingFee => _shippingFee;
  Map<Product, Map<String, dynamic>> cartItems = {};

  void addToCart(Product product, int quantity, String selectedSize) {
    // Get the available stock for the selected size
    int availableStock = _getAvailableStock(product, selectedSize);

    // If the quantity exceeds available stock, set it to available stock
    if (quantity > availableStock) {
      quantity = availableStock;
      print("Quantity exceeds available stock. Limiting to $availableStock.");
    }

    final Product? existingProduct = cartItems.keys.firstWhere(
      (item) => item.id == product.id,
      orElse: () => null as Product, // Explicitly cast null to Product?
    );

    if (existingProduct != null &&
        cartItems[existingProduct]!['selectedSize'] == selectedSize) {
      cartItems[existingProduct]!['quantity'] += quantity;
    } else {
      cartItems[product] = {
        'quantity': quantity,
        'selectedSize': selectedSize,
      };
    }

    notifyListeners();
  }

  int _getAvailableStock(Product product, String selectedSize) {
    switch (selectedSize) {
      case 'S':
        return product.s_stock;
      case 'M':
        return product.m_stock;
      case 'L':
        return product.l_stock;
      case 'XL':
        return product.xl_stock;
      default:
        return 0; // In case of invalid size
    }
  }

  void updateCartItems(Map<Product, Map<String, dynamic>> newItems) {
    cartItems = newItems;
    notifyListeners();
  }

  void updateCartItemsFromDatabase(List<dynamic> fetchedCartItems) {
    // Clear existing cartItems
    cartItems.clear();

    for (var item in fetchedCartItems) {
      final Product product = Product(
        id: item['productId'],
        name: item['name'],
        adjustedPrice: item['adjustedPrice'],
        old_price: item['old_price'],
        new_price: item['new_price'],
        discount: item['discount'],
        description: item['description'],
        reviews: [], // Add reviews if available
        stocks: {}, // Add stock data if available
        s_stock: item['s_stock'] ?? 0,
        m_stock: item['m_stock'] ?? 0,
        l_stock: item['l_stock'] ?? 0,
        xl_stock: item['xl_stock'] ?? 0,
        category: item['category'] ?? "Uncategorized",
        tags: item['tags'],
        image: item['image'],
        available: item['available'] ?? false,
        isNew: item['isNew'] ?? false,
      );

      cartItems[product] = {
        'quantity': item['quantity'],
        'selectedSize': item['selectedSize'],
      };
    }

    notifyListeners();
  }

  List<MapEntry<Product, Map<String, dynamic>>> get cartItemsList {
    return cartItems.entries.toList();
  }

  final Map<Product, int> _items = {};

  List<MapEntry<Product, int>> get items => _items.entries.toList();
  int itemCount(Product product) {
    if (cartItems.containsKey(product)) {
      return cartItems[product]!['quantity'];
    }
    return 0;
  }

  void clearCart() {
    _items.clear(); // Clear all items in the cart
    notifyListeners(); // Notify listeners to rebuild the UI
  }

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

  // Add an item to the cart and adjust the quantity if already added
  void addItem(Product product, String selectedSize, {int quantity = 1}) {
    if (selectedSize.isEmpty) {
      print("Error: Size must be selected for the product.");
      return;
    }

    void setStockErrorMessage(String message) {
      _stockErrorMessage = message;
      notifyListeners();
    }

    // Method to clear the stock error message
    void clearStockErrorMessage() {
      _stockErrorMessage = '';
      notifyListeners();
    }

    // Get the available stock for the selected size
    int availableStock = _getAvailableStock(product, selectedSize);
    if (availableStock < quantity) {
      setStockErrorMessage(
          "Not enough stock available for size $selectedSize.");
      return;
    }
    clearStockErrorMessage();

    if (cartItems.containsKey(product) &&
        cartItems[product]!['selectedSize'] == selectedSize) {
      cartItems[product]!['quantity'] += quantity;
    } else {
      cartItems[product] = {
        'quantity': quantity,
        'selectedSize': selectedSize,
      };
    }

    notifyListeners();
  }

  void subtractItem(Product product, String selectedSize) {
    if (cartItems.containsKey(product) &&
        cartItems[product]!['selectedSize'] == selectedSize) {
      if (cartItems[product]!['quantity'] > 1) {
        cartItems[product]!['quantity'] -= 1;
      } else {
        cartItems.remove(product);
      }
      notifyListeners();
    }
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/model/address.dart';
import 'package:indigitech_shop/view/address_view.dart';
import 'package:indigitech_shop/view/cart_view.dart';
import 'package:indigitech_shop/view/checkout_view.dart';
import 'package:indigitech_shop/view/home/home_view.dart';
import 'package:indigitech_shop/view/auth/login_view.dart';
import 'package:indigitech_shop/view/auth/signup_view.dart';
import 'package:indigitech_shop/view/profile_view.dart';
import 'package:indigitech_shop/view_model/address_view_model.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:indigitech_shop/view_model/cart_view_model.dart';
import 'package:indigitech_shop/view_model/checkout_manager_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indigitech_shop/view/checkout_result.dart'; // Checkout result view
import 'package:uni_links/uni_links.dart'; // Import uni_links
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CheckoutManager()),
        ChangeNotifierProvider(create: (context) => CartViewModel()),
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => AddressViewModel()),
      ],
      child: Builder(
        builder: (context) {
          final checkoutManager =
              Provider.of<CheckoutManager>(context, listen: false);
          print("Global CheckoutManager is available: $checkoutManager");
          return const MyApp();
        },
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    print("CheckoutViewState initialized with GlobalKey: $checkoutViewKey");

    _initDeepLink();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleWebRedirect();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    print("Retrieved User ID: $userId");
    return userId != null && userId.isNotEmpty;
  }

  void _initDeepLink() async {
    if (kIsWeb) {
      // Web-specific logic: Monitor the browser's current URL
      final currentUrl = html.window.location.href;
      print("Current URL on web: $currentUrl");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId =
          prefs.getString('userId'); // Retrieve userId from SharedPreferences
      if (currentUrl.contains("checkout-success")) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => CheckoutSuccessView(userId: userId!)),
        );
      } else if (currentUrl.contains("checkout-failure")) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => CheckoutFailureView()),
        );
      }
    } else {
      // Mobile-specific deep linking logic
      try {
        final initialUri = await getInitialUri();
        if (initialUri != null) {
          _handleDeepLink(initialUri);
        }

        _sub = uriLinkStream.listen((Uri? uri) {
          if (uri != null) {
            _handleDeepLink(uri);
          }
        }, onError: (err) {
          print('Deep link error: $err');
        });
      } catch (e) {
        print('Failed to initialize deep linking: $e');
      }
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getString('userId'); // Retrieve userId from SharedPreferences
    if (uri.host == 'checkout-success') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => CheckoutSuccessView(userId: userId!)),
      );
    } else if (uri.host == 'checkout-failure') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CheckoutFailureView()),
      );
    }
  }

  Future<void> _handleWebRedirect() async {
    if (kIsWeb) {
      final currentUrl = html.window.location.href;
      print("Current URL on web: $currentUrl");

      final uri = Uri.parse(currentUrl);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> cartItems =
          List<Map<String, dynamic>>.from(
        json.decode(prefs.getString('cartItems') ?? '[]'),
      );
      final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
        json.decode(prefs.getString('items') ?? '[]'),
      );
      final referenceNumber = prefs.getString('referenceNumber') ?? '';
      final totalAmount = prefs.getDouble('totalAmount') ?? 0.0;
      final shippingFee = prefs.getDouble('shippingFee') ?? 0.0;
      final userAddress = json.decode(prefs.getString('userAddress') ?? '{}');

      print("Retrieved data from SharedPreferences:");
      print("Cart Items: $cartItems");
      print("Reference Number: $referenceNumber");
      print("Total Amount: $totalAmount");
      print("Shipping Fee: $shippingFee");
      print("User Address: $userAddress");

      final userId = prefs.getString('userId');

      final authViewModel = context.read<AuthViewModel>();
      final cartViewModel = context.read<CartViewModel>();

      final region = prefs.getString('region') ?? '';
      final province = prefs.getString('province') ?? '';
      final municipality = prefs.getString('municipality') ?? '';
      final barangay = prefs.getString('barangay') ?? '';
      final street = prefs.getString('street') ?? '';
      final zip = prefs.getString('zip') ?? '';

      if (region.isEmpty ||
          province.isEmpty ||
          municipality.isEmpty ||
          barangay.isEmpty) {
        throw Exception("Incomplete address information in SharedPreferences.");
      }

      final reconstructedAddress = Address(
        region: region,
        province: province,
        municipality: municipality,
        barangay: barangay,
        street: street,
        zip: zip,
      );
      try {
        if (uri.queryParameters['message'] == 'true') {
          print("Payment successful. Processing checkout...");

          // Fetch product IDs for the cart items
          final List<Map<String, dynamic>> stockUpdates = [];
          for (var item in cartItems) {
            final productId = await fetchProductIdByName(item['name']);
            if (productId != null) {
              stockUpdates.add({
                "productId": productId,
                "size": item['selectedSize'],
                "quantity": item['quantity'],
              });
            } else {
              print("No product ID found for item: ${item['name']}");
            }
          }
          final transactionPayload = {
            "userId": prefs.getString('userId'),
            "status": "Cart Processing",
            "amount": totalAmount,
            "transactionId": referenceNumber,
            "date": DateTime.now().toIso8601String(),
            "items": cartItems,
            "shippingFee": shippingFee,
            "address": reconstructedAddress,
          };

          await saveTransaction(
            cartItems,
            totalAmount,
            reconstructedAddress,
            referenceNumber,
          );

          await _updateStockInDatabase(
            cartItems, // Pass the List<Map<String, dynamic>>
            cartViewModel,
          );

          // Delete Cart Items
          await _deleteCartItems(items);

          authViewModel.logins();

          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => CheckoutSuccessView(userId: userId!),
            ),
          );
        } else if (uri.queryParameters['message'] == 'false') {
          print("Payment failed. Navigating to CheckoutFailureView...");
          authViewModel.logins();

          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(builder: (context) => CheckoutFailureView()),
          );
        } else {
          print("Unrecognized query parameter. Staying on the current page.");
        }
      } catch (e, stackTrace) {
        print("Error during web redirect handling: $e");
        print(stackTrace);
      }
    }
  }

  Future<String?> fetchProductIdByName(String productName) async {
    try {
      final response = await http
          .get(Uri.parse('https://ip-tienda-han-backend.onrender.com/product/$productName'));
      if (response.statusCode == 200) {
        final productJson = jsonDecode(response.body);
        print('API Response: $productJson'); // Log the API response

        // Extract 'id' directly from the JSON response
        final productId = productJson['id'] as String?;
        if (productId != null) {
          print('Fetched Product ID: $productId');
          return productId;
        } else {
          print('Product ID not found in the response.');
          return null;
        }
      } else {
        print('Failed to fetch product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Future<void> _updateStockInDatabase(
      List<Map<String, dynamic>> cartItems, CartViewModel cartViewModel) async {
    print("Executing updateStockInDatabase in CheckoutViewState...");

    final List<Map<String, dynamic>> stockUpdates = [];

    for (var item in cartItems) {
      final productName = item['name'];
      final quantity = item['quantity'];
      final selectedSize = item['selectedSize'] ?? "N/A";

      // Fetch product ID if it is missing

      // Fetch product ID by name
      final productId = await fetchProductIdByName(productName);
      if (productId == null) {
        throw Exception("Product ID could not be fetched for: $productName");
      }

      // Add to stock updates list
      stockUpdates.add({
        "id": productId,
        "name": productName,
        "size": selectedSize,
        "quantity": quantity,
      });
    }

    // Log and send payload to API
    print("Payload to API: ${json.encode({"updates": stockUpdates})}");

    final response = await http.post(
      Uri.parse("https://ip-tienda-han-backend.onrender.com/api/updateStock"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"updates": stockUpdates}),
    );

    if (response.statusCode != 200) {
      print("Error response: ${response.body}");
      throw Exception("Failed to update stock: ${response.body}");
    }
  }

  Future<void> saveTransaction(
    List<Map<String, dynamic>> cartItems,
    double totalAmount,
    Address reconstructedAddress,
    String referenceNumber,
  ) async {
    print("saveTransaction invoked:");
    print("Cart Items: $cartItems");
    print("Total Amount: $totalAmount");
    print("Reconstructed Address: $reconstructedAddress");

    print("Reference Number: $referenceNumber");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authViewModel = context.read<AuthViewModel>();
    final userId = prefs.getString('userId');

    // Fetch user details and address
    await authViewModel.fetchUserDetails();
    final currentUser = authViewModel.user;

    final region = prefs.getString('region') ?? '';
    final province = prefs.getString('province') ?? '';
    final municipality = prefs.getString('municipality') ?? '';
    final barangay = prefs.getString('barangay') ?? '';
    final street = prefs.getString('street') ?? '';
    final zip = prefs.getString('zip') ?? '';

    if (region.isEmpty ||
        province.isEmpty ||
        municipality.isEmpty ||
        barangay.isEmpty) {
      throw Exception("Incomplete address information in SharedPreferences.");
    }

    reconstructedAddress = Address(
      region: region,
      province: province,
      municipality: municipality,
      barangay: barangay,
      street: street,
      zip: zip,
    );

    final serializedItems = cartItems.map((item) {
      print("Original Cart Item: $item");
      final serializedItem = {
        "name": item['name'].trim(),
        "size": item['selectedSize'] ?? "N/A",
        "quantity": item['quantity'] ?? 0,
        "price": item['adjustedPrice'] ?? 0.0,
      };
      print("Serialized Item: $serializedItem");
      return serializedItem;
    }).toList();

    int totalQuantity = serializedItems.fold(
        0, (sum, item) => sum + (item['quantity'] as num).toInt());

    // Construct payload
    final transactionPayload = {
      "userId": userId,
      "status": "Cart Processing",
      "amount": serializedItems.fold(
          0.0, (sum, item) => sum + (item['price'] * item['quantity'])),
      "quantity": totalQuantity,
      "transactionId": referenceNumber,
      "date": DateTime.now().toIso8601String(),
      "item": serializedItems
          .map((item) => item['name'])
          .join(", "), // Only include names, separated by "; "
      "totalAmount": totalAmount,
      "contact": currentUser?.phone ?? '',
      "name": currentUser?.name ?? '',
      "address": reconstructedAddress.fullAddress(), // Use fullAddress() here
    };

    try {
      print("Sending Transaction Payload: ${json.encode(transactionPayload)}");
      print("Transaction Endpoint: https://ip-tienda-han-backend.onrender.com/api/transactions");

      final response = await http.post(
        Uri.parse('https://ip-tienda-han-backend.onrender.com/api/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transactionPayload),
      );

      print(
          "Transaction API Response: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Transaction saved successfully.");
        print("Transaction saved: $transactionPayload");
      } else {
        Fluttertoast.showToast(
            msg: "Error saving transaction. Code: ${response.statusCode}");
        print(
            "Error saving transaction: ${response.statusCode}, ${response.body}");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Error saving transaction: $error");
      print("Error saving transaction: $error");
    }
  }

  Future<void> _deleteCartItems(List<Map<String, dynamic>> cartItems) async {
    print("Executing deleteCartItems in CheckoutViewState...");

    final List<String> cartItemIds = [];

    for (var item in cartItems) {
      if (item.containsKey('cartItemId') && item['cartItemId'] != null) {
        cartItemIds.add(item['cartItemId'] as String); // Collect 'cartItemId'
      } else {
        print("No cartItemId found for item: $item");
      }
    }

    if (cartItemIds.isEmpty) {
      print("No valid cartItemIds found for deletion.");
      return;
    }

    try {
      print("Payload to API: ${json.encode({"cartItemIds": cartItemIds})}");

      final response = await http.post(
        Uri.parse("https://ip-tienda-han-backend.onrender.com/api/cart/removeItems"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"cartItemIds": cartItemIds}),
      );

      if (response.statusCode == 200) {
        print("Items successfully removed from cart: $cartItemIds");
      } else if (response.statusCode == 404) {
        print("No items found to remove: ${response.body}");
      } else {
        print(
            "Failed to remove items: ${response.statusCode}, ${response.body}");
      }
    } catch (error) {
      print("Error removing items from cart: $error");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Tienda',
      home: SafeArea(
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens(context),
          ),
        ),
      ),
      builder: (context, child) {
        return MediaQuery.withNoTextScaling(
            child: child ?? const SizedBox.shrink());
      },
    );
  }

  List<Widget> _screens(BuildContext context) {
    final authViewModel =
        context.watch<AuthViewModel>(); // Get the AuthViewModel instance
    String? userId;
    SharedPreferences.getInstance().then((prefs) {
      userId = prefs.getString('userId');
    });
    return <Widget>[
      const HomeView(),
      const CartView(),
      const ProfileView(),
      LoginView(
        onLogin: () {
          final authViewModel = context.read<AuthViewModel>();
          authViewModel.logins().then((_) async {
            if (authViewModel.isLoggedIn) {
              // Get user info from authViewModel
              final userInfo = authViewModel
                  .user; // Assuming this is where user info is stored

              // Store user info in SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                  'userId', userInfo!.id); // Replace 'id' with actual field
              await prefs.setString('userName',
                  userInfo.name); // Replace 'name' with actual field
              await prefs.setString('userEmail',
                  userInfo.email); // Replace 'email' with actual field
              // Add other user details as needed

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeView()),
              );
            }
          });
        },
        onCreateAccount: () {
          final authViewModel = context.read<AuthViewModel>();
          // Navigate to the Signup View
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SignupView(
                onLogin: () {
                  authViewModel.logins();
                },
              ),
            ),
          );
        },
      ),
    ];
  }
}

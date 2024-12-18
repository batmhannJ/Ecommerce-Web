import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/constant/enum/product_size.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/form_styles.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/model/address.dart';
import 'package:indigitech_shop/model/user.dart';
import 'package:indigitech_shop/view/address_view.dart';
import 'package:indigitech_shop/view/auth/login_view.dart';
import 'package:indigitech_shop/view/auth/signup_view.dart';
import 'package:indigitech_shop/view/checkout_view.dart';
import 'package:indigitech_shop/widget/product_list.dart';
import 'package:indigitech_shop/view_model/address_view_model.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:indigitech_shop/view_model/cart_view_model.dart';
import 'package:indigitech_shop/widget/form_fields/custom_text_form_field.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/product.dart';
import '../widget/buttons/custom_filled_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartView extends StatefulWidget {
  final User? user; // Allow null to handle cases where user may not be set
  final Address? address; // Assuming Address is your address model

  const CartView({super.key, this.user, this.address});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  Map<Product, ProductSize> selectedSizes = {};

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchUserCart();
  }

  Future<String?> getUserIdFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      final authViewModel =
          context.watch<AuthViewModel>(); // Get AuthViewModel instance

      // Redirect to LoginView if not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginView(
            onLogin: () async {
              // Save login state to SharedPreferences
              await prefs.setBool('isLoggedIn', true);

              // Fetch userId after successful login
              String? userId =
                  prefs.getString('userId'); // Ensure userId is stored
              if (userId != null) {
                await _fetchUserCart(); // Call the method to fetch cart items
              }

              // Navigate to the next screen
              _navigateToCheckout(authViewModel.address);
            },
            onCreateAccount: () {
              // Navigate to Signup View
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SignupView(
                    onLogin: () {
                      // After account creation, proceed
                      _navigateToCheckout(authViewModel.address);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // If already logged in, fetch the cart directly
      String? userId = prefs.getString('userId'); // Ensure userId is stored
      if (userId != null) {
        await _fetchUserCart(); // Call the method to fetch cart items
      }
    }
  }

  Future<void> _fetchUserCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        print("No userId found in SharedPreferences.");
        return;
      }

      print("Fetched userId: $userId");

      final apiUrl = 'http://localhost:4000/api/cart/$userId';
      final response = await http.get(Uri.parse(apiUrl));
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['cartItems'] != null && data['cartItems'] is List) {
          final cartItems = List<Map<String, dynamic>>.from(data['cartItems']);
          print("Cart items fetched: $cartItems");

          final cartViewModel = context.read<CartViewModel>();
          Map<Product, Map<String, dynamic>> updatedCartItems =
              {}; // Store updated cart items

          for (var item in cartItems) {
            print("Processing item: $item");

            if (item != null) {
              try {
                String productId =
                    item['productId'].toString(); // Correct productId usage
                String productName = item['name'] ??
                    "Unknown Product"; // Default if not available
                double adjustedPrice = (item['adjustedPrice'] ?? 0).toDouble();
                double oldPrice = (item['old_price'] ?? 0).toDouble();
                double newPrice = (item['new_price'] ?? 0).toDouble();
                double discount = (item['discount'] ?? 0).toDouble();
                String description =
                    item['description'] ?? "No description available";
                List<String> tags =
                    item['tags'] != null ? List<String>.from(item['tags']) : [];
                List<String> image = item['image'] != null
                    ? List<String>.from(item['image'])
                    : [];

                // Fetch product details using the correct productId
                final productResponse = await http.get(
                    Uri.parse('http://localhost:4000/api/products/$productId'));
                if (productResponse.statusCode == 200) {
                  final productData = json.decode(productResponse.body);
                  productName = productData['name'] ?? productName;
                  description = productData['description'] ?? description;
                  oldPrice = productData['old_price']?.toDouble() ?? oldPrice;
                  newPrice = productData['new_price']?.toDouble() ?? newPrice;
                  adjustedPrice =
                      productData['new_price']?.toDouble() ?? adjustedPrice;
                  discount = productData['discount']?.toDouble() ?? discount;

                  // Log fetched product data to confirm
                  print("Fetched product data: $productData");
                } else {
                  print(
                      "Failed to fetch product details for productId: $productId");
                }

                // Instantiate Product object with updated details
                Product product = Product(
                  id: productId,
                  name: productName,
                  adjustedPrice: adjustedPrice,
                  old_price: oldPrice,
                  new_price: newPrice,
                  discount: discount,
                  description: description,
                  reviews: [], // Add reviews if available
                  stocks: {}, // Add stock data if available
                  s_stock: item['s_stock'] ?? 0,
                  m_stock: item['m_stock'] ?? 0,
                  l_stock: item['l_stock'] ?? 0,
                  xl_stock: item['xl_stock'] ?? 0,
                  category: item['category'] ?? "Uncategorized",
                  tags: tags,
                  image: image,
                  available: item['available'] ?? false,
                  isNew: item['isNew'] ?? false,
                );

                int quantity = item['quantity'] ?? 1;
                String size = item['selectedSize'] ?? "Unknown";

                // Update cart items directly in the ViewModel
                updatedCartItems[product] = {
                  'quantity': quantity,
                  'selectedSize': size,
                };
              } catch (e) {
                print("Error processing cart item: $e");
              }
            }
          }

          // Update the CartViewModel's cartItems with the fetched data
          cartViewModel.updateCartItems(updatedCartItems);
        } else {
          print("No items found in cart data.");
        }
      } else {
        print("Failed to fetch cart: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching cart: $e");
    }
  }

// Function to fetch item name based on cartItemId (productId)
  Future<String> _fetchItemName(String productId) async {
    try {
      final apiUrl =
          'http://localhost:4000/api/products/$productId'; // Assuming endpoint for fetching product details
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['name'] != null) {
          return data['name']; // Assuming 'name' is the field for item name
        } else {
          return 'Unknown Product';
        }
      } else {
        print('Failed to fetch item name: ${response.statusCode}');
        return 'Unknown Product';
      }
    } catch (e) {
      print('Error fetching item name: $e');
      return 'Unknown Product';
    }
  }

  void _navigateToCheckout(Address? userAddress) {
    // Prepare cart items to pass
    List<Map<String, dynamic>> cartItems =
        context.read<CartViewModel>().items.map((entry) {
      Product product = entry.key;
      int quantity = entry.value;
      String selectedSize = selectedSizes[product]?.name ??
          ""; // Get selected size for each product
// Assuming you have a way to get the selected size for each product
      return {
        'name': product.name,
        'selectedSize': selectedSize, // Modify to get actual selected size
        'quantity': quantity,
      };
    }).toList();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CheckoutView(
          address: userAddress,
          cartItems: cartItems, // Pass the cart items
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<Product, int>> items =
        context.select<CartViewModel, List<MapEntry<Product, int>>>(
      (value) => value.items,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        color: AppColors.lightGrey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 50.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        'CART',
                        style: AppTextStyles.headline5.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  MapEntry<Product, int> item = items[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      leading: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductList(products: [item.key]),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: item.key.image.isNotEmpty
                              ? Image.network(
                                  'http://localhost:4000/upload/images/${item.key.image[0]}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Image.asset(
                                        'assets/images/placeholder_food.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text(
                                    "No image available",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                        ),
                      ),
                      title: Text(
                        item.key.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the selected size
                            Text(
                              "Size: ${context.watch<CartViewModel>().getSelectedSize(item.key)?.name ?? 'N/A'}",
                              style: AppTextStyles.body2.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "₱${context.read<CartViewModel>().totalItemPrice(item.key)}",
                                    style: AppTextStyles.body2.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                QuantitySelector(
                                  product: item.key,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cart Totals",
                      style: AppTextStyles.headline5.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Subtotal",
                          style: AppTextStyles.body2.copyWith(fontSize: 14),
                        ),
                        Text(
                          "₱${context.read<CartViewModel>().getSubtotal()}",
                          style: AppTextStyles.body2.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        color: AppColors.greyAD.withAlpha(100),
                        height: 0,
                        thickness: 1.5,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: AppTextStyles.subtitle1.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "₱${context.read<CartViewModel>().getSubtotal()}",
                          style: AppTextStyles.subtitle1.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      disabled: items.isEmpty,
                      text: "PROCEED TO CHECKOUT",
                      textStyle: AppTextStyles.button,
                      height: 50,
                      fillColor:
                          Color(0xFF778C62), // Maroon color for the button
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14),
                      command: () async {
                        final authViewModel = context.read<AuthViewModel>();
                        final addressViewModel = context.read<AuthViewModel>();

                        // Check if the user is logged in
                        if (!authViewModel.isLoggedIn) {
                          // Prompt user to log in
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "You need to log in to proceed to checkout")),
                          );
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginView(
                                onLogin: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool(
                                      'isLoggedIn', true); // Save login state
                                  _navigateToCheckout(addressViewModel
                                      .address); // Proceed to CheckoutView after login
                                },
                                onCreateAccount: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SignupView(onLogin: () {
                                              _navigateToCheckout(addressViewModel
                                                  .address); // Proceed to CheckoutView after account creation
                                            })),
                                  );
                                },
                              ),
                            ),
                          );
                        } else {
                          // User is logged in, proceed to CheckoutView
                          _navigateToCheckout(addressViewModel.address);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on String? {
  Null get first => null;
}

class QuantitySelector extends StatelessWidget {
  final Product product;
  const QuantitySelector({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    int itemCount = context.watch<CartViewModel>().itemCount(product);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.greyAD.withAlpha(100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              context.read<CartViewModel>().subtractItem(product);
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                itemCount > 1 ? Symbols.remove : Symbols.delete,
                size: 15,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              border: Border(
                left: BorderSide(color: AppColors.greyAD.withAlpha(100)),
                right: BorderSide(color: AppColors.greyAD.withAlpha(100)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Text(
                "$itemCount",
                style: AppTextStyles.caption
                    .copyWith(fontWeight: AppFontWeights.bold),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<CartViewModel>().addItem(product);
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: const Icon(
                Symbols.add,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

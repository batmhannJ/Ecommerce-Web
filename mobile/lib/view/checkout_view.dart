import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/model/user.dart';
import 'package:indigitech_shop/services/address_service.dart';
import 'package:indigitech_shop/view/address_view.dart';
import 'package:indigitech_shop/view/layout/default_view_layout.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // Add this import
import 'dart:convert';
import '../model/address.dart';
import '../model/product.dart';
import '../view_model/cart_view_model.dart';
import '../widget/buttons/custom_filled_button.dart';
import 'package:indigitech_shop/view/checkout_result.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class CheckoutView extends StatefulWidget {
  final User? user; // User information passed from AddressView
  final Address? address;
  final List<Map<String, dynamic>>
      cartItems; // List of items with product name, size, and quantity

  const CheckoutView({
    super.key,
    this.user,
    this.address,
    required this.cartItems, // Make cartItems required
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final AddressService _addressService =
      AddressService('https://isaacdarcilla.github.io/philippine-addresses');
  int? _stockCount;
  double shippingFee = 0.0; // Non-nullable, default to 0.0

  Future<Map<String, double>?> fetchCoordinates(String address) async {
    const apiKey = '072e48c34a52df1351a9de28cf930b88'; // Your API key
    final url =
        'http://api.positionstack.com/v1/forward?access_key=$apiKey&query=$address';

    print("Fetching coordinates for address: $address");

    try {
      // Delay bago magpadala ng request
      await Future.delayed(Duration(seconds: 2));

      final response = await http.get(Uri.parse(url));
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'].isNotEmpty) {
          print("Fetched Coordinates: ${data['data'][0]}");
          return {
            'latitude': data['data'][0]['latitude'],
            'longitude': data['data'][0]['longitude'],
          };
        } else {
          print("No data found for the address.");
        }
      } else {
        print("Error fetching coordinates: ${response.body}");
        if (response.statusCode == 429) {
          Fluttertoast.showToast(
              msg: "Too many requests. Please try again later.");
        }
      }
    } catch (error) {
      print("Error fetching coordinates: $error");
      Fluttertoast.showToast(msg: "Error fetching coordinates.");
    }
    return null;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c; // Returns distance in kilometers
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<void> calculateShippingFee(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();
    final userAddress = authViewModel.address;

    if (userAddress == null) {
      print("User address is null");
      return;
    }

    final regionCode = userAddress.region;

    if (regionCode == null) {
      print("User region is null");
      return;
    }

    print("User Region: $regionCode");

    const mainOfficeLat = 14.628488; // Main office latitude
    const mainOfficeLon = 121.03342; // Main office longitude

    double distance = 0.0;

    if (regionCode == 'NCR') {
      distance = 10; // Example value; adjust as needed for NCR
    } else {
      distance = 16; // Example value for non-NCR
    }

    setState(() {
      shippingFee = distance * 5; // Calculate the fee based on distance
    });

    print("Calculated Shipping Fee: PHP $shippingFee");
  }

  Future<void> proceedToPayment(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();
    final userAddress = authViewModel.address;

    if (userAddress == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Incomplete Address"),
          content: Text(
              "Please complete your address before proceeding to payment."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final cartViewModel = context.read<CartViewModel>();
    final items = cartViewModel.items;
    final subtotal = cartViewModel.getSubtotal();
    final referenceNumber = DateTime.now().millisecondsSinceEpoch.toString();

    final paymongoUrl = "https://api.paymongo.com/v1";
    const secretKey =
        'sk_test_fp78egyq6UtfYJMVaRf8DX2v'; // Replace with your secret key
    final authHeader = base64Encode(utf8.encode('$secretKey:'));

    final lineItems = items.map<Map<String, dynamic>>((productEntry) {
      final product = productEntry.key;
      final quantity = productEntry.value;
      final selectedSize = cartViewModel.getSelectedSize(product);

      return {
        "name": product.name,
        "description": "Size: ${selectedSize?.name ?? 'N/A'}",
        "amount": (product.new_price * 100).toInt(),
        "quantity": quantity,
        "currency": "PHP",
      };
    }).toList();

    final deliveryFeeItem = {
      "name": "Delivery Fee",
      "description": "Delivery to your address",
      "amount": (shippingFee * 100).toInt(),
      "quantity": 1,
      "currency": "PHP",
    };

    final payload = {
      "data": {
        "attributes": {
          "amount": ((subtotal + shippingFee) * 100).toInt(),
          "description": "Payment for Order $referenceNumber",
          "currency": "PHP",
          "payment_method_types": ["gcash", "grab_pay", "paymaya", "card"],
          "livemode": false,
          "statement_descriptor": "Tienda",
          "success_redirect_url":
              "http://localhost:3000/myorders?transaction_id=$referenceNumber&status=success",
          "cancel_redirect_url": "http://localhost:3000/cart?status=canceled",
          "line_items": [...lineItems, deliveryFeeItem],
        },
      },
    };

    try {
      final response = await http.post(
        Uri.parse("$paymongoUrl/checkout_sessions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $authHeader",
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final checkoutUrl = responseData['data']['attributes']['checkout_url'];

        if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
          await launchUrl(Uri.parse(checkoutUrl));
          //toast("Redirecting to payment gateway...", context);

          await saveTransaction(
            Map.fromEntries(items),
            subtotal + shippingFee,
            userAddress,
            referenceNumber,
          );

          await _updateStockInDatabase(items as List<Map<String, dynamic>>);
        } else {
          throw Exception("Failed to launch payment URL");
        }
      } else {
        throw Exception("Payment failed: ${response.body}");
      }
    } catch (e) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CheckoutFailureView()),
      );
      print("Error: $e");
    }
  }

  List<dynamic> regions = [];
  List<dynamic> provinces = [];
  List<dynamic> cities = [];
  List<dynamic> barangays = [];

  String? selectedRegion;
  String? selectedProvince;
  String? selectedCity;
  String? selectedBarangay;

  @override
  void initState() {
    super.initState();
    final authViewModel = context.read<AuthViewModel>();
    authViewModel.fetchUserAddress().then((_) {
      setState(() {
        final userAddress = authViewModel.address;

        selectedRegion = userAddress?.region;
        selectedProvince = userAddress?.province;
        selectedCity = userAddress?.municipality;
        selectedBarangay = userAddress?.barangay;

        if (selectedRegion != null) {
          fetchProvinces(selectedRegion!);
        }
        if (selectedProvince != null) {
          fetchCities(selectedProvince!);
        }
        if (selectedCity != null) {
          fetchBarangays(selectedCity!);
        }
        print('Street: ${userAddress?.street}');
        print('Zip: ${userAddress?.zip}');

        WidgetsBinding.instance.addPostFrameCallback((_) {
          calculateShippingFee(context);
        });
      });
    });

    fetchRegions();
    _loadStockCount();
  }

  Future<void> _loadStockCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _stockCount = prefs.getInt('stockCount');
    });
  }

  Future<void> _updateStockInDatabase(
      List<Map<String, dynamic>> lineItems) async {
    final stockUpdates = lineItems.map((item) {
      return {
        "id": item["id"], // Assuming each lineItem has a product ID
        "size": item["description"] ?? "N/A",
        "quantity": item["quantity"],
      };
    }).toList();

    await http.post(
      Uri.parse("http://localhost:4000/api/updateStock"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"updates": stockUpdates}),
    );
  }

  Future<void> saveTransaction(
    Map<Product, int> items,
    double totalAmount,
    Address userAddress,
    String referenceNumber,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authViewModel = context.read<AuthViewModel>();
    final userId = prefs.getString('userId');

    // Fetch user details and address
    await authViewModel.fetchUserDetails();
    final currentUser = authViewModel.user;
    final fetchedUserAddress = authViewModel.address;

    if (userId == null) {
      Fluttertoast.showToast(msg: "User ID not found. Please log in.");
      return;
    }

    if (currentUser == null) {
      Fluttertoast.showToast(msg: "User details not found. Please log in.");
      return;
    }

    if (fetchedUserAddress == null) {
      Fluttertoast.showToast(msg: "User address not found.");
      return;
    }

    final regionName = getRegionName(fetchedUserAddress.region);
    final provinceName = getProvinceName(fetchedUserAddress.province);
    final cityName = getCityName(fetchedUserAddress.municipality);
    final barangayName = getBarangayName(fetchedUserAddress.barangay);
    final cartViewModel = context.read<CartViewModel>();
    final cartItems = widget.cartItems; // Assuming cartItems is already a map
    final subtotal = cartViewModel.getSubtotal();
    final referenceNumber = DateTime.now().millisecondsSinceEpoch.toString();

    // Serialize items
    final serializedItems = items.entries.map((entry) {
      final product = entry.key;
      final quantity = entry.value;
      return {
        "name": product.name.trim(),
      };
    }).toList(); // Convert to a list of JSON objects

    final transactionPayload = {
      "userId": userId,
      "status": "Cart Processing",
      "amount": subtotal,
      "quantity": serializedItems.length,
      "transactionId": referenceNumber,
      "date": DateTime.now().toIso8601String(),
      "item": serializedItems
          .map((item) => "${item['name']}")
          .join(';'), // Convert array to a single string
      "totalAmount": totalAmount,
      "contact": currentUser.phone ?? '', // Ensure phone is available
      "name": currentUser.name ?? '', // Ensure name is available
      "address":
          "${fetchedUserAddress.street}, $barangayName, $cityName, $provinceName, ${fetchedUserAddress.zip}",
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/api/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transactionPayload),
      );

      if (response.statusCode == 200) {
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

  Future<void> fetchRegions() async {
    try {
      regions = await _addressService.regions();
      setState(() {
        if (selectedRegion != null &&
            regions.any((region) => region['region_code'] == selectedRegion)) {
          selectedRegion = selectedRegion;
        } else if (regions.isNotEmpty) {
          selectedRegion = regions[0]['region_code'];
        } else {
          selectedRegion = null; // Handle the case when there are no regions
        }
      });
    } catch (error) {
      print("Error fetching regions: $error");
    }
  }

  Future<void> fetchProvinces(String regionCode) async {
    try {
      List<dynamic> fetchedProvinces =
          await _addressService.provinces(regionCode);
      setState(() {
        provinces.clear(); // Clear previous provinces to avoid duplicates
        provinces.addAll(fetchedProvinces);
        if (provinces
            .any((province) => province['province_code'] == selectedProvince)) {
          selectedProvince = selectedProvince;
        } else {
          selectedProvince = provinces.isNotEmpty
              ? provinces[0]['province_code']
              : null; // Default to first province
        }
      });
    } catch (error) {
      print("Error fetching provinces: $error");
    }
  }

  Future<void> fetchCities(String provinceCode) async {
    try {
      List<dynamic> fetchedCities = await _addressService.cities(provinceCode);
      setState(() {
        cities.clear(); // Clear previous cities to avoid duplicates
        cities.addAll(fetchedCities);
        // Reset selectedCity if it's not found in the new list
        if (cities.any((city) => city['city_code'] == selectedCity)) {
          // If selectedCity exists in the new cities
          selectedCity = selectedCity;
        } else {
          selectedCity = cities.isNotEmpty
              ? cities[0]['city_code']
              : null; // Default to first city
        }
        if (selectedCity != null) {
          fetchBarangays(selectedCity!);
        }
      });
    } catch (error) {
      print("Error fetching cities: $error");
    }
  }

  Future<void> fetchBarangays(String cityCode) async {
    try {
      List<dynamic> fetchedBarangays =
          await _addressService.barangays(cityCode);
      setState(() {
        barangays.clear(); // Clear previous barangays to avoid duplicates
        barangays.addAll(fetchedBarangays);
        if (barangays
            .any((barangay) => barangay['brgy_code'] == selectedBarangay)) {
          selectedBarangay = selectedBarangay; // Keep it as is if found
        } else {
          selectedBarangay = barangays.isNotEmpty
              ? barangays[0]['brgy_code']
              : null; // Default to first barangay
        }
      });
    } catch (error) {
      print("Error fetching barangays: $error");
    }
  }

  String getRegionName(String? regionCode) {
    final region = regions.firstWhere(
      (r) => r['region_code'] == regionCode,
      orElse: () =>
          {'region_name': "Not provided"}, // Ensure a valid map is returned
    ) as Map<String, dynamic>; // Cast to the expected type

    return region['region_name'] ?? "Not provided";
  }

  String getProvinceName(String? provinceCode) {
    final province = provinces.firstWhere(
      (p) => p['province_code'] == provinceCode,
      orElse: () =>
          {'province_name': "Not provided"}, // Ensure a valid map is returned
    ) as Map<String, dynamic>; // Cast to the expected type

    return province['province_name'] ?? "Not provided";
  }

  String getCityName(String? cityCode) {
    final city = cities.firstWhere(
      (c) => c['city_code'] == cityCode,
      orElse: () =>
          {'city_name': "Not provided"}, // Ensure a valid map is returned
    ) as Map<String, dynamic>; // Cast to the expected type

    return city['city_name'] ?? "Not provided";
  }

  String getBarangayName(String? barangayCode) {
    final barangay = barangays.firstWhere(
      (b) => b['brgy_code'] == barangayCode,
      orElse: () =>
          {'brgy_name': "Not provided"}, // Ensure a valid map is returned
    ) as Map<String, dynamic>; // Cast to the expected type

    return barangay['brgy_name'] ?? "Not provided";
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final userAddress = authViewModel.address;

    return DefaultViewLayout(
      title: "Checkout",
      background: AppColors.coolGrey,
      content: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                orderDetailsCard(),
                itemsOrderedCard(context),
                userAddress != null
                    ? shippingInformationCard(context)
                    : addressPromptCard(
                        context), // Show address prompt if no address
                orderSummaryCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addressPromptCard(BuildContext context) {
    return InfoCard(
      title: "SET SHIPPING ADDRESS",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You haven't set a shipping address yet. Please set your address to proceed.",
            style: AppTextStyles.body2,
          ),
          const Gap(10),
          CustomButton(
            isExpanded: true,
            text: "Set Address",
            textStyle: AppTextStyles.button,
            command: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddressView()),
            ),
            height: 48,
            fillColor: AppColors.red,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ],
      ),
    );
  }

  Widget orderDetailsCard() {
    String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16), // Padding inside the container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Subtle shadow
            blurRadius: 4,
            offset: const Offset(0, 2), // Shadow position
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ORDER DETAILS",
            style: AppTextStyles.headline4.copyWith(
              fontWeight: AppFontWeights.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16), // Space below title
          _buildDetailRow(Icons.calendar_today, "Date", formattedDate),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 12), // Row padding
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light background color for row
        borderRadius: BorderRadius.circular(8), // Rounded corners for row
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black), // Black icon
          const SizedBox(width: 10), // Space between icon and title
          Expanded(
            // Use Expanded to take available space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: AppFontWeights.semiBold,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget itemsOrderedCard(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);

    List<MapEntry<Product, int>> items =
        context.select<CartViewModel, List<MapEntry<Product, int>>>(
      (value) => value.items,
    );

    return Card(
      elevation: 4, // Adds shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      margin: const EdgeInsets.symmetric(vertical: 10), // Card margin
      child: Padding(
        padding: const EdgeInsets.all(16), // Card padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ITEMS ORDERED",
              style: AppTextStyles.headline4.copyWith(
                fontWeight: AppFontWeights.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10), // Space between title and content
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                MapEntry<Product, int> item = items[index];
                final productEntry = cartViewModel.items[index];
                final product = productEntry.key;
                final selectedSize = cartViewModel.getSelectedSize(product);

                return Padding(
                  padding: EdgeInsets.only(top: index != 0 ? 20 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded image
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.greyAD),
                          ),
                          child: item.key.image.isNotEmpty
                              ? Image.network(
                                  'http://localhost:4000/upload/images/${item.key.image[0]}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
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
                      const SizedBox(
                          width: 10), // Spacing between image and text
                      Expanded(
                        child: SizedBox(
                          height: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.key.name,
                                style: AppTextStyles.body2.copyWith(
                                  fontWeight: AppFontWeights.bold,
                                  fontSize: 16, // Adjusted size
                                ),
                              ),
                              Text(
                                'Size: ${selectedSize != null ? selectedSize.name : 'N/A'}',
                                style: AppTextStyles.subtitle2.copyWith(
                                  color: AppColors
                                      .greyAD, // Lighter color for size
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: AppTextStyles.subtitle2,
                                  text: "Quantity:  ",
                                  children: [
                                    TextSpan(
                                      text: "${item.value}",
                                      style: const TextStyle(
                                        fontWeight: AppFontWeights.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget shippingInformationCard(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final userAddress = authViewModel.address;

    return Container(
      padding: const EdgeInsets.all(16), // Padding inside the container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Subtle shadow
            blurRadius: 4,
            offset: const Offset(0, 2), // Shadow position
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SHIPPING INFORMATION",
            style: AppTextStyles.headline4.copyWith(
              fontWeight: AppFontWeights.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16), // Space below title
          _buildShippingRow(
              Icons.home, 'Street', userAddress?.street ?? "Not provided"),
          const SizedBox(height: 10), // Space between rows
          _buildShippingRow(Icons.location_city, 'Barangay',
              getBarangayName(selectedBarangay)),
          const SizedBox(height: 10), // Space between rows
          _buildShippingRow(
              Icons.location_on, 'City', getCityName(selectedCity)),
          const SizedBox(height: 10), // Space between rows
          _buildShippingRow(
              Icons.map, 'Province', getProvinceName(selectedProvince)),
          const SizedBox(height: 10), // Space between rows
          _buildShippingRow(
              Icons.flag, 'Region', getRegionName(selectedRegion)),
          const SizedBox(height: 10), // Space between rows
          _buildShippingRow(
              Icons.mail, 'Zip', userAddress?.zip ?? "Not provided"),
        ],
      ),
    );
  }

  Widget _buildShippingRow(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 12), // Row padding
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light background color for row
        borderRadius: BorderRadius.circular(8), // Rounded corners for row
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black), // Black icon
          const SizedBox(width: 10), // Space between icon and title
          Expanded(
            // Use Expanded to take available space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, // Semi-bold for the title
                    fontSize: 16,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors
                          .grey), // Slightly smaller and grey for the value
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getFullAddress(Address userAddress,
      {String? barangay,
      String? municipality,
      String? province,
      String? region}) {
    final street = userAddress.street ?? "";
    final zip = userAddress.zip ?? "";

    return '$street${barangay != null ? ', $barangay' : ''}'
        '${municipality != null ? ', $municipality' : ''}'
        '${province != null ? ', $province' : ''}'
        '${region != null ? ', $region' : ''}'
        '${zip.isNotEmpty ? ', $zip' : ''}';
  }

  Widget orderSummaryCard(BuildContext context) {
    final double shippingFee =
        this.shippingFee; // Use the shippingFee from the state variable
    final subtotal = context.read<CartViewModel>().getSubtotal();
    final total = subtotal + shippingFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ORDER SUMMARY",
            style: AppTextStyles.headline4.copyWith(
              fontWeight: AppFontWeights.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade300), // Divider for separation
          const SizedBox(height: 8),
          _buildSummaryRow("Subtotal:", "₱${subtotal.toStringAsFixed(2)}",
              Icons.monetization_on),
          _buildSummaryRow("Shipping:", "₱${shippingFee.toStringAsFixed(2)}",
              Icons.local_shipping),
          Divider(color: Colors.grey.shade300), // Divider for total section
          _buildSummaryRow(
              "Total:", "₱${total.toStringAsFixed(2)}", Icons.payment,
              isTotal: true),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  isExpanded: true,
                  text: "Proceed to Payment",
                  textStyle: AppTextStyles.button.copyWith(color: Colors.white),
                  command: () => proceedToPayment(context),
                  height: 48,
                  fillColor: AppColors.red,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: isTotal ? Colors.green : Colors.black54),
              const SizedBox(width: 8), // Space between icon and text
              Text(
                label,
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: isTotal ? AppFontWeights.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              color: isTotal ? Colors.green : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final Widget content;
  const InfoCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text(
            title,
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: AppFontWeights.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: content,
        ),
      ],
    );
  }
}

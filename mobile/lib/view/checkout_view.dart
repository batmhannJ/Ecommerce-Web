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
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart'; // Add this import for URL launching
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

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
    const apiKey = 'c60e6af4b3421c7b225c09fa354560ec'; // Your API key
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

    // Get the region code from the user's address
    final regionCode = userAddress.region;

    if (regionCode == null) {
      print("User region is null");
      return;
    }

    print("User Region: $regionCode");

    const mainOfficeLat = 14.628488; // Main office latitude
    const mainOfficeLon = 121.03342; // Main office longitude

    double distance = 0.0;

    // Determine shipping fee based on the region
    if (regionCode == 'NCR') {
      distance = 10; // Example value; adjust as needed for NCR
    } else {
      // Default case for other regions; adjust as needed
      distance = 16; // Example value for non-NCR
    }

    setState(() {
      shippingFee = distance * 5; // Calculate the fee based on distance
    });

    print("Calculated Shipping Fee: PHP $shippingFee");
  }

  Future<void> proceedToPayment(BuildContext context) async {
    final userAddress = context.read<AuthViewModel>().address;

    if (userAddress == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Address Required"),
          content:
              Text("Please set your address before proceeding to payment."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return; // Stop if no address is set
    }
    final cartViewModel = context.read<CartViewModel>();
    final subtotal = cartViewModel.getSubtotal();
    final items = cartViewModel.items;

    final paymentData = {
      "totalAmount": {
        "currency": "PHP",
        "value": (subtotal + shippingFee)
            .toString(), // Include shipping fee in total
      },
      "requestReferenceNumber":
          DateTime.now().millisecondsSinceEpoch.toString(),
      "items": [
        ...items.map((productEntry) {
          final product = productEntry.key;
          final quantity = productEntry.value;
          final selectedSize = cartViewModel.getSelectedSize(product);

          return {
            "name": product.name,
            "size": selectedSize?.name ?? '', // Ensure size is included
            "quantity": quantity,
            "totalAmount": {
              "currency": "PHP",
              "value": subtotal.toString(),
            },
          };
        }).toList(),
        {
          "name": "Delivery Fee", // Name for delivery fee item
          "amount": {
            "currency": "PHP",
            "value": shippingFee.toString(), // Delivery fee value
          },
          "totalAmount": {
            "currency": "PHP",
            "value": shippingFee.toString(), // Total amount for delivery fee
          },
        },
      ],
    };

// Debug the updated payment data structure
    print("Payment Data: ${json.encode(paymentData)}");

    const publicKey =
        'pk-NCLk7JeDbX1m22ZRMDYO9bEPowNWT5J4aNIKIbcTy2a'; // Replace with your public key
    const secretKey =
        '8MqXdZYWV9UJB92Mc0i149CtzTWT7BYBQeiarM27iAi'; // Replace with your secret key
    final auth = base64Encode(utf8.encode('$publicKey:$secretKey'));

    final response = await http.post(
      Uri.parse("https://pg-sandbox.paymaya.com/checkout/v1/checkouts"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Basic $auth", // Set Authorization header
      },
      body: json.encode(paymentData),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final checkoutUrl =
          responseData['redirectUrl']; // Extract the redirect URl

      if (await canLaunch(checkoutUrl)) {
        await launch(checkoutUrl);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CheckoutSuccessView()),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CheckoutSuccessView()), // Navigate on successful payment
        );
        await _updateStockInDatabase(
          widget.cartItems,
          List<Map<String, dynamic>>.from(
              paymentData['items'] as List), // Cast to the correct type
        );

        await saveTransaction(paymentData, context);
      } else {
        // Handle the error if the URL cannot be launched
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CheckoutFailureView()),
        );
        print('Could not launch $checkoutUrl');
      }
    } else {
      // Handle failure - navigate to CheckoutFailureView
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CheckoutFailureView()),
      );
      print('Payment failed: ${response.body}');
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

        // Update drop-downs for region, province, city, and barangay
        selectedRegion = userAddress?.region;
        selectedProvince = userAddress?.province;
        selectedCity = userAddress?.municipality;
        selectedBarangay = userAddress?.barangay;

        // Fetch corresponding provinces, cities, and barangays based on address
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

    // Fetch regions initially
    fetchRegions();
    _loadStockCount();
  }

  Future<void> _loadStockCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _stockCount = prefs.getInt('stockCount');
    });
  }

  Future<void> _updateStockInDatabase(List<Map<String, dynamic>> cartItems,
      List<Map<String, dynamic>> paymentItems) async {
    for (var item in paymentItems) {
      final name = item['name'];
      final size = item['size'];
      final quantity = item['quantity'];

      // Check if required fields are present
      if (name == null || size == null || quantity == null) {
        print('Missing fields for item: $item');
        continue; // Skip this iteration if required fields are missing
      }

      final response = await http.post(
        Uri.parse('http://localhost:4000/updateStock'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'size': size,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        print('Stock updated successfully for $name');
      } else {
        print('Failed to update stock: ${response.body}');
      }
    }
  }

  Future<void> saveTransaction(
      Map<String, dynamic> paymentData, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    // Check if userId is null
    if (userId == null) {
      Fluttertoast.showToast(msg: "User ID not found. Please log in.");
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final userAddress = authViewModel.address;

    // Check if userAddress is not null
    if (userAddress == null) {
      Fluttertoast.showToast(msg: "User address not found.");
      return;
    }

    // Prepare transaction details
    final transactionDetails = {
      "transactionId": paymentData["requestReferenceNumber"],
      "date": DateTime.now().toIso8601String(),
      "name": authViewModel.user?.name ??
          "Unknown User", // Using null-aware operator
      "contact": authViewModel.user?.phone ??
          "No contact available", // Using null-aware operator
      "item": paymentData["items"].map((item) => item['name']).join(', '),
      "quantity": paymentData["items"]
          .map((item) => item['quantity'])
          .reduce((a, b) => a + b),
      "amount": paymentData["totalAmount"]["value"],
      "address":
          "${userAddress.street} ${userAddress.municipality} ${userAddress.province} ${userAddress.zip}",
      "status": "Cart Processing",
      "userId": userId,
    };

    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:4000/api/transactions'), // Change localhost to your machine IP
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transactionDetails),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Transaction saved successfully.");
        print("Transaction saved: $transactionDetails");
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
    // Get the current date and format it
    String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    return InfoCard(
      title: "ORDER DETAILS",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Date",
            style: AppTextStyles.body2
                .copyWith(fontWeight: AppFontWeights.semiBold),
          ),
          Text(
            formattedDate, // Use the formatted date here
            style: AppTextStyles.body2,
          ),
          const Gap(10),
          Text(
            "Order Number",
            style: AppTextStyles.body2
                .copyWith(fontWeight: AppFontWeights.semiBold),
          ),
          Text(
            "072102", // Keep this as is or modify if necessary
            style: AppTextStyles.body2,
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

    return InfoCard(
      title: "ITEMS ORDERED",
      content: ListView.builder(
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
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyAD)),
                  child: item.key.image.isNotEmpty
                      ? Image.network(
                          'http://localhost:4000/upload/images/${item.key.image[0]}', // Fetch image from local server
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Image.asset(
                                'assets/images/placeholder_food.png', // Local placeholder image
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
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                ),
                const Gap(10),
                SizedBox(
                  height: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.key.name,
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: AppFontWeights.bold,
                        ),
                      ),
                      Text(
                          'Size: ${selectedSize != null ? selectedSize.name : 'N/A'}'),
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
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget shippingInformationCard(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final userAddress = authViewModel.address;

    return InfoCard(
      title: "SHIPPING INFORMATION",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Street: ${userAddress?.street ?? "Not provided"}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Barangay: ${getBarangayName(selectedBarangay)}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'City: ${getCityName(selectedCity)}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Province: ${getProvinceName(selectedProvince)}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Region: ${getRegionName(selectedRegion)}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Zip: ${userAddress?.zip ?? "Not provided"}',
            style: const TextStyle(fontSize: 16),
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

    return InfoCard(
      title: "ORDER SUMMARY",
      content: Column(
        children: [
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
            },
            children: [
              TableRow(children: [
                Text(
                  "Subtotal:",
                  style: AppTextStyles.subtitle2,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    "₱${context.read<CartViewModel>().getSubtotal()}",
                    style: AppTextStyles.body2,
                  ),
                ),
              ]),
              TableRow(children: [
                Text(
                  "Shipping:",
                  style: AppTextStyles.subtitle2,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    "₱${shippingFee.toStringAsFixed(2)}", // Display calculated shipping fee
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ]),
              TableRow(children: [
                Text(
                  "Total:",
                  style: AppTextStyles.subtitle2
                      .copyWith(fontWeight: AppFontWeights.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    "₱${(context.read<CartViewModel>().getSubtotal() + shippingFee).toStringAsFixed(2)}", // Sum of subtotal and shipping fee
                    style: AppTextStyles.body2.copyWith(color: Colors.green),
                  ),
                ),
              ]),
            ],
          ),
          const Gap(25),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  isExpanded: true,
                  text: "Proceed",
                  textStyle: AppTextStyles.button,
                  command: () => proceedToPayment(
                      context), // Call the payment function here
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

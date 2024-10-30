import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart'; // for toast notifications
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class CheckoutSuccessView extends StatefulWidget {
  @override
  _CheckoutSuccessViewState createState() => _CheckoutSuccessViewState();
}

class _CheckoutSuccessViewState extends State<CheckoutSuccessView> {
  List<dynamic> orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUserOrders(); // Fetch user orders on initialization
  }

  // Function to get user ID from shared preferences
  Future<String> getUserIdFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ??
        ''; // Adjust this based on how you save user ID
  }

  // Function to fetch user orders from API
  Future<void> fetchUserOrders() async {
    final userId = await getUserIdFromPreferences(); // Await the user ID
    if (userId.isEmpty) {
      Fluttertoast.showToast(msg: "User not logged in.");
      setState(() {
        loading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:4000/api/transactions/userTransactions/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedOrders = json.decode(response.body);
        setState(() {
          orders = fetchedOrders;
          loading = false;
        });
      } else {
        Fluttertoast.showToast(msg: "Error fetching orders.");
        setState(() {
          loading = false;
        });
      }
    } catch (error) {
      print("Error fetching orders: $error");
      Fluttertoast.showToast(msg: "Error fetching orders.");
      setState(() {
        loading = false;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("My Orders")),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : orders.isNotEmpty
            ? ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    child: ExpansionTile(
                      title: Text("Item: ${order['item']}"),
                      children: [
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Order ID: ${order['transactionId']}"),
                              Text("Date: ${order['date']}"),
                              Text("Quantity: ${order['quantity']}"),
                              Text("Amount: ${order['amount']}"),
                              Text("Status: ${order['status']}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : const Center(child: Text("No orders found")),
  );
}
}

class CheckoutFailureView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Failed")),
      body: Center(
        child: Text("There was an issue with your payment. Please try again."),
      ),
    );
  }
}

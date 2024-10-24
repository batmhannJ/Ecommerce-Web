// checkout_result_view.dart
import 'package:flutter/material.dart';

class CheckoutSuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Successful")),
      body: Center(
        child: Text("Thank you for your purchase!"),
      ),
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

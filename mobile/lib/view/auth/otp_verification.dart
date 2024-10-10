import 'package:flutter/material.dart';
import 'package:gap/gap.dart'; // You might already have this
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:indigitech_shop/view/profile_view.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback onOTPVerified; // This will be called once OTP is verified

  OTPVerificationScreen({
    required this.email,
    required this.onOTPVerified,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();

  Future<void> _verifyOTP() async {
  String otp = _otpController.text.trim(); // Trim the OTP input
 
  if (otp.isNotEmpty) {
    bool isVerified = await _verifyOTPRequest(widget.email, otp); 
    if (isVerified) {
      widget.onOTPVerified(); 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileView()), // Replace with your ProfileView widget
        );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
    }
  }
}


  Future<bool> _verifyOTPRequest(String email, String otp) async {
  final response = await http.post(
    Uri.parse('http://localhost:4000/verify-otp-mobile'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'email': email,
      'otp': otp,
    }),
  );

  // Log the server response for debugging
  print("Server response: ${response.body}");

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}


  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter the OTP sent to ${widget.email}",
              style: TextStyle(fontSize: 16),
            ),
            const Gap(20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'OTP',
              ),
            ),
            const Gap(20),
            ElevatedButton(
              onPressed: _verifyOTP, // Verify OTP on button press
              child: Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}

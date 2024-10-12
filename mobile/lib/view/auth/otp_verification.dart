import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
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
        // Call the onOTPVerified callback
        widget.onOTPVerified();

        // Fetch userId after OTP verification
        String? userId = await _fetchUserId(widget.email);
        if (userId != null) {
          // Store the user ID in local storage
          await _storeUserId(userId);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfileView()), // Navigate to ProfileView
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User ID not found. Please try again.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid OTP. Please try again.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter the OTP.")),
      );
    }
  }

  Future<bool> _verifyOTPRequest(String email, String otp) async {
    try {
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
        final data = json.decode(response.body);
        return data['success']; // Return true if OTP verification succeeded
      } else {
        print("Error: ${response.statusCode}, ${response.body}");
        return false; // Return false if the response was not successful
      }
    } catch (e) {
      print("Exception: $e");
      return false; // Return false on exception
    }
  }

  Future<String?> _fetchUserId(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/get-user-id-by-email'), // New endpoint to fetch user ID by email
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email}),
      );

      // Log the server response for debugging
      print("Fetch User ID response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['userId']; // Return user ID from response
      } else {
        print("Error fetching user ID: ${response.statusCode}, ${response.body}");
        return null; // Return null if the response was not successful
      }
    } catch (e) {
      print("Exception while fetching user ID: $e");
      return null; // Return null on exception
    }
  }

  Future<void> _storeUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
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

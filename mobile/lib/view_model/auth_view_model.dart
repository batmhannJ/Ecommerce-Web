import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import '../model/address.dart';

class AuthViewModel extends ChangeNotifier {
  User? _user;
  Address? _address; // Holds the address

  User? get user => _user;
  Address? get address => _address; // Getter for the address

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // User state variables
  String? _userId; // The ID of the current user
  String? _currentPassword; // The current password for the user

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  void setAddress(Address newAddress) { // Method to set the address
    _address = newAddress;
    notifyListeners();
  }

  Future<void> updateUser({
    required String name,
    required String phone,
    required String email,
    required BuildContext context,
  }) async {
    if (_user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      final url = 'http://localhost:4000/api/edituser-mobile/$userId';

      final userData = {
        'name': name,
        'phone': phone,
        'email': email,
      };

      try {
        final response = await http.patch(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userData),
        );

        if (response.statusCode == 200) {
          final updatedUser = jsonDecode(response.body);
          _user = _user!.copyWith(
            name: updatedUser['name'],
            phone: updatedUser['phone'],
            email: updatedUser['email'],
          );

          notifyListeners();
          _showSnackBar(context, 'User details updated successfully.');
        } else {
          _showSnackBar(context, 'Failed to update user. Please try again.', isSuccess: false);
        }
      } catch (e) {
        _showSnackBar(context, 'Error updating user: $e', isSuccess: false);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isSuccess = true}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red, // Green for success, red for error
      duration: const Duration(seconds: 3), // Duration of the SnackBar
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> updateAddress({
    required String province,
    required String municipality, // Change `city` to `municipality`
    required String barangay,
    required String zip, // Change `postalCode` to `zip`
    required String street,
  }) async {
    // Validate that user is logged in
    if (_user != null) {
      // Create a new Address instance with the provided data
      final newAddress = Address(
        province: province,
        municipality: municipality, // Use municipality instead of city
        barangay: barangay,
        zip: zip, // Use zip instead of postalCode
        street: street, // Assuming street corresponds to line1
      );

      // Update the address
      _address = newAddress; 
      notifyListeners(); 

      // Send the updated address to your backend
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      final url = 'http://localhost:4000/api/update-address/$userId';
      final addressData = newAddress.toJson(); // Ensure Address class has a toJson method

      try {
        final response = await http.patch(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(addressData),
        );

        if (response.statusCode == 200) {
          print('Address updated successfully.');
        } else {
          print('Failed to update address: ${response.body}');
        }
      } catch (e) {
        print('Error updating address: $e');
      }
    } else {
      print('User not logged in. Cannot update address.');
    }
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // Method to change the password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // Simulate checking the old password
    if (_currentPassword == null || _currentPassword != oldPassword) {
      throw Exception("Old password is incorrect");
    }

    // Simulate changing the password (here you would make an API call)
    try {
      // Update the current password
      _currentPassword = newPassword;

      // Simulate a successful API response
      await Future.delayed(const Duration(seconds: 2));

      // Notify listeners about the state change if needed
      notifyListeners();
      print("Password changed successfully!");
    } catch (error) {
      // Handle any errors that occur during the password change
      print("Error changing password: $error");
      throw Exception("Failed to change password");
    }
  }

  Future<void> fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId'); // Ensure you retrieve the user ID

    if (userId != null) {
      try {
        final response = await http.get(
          Uri.parse('http://localhost:4000/api/get-user-details/$userId'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setUser(User.fromJson(data)); // Set the user correctly
          print('User fetched: ${data.toString()}'); // Debugging line
        } else {
          print('Failed to load user details');
        }
      } catch (e) {
        print('Exception: $e');
      }
    } else {
      print('User ID is null, cannot fetch user details');
    }
  }

  Future<void> fetchUserAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      try {
        final response = await http.get(
          Uri.parse('http://localhost:4000/get-user-address/$userId'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          // Ensure that you are checking the validity of data
          if (data != null) {
            setAddress(Address.fromJson(data));
            print('Address fetched: ${data.toString()}');
          } else {
            print('No address data found');
            setAddress(Address()); // Set to empty Address if null
          }
        } else {
          print('Failed to load user address: ${response.statusCode}');
          setAddress(Address()); // Also set to empty Address on failure
        }
      } catch (e) {
        print('Exception fetching address: $e');
        setAddress(Address()); // Set to empty Address on exception
      }
    } else {
      print('User ID is null, cannot fetch user address');
      setAddress(Address()); // Set to empty Address if user ID is null
    }
  }
}

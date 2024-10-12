import 'package:flutter/cupertino.dart';
import '../model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import '../model/address.dart'; // Import your Address model if it's in a separate file


class AuthViewModel extends ChangeNotifier {
  User? _user;
  Address? _address; // Add this line to hold the address

  User? get user => _user;
  Address? get address => _address; // Create a getter for the address

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

    // Assuming you have these variables for user state
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

  void updateUser({required String name, required String phone, required String email}) {
    if (_user != null) {
      _user = _user!.copyWith(name: name, phone: phone, email: email);
      notifyListeners();
    }
  }

    void updateAddress({required String province, required String municipality, required String barangay, required String zip, required String street}) {
    if (_user != null) {
      _user = _user!.copyWith(province: province, municipality: municipality, barangay: barangay, zip: zip, street:street);
      notifyListeners();
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
          setUser(User.fromJson(data)); // Ensure that you set the user correctly
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
      }
    } catch (e) {
      print('Exception fetching address: $e');
    }
  } else {
    print('User ID is null, cannot fetch user address');
  }
}


}

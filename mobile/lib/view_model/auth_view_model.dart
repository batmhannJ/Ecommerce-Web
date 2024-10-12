import 'package:flutter/cupertino.dart';
import '../model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class AuthViewModel extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  void updateUser({required String name, required String phone, required String email}) {
    if (_user != null) {
      _user = _user!.copyWith(name: name, phone: phone, email: email);
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
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

}

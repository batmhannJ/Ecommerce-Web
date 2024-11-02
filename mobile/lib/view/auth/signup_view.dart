import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/form_styles.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/auth/forgot_password_view.dart';
import 'package:indigitech_shop/view/auth/login_view.dart';
import 'package:indigitech_shop/view/home/home_view.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:indigitech_shop/widget/form_fields/custom_text_form_field.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widget/buttons/custom_filled_button.dart';

class SignupView extends StatefulWidget {
  final VoidCallback onLogin;
  const SignupView({
    super.key,
    required this.onLogin,
  });

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _doAgreeToTerms = false;
  String _generatedOTP = '';
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> requestOTP() async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:4000/send-otp-mobile"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _emailController.text}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP sent to your email")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send OTP")),
        );
      }
    } catch (error) {
      print("Error sending OTP: $error");
    }
  }

  // Function to validate OTP
  /*bool validateOTP() {
    return _otpController.text == _generatedOTP;
  }*/

  Future<void> onSignup() async {
    final otpResponse = await http.post(
      Uri.parse("http://localhost:4000/verify-otp-mobile"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _emailController.text,
        "otp": _otpController.text,
      }),
    );

    if (otpResponse.statusCode == 200) {
      // Proceed with final signup step if OTP is valid
      final response = await http.post(
        Uri.parse("http://localhost:4000/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _nameController.text,
          "email": _emailController.text,
          "phone": _phoneController.text,
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];
        print("Signup successful! Token: $token");
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginView(
              onLogin: () {
                final authViewModel = context.read<AuthViewModel>();
                authViewModel.logins().then((_) async {
                  if (authViewModel.isLoggedIn) {
                    // Get user info from authViewModel
                    final userInfo = authViewModel
                        .user; // Assuming this is where user info is stored

                    // Store user info in SharedPreferences
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString('userId',
                        userInfo!.id); // Replace 'id' with actual field
                    await prefs.setString('userName',
                        userInfo.name); // Replace 'name' with actual field
                    await prefs.setString('userEmail',
                        userInfo.email); // Replace 'email' with actual field
                    // Add other user details as needed

                    // Redirect to HomeView after successful login
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const HomeView()),
                    );
                  }
                });
              },
              onCreateAccount: () {
                final authViewModel = context.read<AuthViewModel>();
                // Navigate to the Signup View
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SignupView(
                      onLogin: () {
                        authViewModel.logins();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
        Fluttertoast.showToast(msg: "Signup Successful. Continue to login.");
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          _errorMessage = responseData['errors'];
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
          color: AppColors.primary,
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sign Up",
                    style: AppTextStyles.headline4,
                  ),
                  const Gap(20),
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const Gap(10),
                  ],
                  CustomTextFormField(
                    controller: _nameController,
                    formStyle: AppFormStyles.authFormStyle,
                    height: 48,
                    hintText: "Your Name",
                  ),
                  const Gap(15),
                  CustomTextFormField(
                    controller: _emailController,
                    formStyle: AppFormStyles.authFormStyle,
                    height: 48,
                    hintText: "Email Address",
                  ),
                  const Gap(15),
                  CustomTextFormField(
                    controller: _phoneController,
                    formStyle: AppFormStyles.authFormStyle,
                    height: 48,
                    hintText: "Phone Number",
                  ),
                  const Gap(15),
                  CustomTextFormField(
                    obscureText: true,
                    controller: _passwordController,
                    formStyle: AppFormStyles.authFormStyle,
                    height: 48,
                    hintText: "Password",
                  ),
                  const Gap(15),
                  CustomTextFormField(
                    controller: _otpController,
                    formStyle: AppFormStyles.authFormStyle,
                    height: 48,
                    hintText: "Enter OTP",
                  ),
                  const Gap(15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordView(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.red,
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                  ),
                  const Gap(15),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          disabled: !_doAgreeToTerms,
                          isExpanded: true,
                          text: "Continue",
                          textStyle: AppTextStyles.button,
                          command: onSignup,
                          height: 48,
                          fillColor: AppColors.red,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      const Gap(10),
                      TextButton(
                        onPressed: requestOTP,
                        child: const Text("Get OTP",
                            style: TextStyle(color: AppColors.red)),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Row(
                    children: [
                      Text(
                        "Already have an account? ",
                        style: AppTextStyles.body2,
                      ),
                      TextButton(
                        onPressed: widget.onLogin,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          "Login here",
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.red,
                            fontWeight: AppFontWeights.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  CheckboxListTile(
                    activeColor: AppColors.black,
                    value: _doAgreeToTerms,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    title: Text(
                      "By continuing, I agree to the terms of use & privacy policy.",
                      style: AppTextStyles.body2,
                      overflow: TextOverflow.clip,
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _doAgreeToTerms = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

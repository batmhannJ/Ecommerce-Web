import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/form_styles.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/widget/form_fields/custom_text_form_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widget/buttons/custom_filled_button.dart';
import 'package:indigitech_shop/view/auth/otp_verification.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import '/model/user.dart'; // Adjust the path according to your project structure

class LoginView extends StatefulWidget {
  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;

  const LoginView({
    super.key,
    required this.onCreateAccount,
    required this.onLogin,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _doAgreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _validateCredentials(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:4000/login'), // Update this to match your API URL
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        // Save the token and user ID as needed
        String token = data['token'];
        String userId = data['userId'];
        print("Login successful: Token: $token, User ID: $userId");
        return true; // Credentials are valid
      } else {
        print("Login failed: ${data['errors']}");
        return false; // Invalid credentials
      }
    } else {
      print("Failed to validate credentials. Server response: ${response.body}");
      return false;
    }
  }


  Future<bool> _sendOTP(String email) async {
    final response = await http.post(
      Uri.parse('http://localhost:4000/send-otp-mobile'), // Replace with your API URL
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      print("OTP sent: ${json.decode(response.body)['otp']}"); // For testing purposes
      return true;
    } else {
      print("Failed to send OTP. Server response: ${response.body}");
      return false;
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
                  Text("Login", style: AppTextStyles.headline4),
                  const Gap(20),
                  CustomTextFormField(
                    controller: _emailController,
                    formStyle: AppFormStyles.authFormStyle,
                    height: 48,
                    hintText: "Email Address",
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
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          disabled: !_doAgreeToTerms,
                          isExpanded: true,
                          text: "Continue",
                          textStyle: AppTextStyles.button,
                          command: () async {
                            String email = _emailController.text;
                            String password = _passwordController.text;

                            if (email.isNotEmpty && password.isNotEmpty) {
                              // Call your login API to validate credentials
                              final response = await http.post(
                                Uri.parse('http://localhost:4000/login'), // Your API URL for login
                                headers: {
                                  'Content-Type': 'application/json',
                                },
                                body: json.encode({'email': email, 'password': password}),
                              );

                              if (response.statusCode == 200) {
                                final data = json.decode(response.body);

                                if (data['success']) {
                                  // Now send OTP after successful login
                                  bool otpSent = await _sendOTP(email);
                                  
                                  if (otpSent) {
                                    // Navigate to OTP Verification Screen if OTP is sent
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OTPVerificationScreen(
                                          email: email,
                                          onOTPVerified: widget.onLogin, // Proceed to login after OTP verification
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Handle failure to send OTP
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Failed to send OTP. Please try again.")),
                                    );
                                  }
                                } else {
                                  // Handle login error (e.g., wrong email or password)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(data['errors'])),
                                  );
                                }
                              } else {
                                // Handle server error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Failed to log in. Please try again.")),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please enter both email and password.")),
                              );
                            }
                          },
                          height: 48,
                          fillColor: AppColors.red,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Row(
                    children: [
                      Text("Create an account? ", style: AppTextStyles.body2),
                      TextButton(
                        onPressed: widget.onCreateAccount,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          "Click here",
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.red,
                            fontWeight: AppFontWeights.bold,
                          ),
                        ),
                      )
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
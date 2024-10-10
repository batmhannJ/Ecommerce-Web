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

  Future<bool> _sendOTP(String email) async {
  final response = await http.post(
    Uri.parse('http://localhost:4000/send-otp-mobile'), // Replace with your API URL
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    print("OTP sent: ${json.decode(response.body)['otp']}"); // For testing purposes
    return true;
  } else {
    print("Failed to send OTP. Server response: ${response.body}");
    return false;
  }
}


Future<bool> _verifyOTP(String email, String otp) async {
  final response = await http.post(
    Uri.parse('http://localhost:4000/verify-otp-mobile'), // Replace with your API URL
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'email': email,
      'otp': otp,
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
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
                  Text(
                    "Login",
                    style: AppTextStyles.headline4,
                  ),
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
                              
                              if (email.isNotEmpty) {
                                bool otpSent = await _sendOTP(email);
                                if (otpSent) {
                                  // Navigate to OTP Verification Screen
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
                                  // Handle OTP sending failure (show error, etc.)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Failed to send OTP. Please try again.")),
                                  );
                                }
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
                      Text(
                        "Create an account? ",
                        style: AppTextStyles.body2,
                      ),
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
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

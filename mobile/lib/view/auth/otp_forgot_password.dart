// otp_verification_view.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/form_styles.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/widget/form_fields/custom_text_form_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OTPForgotPasswordView extends StatefulWidget {
  final String email;

  OTPForgotPasswordView({required this.email});

  @override
  _OTPVerificationViewState createState() => _OTPVerificationViewState();
}

class _OTPVerificationViewState extends State<OTPForgotPasswordView> {
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _resetPassword() async {
    String otp = _otpController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (otp.isNotEmpty &&
        newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (newPassword == confirmPassword) {
        final response = await http.post(
          Uri.parse(
              'http://localhost:4000/reset-password'), // Update to your API URL
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': widget.email,
            'otp': otp,
            'newPassword': newPassword,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password reset successfully.")),
          );
          Navigator.popUntil(
              context, (route) => route.isFirst); // Go back to login
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid OTP or reset failed.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify OTP"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Verify OTP and Reset Password",
                style: AppTextStyles.headline4),
            const Gap(20),
            CustomTextFormField(
              controller: _otpController,
              formStyle: AppFormStyles.authFormStyle,
              height: 48,
              hintText: "OTP",
            ),
            const Gap(20),
            CustomTextFormField(
              controller: _newPasswordController,
              formStyle: AppFormStyles.authFormStyle,
              height: 48,
              hintText: "New Password",
              obscureText: true,
            ),
            const Gap(20),
            CustomTextFormField(
              controller: _confirmPasswordController,
              formStyle: AppFormStyles.authFormStyle,
              height: 48,
              hintText: "Confirm Password",
              obscureText: true,
            ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text("Reset Password", style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
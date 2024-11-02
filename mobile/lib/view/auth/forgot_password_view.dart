// forgot_password_view.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/form_styles.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/widget/form_fields/custom_text_form_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordView extends StatefulWidget {
  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    String email = _emailController.text;
    if (email.isNotEmpty) {
      final response = await http.post(
        Uri.parse(
            'http://localhost:4000/forgot-password'), // Update to your API URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Password reset link sent to your email.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to send reset link. Please try again.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email address.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Reset Your Password", style: AppTextStyles.headline4),
            const Gap(20),
            Text(
              "Enter your email address below and we’ll send you a link to reset your password.",
              style: AppTextStyles.body1,
            ),
            const Gap(20),
            CustomTextFormField(
              controller: _emailController,
              formStyle: AppFormStyles.authFormStyle,
              height: 48,
              hintText: "Email Address",
            ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _requestPasswordReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "Send Reset Link",
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

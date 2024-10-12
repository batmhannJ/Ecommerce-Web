import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/form_styles.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/widget/form_fields/custom_text_form_field.dart';

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

  bool _doAgreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                          command: () {},
                          height: 48,
                          fillColor: AppColors.red,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
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

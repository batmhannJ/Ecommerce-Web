import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/layout/default_view_layout.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import '../core/style/form_styles.dart';
import '../widget/buttons/custom_filled_button.dart';
import '../widget/form_fields/custom_text_form_field.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultViewLayout(
      title: "Change Password",
      content: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Change Password",
                style: AppTextStyles.subtitle2.copyWith(color: AppColors.darkGrey),
              ),
              const Gap(20),
              CustomTextFormField(
                controller: _oldPasswordController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 48,
                hintText: "Old Password",
                obscureText: true,
              ),
              const Gap(20),
              CustomTextFormField(
                controller: _newPasswordController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 48,
                hintText: "New Password",
                obscureText: true,
              ),
              const Gap(20),
              CustomTextFormField(
                controller: _confirmPasswordController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 48,
                hintText: "Confirm New Password",
                obscureText: true,
              ),
              const Gap(30),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      disabled: _oldPasswordController.text.isEmpty ||
                          _newPasswordController.text.isEmpty ||
                          _confirmPasswordController.text.isEmpty ||
                          (_newPasswordController.text != _confirmPasswordController.text),
                      isExpanded: true,
                      text: "Change Password",
                      textStyle: AppTextStyles.button,
                      command: () {
                        // Call your change password method in AuthViewModel
                        context.read<AuthViewModel>().changePassword(
                          oldPassword: _oldPasswordController.text,
                          newPassword: _newPasswordController.text,
                        );
                        Navigator.of(context).pop();
                      },
                      height: 48,
                      fillColor: AppColors.black,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

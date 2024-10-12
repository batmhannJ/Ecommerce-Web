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

class AccountSettingsView extends StatefulWidget {
  const AccountSettingsView({super.key});

  @override
  State<AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? currentName;
  String? currentPhone;
  String? currentEmail;

  @override
  void initState() {
    super.initState();
    
    final authViewModel = context.read<AuthViewModel>();

    authViewModel.fetchUserDetails().then((_) {
      setState(() {
        final currentUser = authViewModel.user;

        _nameController.text = currentUser?.name ?? ''; // Safe handling of null
        _phoneController.text = currentUser?.phone ?? ''; // Safe handling of null
        _emailController.text = currentUser?.email ?? ''; // Safe handling of null

        print('Name: ${currentUser?.name}');
        print('Phone: ${currentUser?.phone}');
        print('Email: ${currentUser?.email}');
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultViewLayout(
      title: "Account Settings",
      content: Form(
        onChanged: () {
          setState(() {
            currentName = _nameController.text;
            currentPhone = _phoneController.text;
            currentEmail = _emailController.text;
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Personal Information",
                style: AppTextStyles.subtitle2.copyWith(color: AppColors.darkGrey),
              ),
              const Gap(10),
              CustomTextFormField(
                controller: _nameController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 48,
                hintText: "Your Name",
              ),
              const Gap(20),
              CustomTextFormField(
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 48,
                hintText: "Phone or Mobile",
              ),
              const Gap(20),
              CustomTextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 48,
                hintText: "Email",
              ),
              const Gap(30),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      disabled: _nameController.text.isEmpty ||
                          _phoneController.text.isEmpty ||
                          _emailController.text.isEmpty,
                      isExpanded: true,
                      text: "Update",
                      textStyle: AppTextStyles.button,
                      command: () {
                        // Update user details via AuthViewModel
                        context.read<AuthViewModel>().updateUser(
                          name: _nameController.text,
                          phone: _phoneController.text,
                          email: _emailController.text,
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

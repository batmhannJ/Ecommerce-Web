import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/dummy.dart';
import 'package:indigitech_shop/model/address.dart';
import 'package:indigitech_shop/view/layout/default_view_layout.dart';
import 'package:indigitech_shop/view_model/address_view_model.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

import '../core/style/form_styles.dart';
import '../widget/buttons/custom_filled_button.dart';
import '../widget/form_fields/custom_text_form_field.dart';
import '../widget/dropdown.dart';
import '../model/user.dart';

class AddressView extends StatefulWidget {
  const AddressView({super.key});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _zipController = TextEditingController();
  final _streetController = TextEditingController();
  final _provinceController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _barangayController = TextEditingController();

  String? currentName;
  String? currentPhone;
  String? currentBarangay;
  String? currentStreet;
  String? currentMunicipality;
  String? currentProvince;
  String? currentRegion;
  String? currentZip;

 @override
void initState() {
  super.initState();
  final authViewModel = context.read<AuthViewModel>();

  // Fetch user details first
  authViewModel.fetchUserDetails().then((_) {
    setState(() {
      final currentUser = authViewModel.user;
      _fullNameController.text = currentUser?.name ?? ''; // Safe handling of null
      _phoneNumberController.text = currentUser?.phone ?? ''; // Safe handling of null

      print('User Name: ${currentUser?.name}');
      print('User Phone: ${currentUser?.phone}');
    });

    // Now fetch user address
    authViewModel.fetchUserAddress().then((_) {
      setState(() {
        final currentAddress = authViewModel.address; // Use currentAddress for clarity
        _provinceController.text = currentAddress?.province ?? ''; // Safe handling of null
        _municipalityController.text = currentAddress?.municipality ?? ''; // Safe handling of null
        _barangayController.text = currentAddress?.barangay ?? ''; // Safe handling of null
        _zipController.text = currentAddress?.zip ?? ''; // Safe handling of null
        _streetController.text = currentAddress?.street ?? ''; // Safe handling of null

        print('Address Province: ${currentAddress?.province}');
        print('Address Municipality: ${currentAddress?.municipality}');
        print('Address Barangay: ${currentAddress?.barangay}');
        print('Address Zip: ${currentAddress?.zip}');
        print('Address Street: ${currentAddress?.street}');
      });
    }).catchError((error) {
      print('Error fetching address: $error');
    });
  }).catchError((error) {
    print('Error fetching user details: $error');
  });
}

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _provinceController.dispose();
    _municipalityController.dispose();
    _barangayController.dispose();
    _zipController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultViewLayout(
      title: "Address",
      content: Form(
        onChanged: () {
           setState(() {
            currentName = _fullNameController.text;
            currentPhone = _phoneNumberController.text;
            currentProvince = _provinceController.text;
            currentMunicipality = _municipalityController.text;
            currentBarangay = _barangayController.text;
            currentZip = _zipController.text;
            currentStreet = _streetController.text;
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contact",
                style:
                    AppTextStyles.subtitle2.copyWith(color: AppColors.darkGrey),
              ),
              const Gap(5),
              CustomTextFormField(
                controller: _fullNameController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 36,
                hintText: "Full Name",
              ),
              const Gap(10),
              CustomTextFormField(
                keyboardType: TextInputType.phone,
                controller: _phoneNumberController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 36,
                hintText: "Phone Number",
              ),
              const Gap(15),
              Text(
                "Address",
                style:
                    AppTextStyles.subtitle2.copyWith(color: AppColors.darkGrey),
              ),
              const Gap(10),
              CustomTextFormField(
                controller: _provinceController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 36,
                hintText: "Province",
              ),
              const Gap(10),
              CustomTextFormField(
                controller: _municipalityController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 36,
                hintText: "City",
              ),
              const Gap(10),
              CustomTextFormField(
                controller: _barangayController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 36,
                hintText: "Barangay",
              ),
              const Gap(10),
             CustomTextFormField(
                controller: _zipController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 36,
                hintText: "Zip Code",
              ),
              const Gap(10),
              CustomTextFormField(
                controller: _streetController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 36,
                hintText: "Street Name, Building, House No.",
              ),
              const Gap(25),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      disabled: _fullNameController.text.isEmpty ||
                          _phoneNumberController.text.isEmpty ||
                          _provinceController.text.isEmpty ||
                          _municipalityController.text.isEmpty ||
                          _barangayController.text.isEmpty ||
                          _zipController.text.isEmpty ||
                          _streetController.text.isEmpty,
                      isExpanded: true,
                      text: "Update",
                      textStyle: AppTextStyles.button,
                       command: () {
                        // Update user details via AuthViewModel
                        context.read<AuthViewModel>().updateAddress(
                          province: _fullNameController.text,
                          municipality: _phoneNumberController.text,
                          barangay: _barangayController.text,
                          zip: _zipController.text,
                          street: _streetController.text,
                        );
                        Navigator.of(context).pop();
                      },
                      height: 48,
                      fillColor: AppColors.black,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
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

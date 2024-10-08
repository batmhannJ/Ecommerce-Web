import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/dummy.dart';
import 'package:indigitech_shop/model/address.dart';
import 'package:indigitech_shop/view/layout/default_view_layout.dart';
import 'package:indigitech_shop/view_model/address_view_model.dart';
import 'package:indigitech_shop/widget/dropdown.dart';
import 'package:provider/provider.dart';

import '../core/style/form_styles.dart';
import '../widget/buttons/custom_filled_button.dart';
import '../widget/form_fields/custom_text_form_field.dart';

class AddressView extends StatefulWidget {
  const AddressView({super.key});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _provinceFormFieldKey = GlobalKey<FormFieldState>();
  final _cityFormFieldKey = GlobalKey<FormFieldState>();
  final _barangayFormFieldKey = GlobalKey<FormFieldState>();

  late Address currentAddress;
  late Address updatedAddress;

  @override
  void initState() {
    updatedAddress = currentAddress =
        context.read<AddressViewModel>().address ?? Address.empty();

    super.initState();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _postalCodeController.dispose();
    _line1Controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultViewLayout(
      title: "Address",
      content: Form(
        onChanged: () {
          setState(() {
            updatedAddress = Address(
              fullName: _fullNameController.text,
              phoneNumber: _phoneNumberController.text,
              province: _provinceFormFieldKey.currentState!.value,
              city: _cityFormFieldKey.currentState!.value,
              barangay: _barangayFormFieldKey.currentState!.value,
              postalCode: _postalCodeController.text,
              line1: _line1Controller.text,
            );
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
                initialValue: currentAddress.fullName,
              ),
              const Gap(10),
              CustomTextFormField(
                keyboardType: TextInputType.phone,
                controller: _phoneNumberController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 36,
                hintText: "Phone Number",
                initialValue: currentAddress.phoneNumber,
              ),
              const Gap(15),
              Text(
                "Address",
                style:
                    AppTextStyles.subtitle2.copyWith(color: AppColors.darkGrey),
              ),
              const Gap(10),
              CustomDropdown<String>(
                formFieldKey: _provinceFormFieldKey,
                hint: "Province",
                initialValue: currentAddress.province.isEmpty
                    ? null
                    : currentAddress.province,
                items: dummyProvince,
              ),
              const Gap(10),
              CustomDropdown<String>(
                formFieldKey: _cityFormFieldKey,
                hint: "City",
                initialValue:
                    currentAddress.city.isEmpty ? null : currentAddress.city,
                items: dummyCity,
              ),
              const Gap(10),
              CustomDropdown<String>(
                formFieldKey: _barangayFormFieldKey,
                hint: "Barangay",
                initialValue: currentAddress.barangay.isEmpty
                    ? null
                    : currentAddress.barangay,
                items: dummyBarangay,
              ),
              const Gap(10),
              CustomTextFormField(
                keyboardType: TextInputType.number,
                controller: _postalCodeController,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 36,
                hintText: "Postal Code",
                initialValue: currentAddress.postalCode,
              ),
              const Gap(10),
              CustomTextFormField(
                controller: _line1Controller,
                formStyle: AppFormStyles.defaultFormStyle,
                height: 36,
                hintText: "Street Name, Building, House No.",
                initialValue: currentAddress.line1,
              ),
              const Gap(25),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      disabled: currentAddress.isEqual(updatedAddress) ||
                          updatedAddress.isIncomplete(),
                      isExpanded: true,
                      text: "Submit",
                      textStyle: AppTextStyles.button,
                      command: () {
                        context
                            .read<AddressViewModel>()
                            .updateAddress(updatedAddress);

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

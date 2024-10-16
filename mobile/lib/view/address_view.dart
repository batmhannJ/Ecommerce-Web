import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/layout/default_view_layout.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:indigitech_shop/services/address_service.dart'; // Update with your actual project name
import '../core/style/form_styles.dart';
import '../widget/buttons/custom_filled_button.dart';
import '../widget/form_fields/custom_text_form_field.dart';

class AddressView extends StatefulWidget {
  const AddressView({super.key});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  final AddressService _addressService = AddressService('https://isaacdarcilla.github.io/philippine-addresses');
  List<dynamic> regions = [];
  List<dynamic> provinces = [];
  List<dynamic> cities = [];
  List<dynamic> barangays = [];
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _zipController = TextEditingController();
  final _streetController = TextEditingController();
  final _provinceController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _barangayController = TextEditingController();
  final _regionController = TextEditingController();

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
  fetchAddressDetails();

  final authViewModel = context.read<AuthViewModel>();

  // Fetch user details first
  authViewModel.fetchUserDetails().then((_) {
    setState(() {
      final currentUser = authViewModel.user;
      _fullNameController.text = currentUser?.name ?? ''; // Safe handling of null
      _phoneNumberController.text = currentUser?.phone ?? ''; // Safe handling of null
      _emailController.text = currentUser?.email ?? ''; // Safe handling of null

      print('User Name: ${currentUser?.name}');
      print('User Phone: ${currentUser?.phone}');
      print('User Email: ${currentUser?.email}');
    });

    // Now fetch user address
    authViewModel.fetchUserAddress().then((_) {  
      final currentAddress = authViewModel.address; // Use currentAddress for clarity
     setState(() {
          _zipController.text = currentAddress?.zip ?? '';
          _streetController.text = currentAddress?.street ?? '';
          setAddressCodes(currentAddress);
          setAddressNames(currentAddress); // Get names after setting codes
        });

    }).catchError((error) {
      print('Error fetching address: $error');
    });
  }).catchError((error) {
    print('Error fetching user details: $error');
  });
}

Future<void> fetchAddressDetails() async {
  try {
    // Fetch regions
    regions = await _addressService.regions();
    print("Regions: $regions");

    // Get the first region's code
    if (regions.isNotEmpty) {
      String regionCode = regions[0]['region_code'];

      // Fetch provinces by region code
      provinces = await _addressService.provinces(regionCode);
      print("Provinces: $provinces");

      if (provinces.isNotEmpty) {
        String provinceCode = provinces[0]['province_code'];

        // Fetch cities by province code
        cities = await _addressService.cities(provinceCode);
        print("Cities: $cities");

        if (cities.isNotEmpty) {
          String cityCode = cities[0]['city_code'];

          // Fetch barangays by city code
          barangays = await _addressService.barangays(cityCode);
          print("Barangays: $barangays");
        }
      }
    }
  } catch (error) {
    print("Error fetching address details: $error");
  }
}


  void setAddressCodes(dynamic currentAddress) {
    if (currentAddress != null) {
      _regionController.text = currentAddress.region ?? '';
      _provinceController.text = currentAddress.province ?? '';
      _municipalityController.text = currentAddress.municipality ?? '';
      _barangayController.text = currentAddress.barangay ?? '';
    }
  }

void setAddressNames(dynamic currentAddress) {
  if (currentAddress != null) {
    print("Current Address: $currentAddress");

    // Retrieve region name
    currentRegion = regions.firstWhere(
      (r) => r['region_code'] == currentAddress.region,
      orElse: () {
        print('Region not found for code: ${currentAddress.region}');
        return {'region_name': ''};  // Return empty string instead of unknown
      },
    )['region_name'];

    print("Retrieved Region: $currentRegion");

    // Validate and retrieve province name
    currentProvince = provinces.firstWhere(
      (p) => p['province_code'] == currentAddress.province,
      orElse: () {
        print('Province not found for code: ${currentAddress.province}');
        return {'province_name': ''};  // Return empty string instead of unknown
      },
    )['province_name'];

    print("Retrieved Province: $currentProvince");

    // Validate and retrieve municipality name
    currentMunicipality = cities.firstWhere(
      (m) => m['municipality_code'] == currentAddress.municipality,
      orElse: () {
        print('Municipality not found for code: ${currentAddress.municipality}');
        return {'municipality_name': ''};  // Return empty string instead of unknown
      },
    )['municipality_name'];

    print("Retrieved Municipality: $currentMunicipality");

    // Validate and retrieve barangay name
    currentBarangay = barangays.firstWhere(
      (b) => b['barangay_code'] == currentAddress.barangay,
      orElse: () {
        print('Barangay not found for code: ${currentAddress.barangay}');
        return {'barangay_name': ''};  // Return empty string instead of unknown
      },
    )['barangay_name'];

    print("Retrieved Barangay: $currentBarangay");

    // Update the text controllers with names
    setState(() {
      _regionController.text = currentRegion ?? ''; 
      _provinceController.text = currentProvince ?? '';
      _municipalityController.text = currentMunicipality ?? '';
      _barangayController.text = currentBarangay ?? '';
    });

    printAddressDetails();
  } else {
    print('Current Address is null');
  }
}


  void printAddressDetails() {
    print("Region Name: $currentRegion");
    print("Province Name: $currentProvince");
    print("Municipality Name: $currentMunicipality");
    print("Barangay Name: $currentBarangay");
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _provinceController.dispose();
    _municipalityController.dispose();
    _barangayController.dispose();
    _regionController.dispose(); // Dispose the region controller
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
            currentRegion = _regionController.text;
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
                controller: _regionController, // Region input
                formStyle: AppFormStyles.defaultFormStyle,
                height: 36,
                hintText: "Region",
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
                         context.read<AuthViewModel>().updateUser(
                          name: _fullNameController.text,
                          phone: _phoneNumberController.text,
                          email: _emailController.text, // Use the email from the controller
                          context: context,
                        );
                        context.read<AuthViewModel>().updateAddress(
                          province: _provinceController.text,  // Corrected to use the province controller
                          municipality: _municipalityController.text, 
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

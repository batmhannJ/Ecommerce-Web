import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/layout/default_view_layout.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:indigitech_shop/services/address_service.dart';
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

  String? selectedRegion;
  String? selectedProvince;
  String? selectedCity;
  String? selectedBarangay;

  @override
  void initState() {
    super.initState();
    fetchAddressDetails();
  }

  Future<void> fetchAddressDetails() async {
    try {
      regions = await _addressService.regions();
      if (regions.isNotEmpty) {
        setState(() {
          selectedRegion = regions[0]['region_code'];
        });
        await fetchProvinces(selectedRegion!);
      }

      // Load existing user address details
      final userAddress = context.read<AuthViewModel>().address;

        if (userAddress != null) {
          // Access the properties of the user address
          String fullName = userAddress.fullName;
          String phoneNumber = userAddress.phoneNumber;
          String province = userAddress.province;
          String municipality = userAddress.municipality; // Use municipality if that's how it's defined
          String barangay = userAddress.barangay;
          String zip = userAddress.zip;
          String street = userAddress.street;

        // Fetch provinces, cities, and barangays based on the existing address
        if (selectedProvince != null) {
          await fetchProvinces(selectedRegion!);
        }
        if (selectedCity != null) {
          await fetchCities(selectedProvince!);
        }
        if (selectedBarangay != null) {
          await fetchBarangays(selectedCity!);
        }
      }
    } catch (error) {
      print("Error fetching address details: $error");
    }
  }

  Future<void> fetchProvinces(String regionCode) async {
    try {
      provinces = await _addressService.provinces(regionCode);
      if (provinces.isNotEmpty) {
        setState(() {
          selectedProvince = provinces[0]['province_code'];
        });
        await fetchCities(selectedProvince!);
      }
    } catch (error) {
      print("Error fetching provinces: $error");
    }
  }

  Future<void> fetchCities(String provinceCode) async {
    try {
      cities = await _addressService.cities(provinceCode);
      if (cities.isNotEmpty) {
        setState(() {
          selectedCity = cities[0]['city_code'];
        });
        await fetchBarangays(selectedCity!);
      }
    } catch (error) {
      print("Error fetching cities: $error");
    }
  }

  Future<void> fetchBarangays(String cityCode) async {
    try {
      barangays = await _addressService.barangays(cityCode);
      setState(() {}); // Update UI after fetching barangays
    } catch (error) {
      print("Error fetching barangays: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultViewLayout(
      title: "Address",
      content: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contact", style: AppTextStyles.subtitle2.copyWith(color: AppColors.darkGrey)),
              const Gap(5),
              CustomTextFormField(controller: _fullNameController, formStyle: AppFormStyles.defaultFormStyle, height: 36, hintText: "Full Name"),
              const Gap(10),
              CustomTextFormField(keyboardType: TextInputType.phone, controller: _phoneNumberController, formStyle: AppFormStyles.defaultFormStyle, height: 36, hintText: "Phone Number"),
              const Gap(15),
              Text("Address", style: AppTextStyles.subtitle2.copyWith(color: AppColors.darkGrey)),
              const Gap(10),

              // Region Dropdown
              DropdownButtonFormField(
                value: selectedRegion,
                items: regions.isNotEmpty
                    ? regions.map((region) {
                        return DropdownMenuItem(
                          value: region['region_code'],
                          child: Text(region['region_name']),
                        );
                      }).toList()
                    : [DropdownMenuItem(child: Text('No regions available'))],
                onChanged: (value) {
                  setState(() {
                    selectedRegion = value as String?;
                    fetchProvinces(selectedRegion!);
                  });
                },
                decoration: InputDecoration(hintText: "Select Region"),
              ),
              const Gap(10),

              // Province Dropdown
              DropdownButtonFormField(
                value: selectedProvince,
                items: provinces.isNotEmpty
                    ? provinces.map((province) {
                        return DropdownMenuItem(
                          value: province['province_code'],
                          child: Text(province['province_name']),
                        );
                      }).toList()
                    : [DropdownMenuItem(child: Text('No provinces available'))],
                onChanged: (value) {
                  setState(() {
                    selectedProvince = value as String?;
                    fetchCities(selectedProvince!);
                  });
                },
                decoration: InputDecoration(hintText: "Select Province"),
              ),
              const Gap(10),

              // City Dropdown
              DropdownButtonFormField(
                value: selectedCity,
                items: cities.isNotEmpty
                    ? cities.map((city) {
                        return DropdownMenuItem(
                          value: city['city_code'],
                          child: Text(city['city_name']),
                        );
                      }).toList()
                    : [DropdownMenuItem(child: Text('No cities available'))],
                onChanged: (value) {
                  setState(() {
                    selectedCity = value as String?;
                    fetchBarangays(selectedCity!);
                  });
                },
                decoration: InputDecoration(hintText: "Select City"),
              ),
              const Gap(10),

              // Barangay Dropdown
              DropdownButtonFormField(
                value: selectedBarangay,
                items: barangays.isNotEmpty
                    ? barangays.map((barangay) {
                        return DropdownMenuItem(
                          value: barangay['brgy_code'],
                          child: Text(barangay['brgy_name']),
                        );
                      }).toList()
                    : [DropdownMenuItem(child: Text('No barangays available'))],
                onChanged: (value) {
                  setState(() {
                    selectedBarangay = value as String?;
                  });
                },
                decoration: InputDecoration(hintText: "Select Barangay"),
              ),
              const Gap(10),

              // Zip Code and Street
              CustomTextFormField(controller: _zipController, formStyle: AppFormStyles.defaultFormStyle, height: 36, hintText: "Zip Code"),
              const Gap(10),
              CustomTextFormField(controller: _streetController, formStyle: AppFormStyles.defaultFormStyle, height: 36, hintText: "Street Name, Building, House No."),
              const Gap(25),

              // Update Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Check if all required fields are filled before proceeding
                  if (_fullNameController.text.isNotEmpty &&
                      _phoneNumberController.text.isNotEmpty &&
                      selectedProvince != null &&
                      selectedCity != null &&
                      selectedBarangay != null &&
                      _zipController.text.isNotEmpty &&
                      _streetController.text.isNotEmpty) {
                    
                    // Update user details
                    context.read<AuthViewModel>().updateUser(
                      name: _fullNameController.text,
                      phone: _phoneNumberController.text,
                      email: _emailController.text,
                      context: context,
                    );

                                // Update address details
                  context.read<AuthViewModel>().updateAddress(
                    fullName: _fullNameController.text, // Full name
                    phoneNumber: _phoneNumberController.text, // Phone number
                    province: selectedProvince ?? '', // Ensure province is a non-null value
                    municipality: selectedCity ?? '', // Ensure city is a non-null value
                    barangay: selectedBarangay ?? '', // Ensure barangay is a non-null value
                    zip: _zipController.text, // Zip code
                    street: _streetController.text, // Street address
                  );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Address Updated Successfully")),
                    );
                  } else {
                    // Show an error message if required fields are missing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all required fields")),
                    );
                  }
                },
                child: const Text("Update Address"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  final AddressService _addressService =
      AddressService('https://isaacdarcilla.github.io/philippine-addresses');

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
    final authViewModel = context.read<AuthViewModel>();

    // Fetch and display user details
    authViewModel.fetchUserDetails().then((_) {
      setState(() {
        final currentUser = authViewModel.user;

        _fullNameController.text = currentUser?.name ?? ''; // Safe handling of null
        _phoneNumberController.text = currentUser?.phone ?? ''; // Safe handling of null
        _emailController.text = currentUser?.email ?? ''; // Safe handling of null

        print('Name: ${currentUser?.name}');
        print('Phone: ${currentUser?.phone}');
        print('Email: ${currentUser?.email}');
      });
    });

    // Fetch and display user address
    authViewModel.fetchUserAddress().then((_) {
      setState(() {
        final userAddress = authViewModel.address;

        _streetController.text = userAddress?.street ?? ''; // Safe handling of null
        _zipController.text = userAddress?.zip ?? ''; // Safe handling of null

        // Update drop-downs for region, province, city, and barangay
        selectedRegion = userAddress?.region;
        selectedProvince = userAddress?.province;
        selectedCity = userAddress?.municipality;
        selectedBarangay = userAddress?.barangay;

        // Fetch corresponding provinces, cities, and barangays based on address
        if (selectedRegion != null) {
          fetchProvinces(selectedRegion!);
        }
        if (selectedProvince != null) {
          fetchCities(selectedProvince!);
        }
        if (selectedCity != null) {
          fetchBarangays(selectedCity!);
        }
      });
    });

    // Fetch regions initially
    fetchRegions();
  }

  Future<void> fetchRegions() async {
    try {
      regions = await _addressService.regions();
      if (regions.isNotEmpty) {
        setState(() {
          selectedRegion = regions[0]['region_code'];
        });
        await fetchProvinces(selectedRegion!);
      }
    } catch (error) {
      print("Error fetching regions: $error");
    }
  }

 Future<void> fetchProvinces(String regionCode) async {
  try {
    List<dynamic> fetchedProvinces = await _addressService.provinces(regionCode);
    setState(() {
      provinces = fetchedProvinces;
      if (provinces.isNotEmpty) {
        selectedProvince = provinces[0]['province_code']; // Ensure this matches what dropdown expects
        fetchCities(selectedProvince!);
      } else {
        selectedProvince = null; // Reset selected province if empty
        cities = []; // Clear cities if no provinces fetched
        selectedCity = null; // Reset selected city
        barangays = []; // Clear barangays
        selectedBarangay = null; // Reset selected barangay
      }
    });
  } catch (error) {
    print("Error fetching provinces: $error");
    // Handle error state or retry logic if necessary
  }
}

Future<void> fetchCities(String provinceCode) async {
  try {
    List<dynamic> fetchedCities = await _addressService.cities(provinceCode);
    setState(() {
      cities = fetchedCities;
      if (cities.isNotEmpty) {
        selectedCity = cities[0]['city_code']; // Ensure this matches what dropdown expects
        fetchBarangays(selectedCity!);
      }
    });
  } catch (error) {
    print("Error fetching cities: $error");
    // Handle error state or retry logic if necessary
  }
}
  Future<void> fetchBarangays(String cityCode) async {
    try {
      List<dynamic> fetchedBarangays = await _addressService.barangays(cityCode);
      setState(() {
        barangays = fetchedBarangays;
      });
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
              CustomTextFormField(
                  controller: _fullNameController,
                  formStyle: AppFormStyles.defaultFormStyle,
                  height: 36,
                  hintText: "Full Name"),
              const Gap(10),
              CustomTextFormField(
                  keyboardType: TextInputType.phone,
                  controller: _phoneNumberController,
                  formStyle: AppFormStyles.defaultFormStyle,
                  height: 36,
                  hintText: "Phone Number"),
              const Gap(15),
              Text("Address", style: AppTextStyles.subtitle2.copyWith(color: AppColors.darkGrey)),
              const Gap(10),

              // Region Dropdown
             // Region Dropdown
DropdownButtonFormField(
  value: selectedRegion,
  items: regions.map((region) {
    return DropdownMenuItem(
      value: region['region_code'],
      child: Text(region['region_name']),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedRegion = value as String?;
      fetchProvinces(selectedRegion!);
    });
  },
  decoration: const InputDecoration(hintText: "Select Region"),
),

DropdownButtonFormField(
  value: selectedProvince,
  items: provinces.map((province) {
    return DropdownMenuItem(
      value: province['province_code'],
      child: Text(province['province_name']),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedProvince = value as String?;
      fetchCities(selectedProvince!); // Fetch cities based on selected province
    });
  },
  decoration: const InputDecoration(hintText: "Select Province"),
),
// City Dropdown
DropdownButtonFormField(
  value: selectedCity,
  items: cities.map((city) {
    return DropdownMenuItem(
      value: city['city_code'],
      child: Text(city['city_name']),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedCity = value as String?;
      fetchBarangays(selectedCity!); // Fetch barangays based on selected city
    });
  },
  decoration: const InputDecoration(hintText: "Select City"),
),

// Barangay Dropdown
DropdownButtonFormField(
  value: selectedBarangay,
  items: barangays.map((barangay) {
    return DropdownMenuItem(
      value: barangay['brgy_code'],
      child: Text(barangay['brgy_name']),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedBarangay = value as String?;
    });
  },
  decoration: const InputDecoration(hintText: "Select Barangay"),
),

              const Gap(10),

              // Zip Code and Street
              CustomTextFormField(
                  controller: _zipController,
                  formStyle: AppFormStyles.defaultFormStyle,
                  height: 36,
                  hintText: "Zip Code"),
              const Gap(10),
              CustomTextFormField(
                  controller: _streetController,
                  formStyle: AppFormStyles.defaultFormStyle,
                  height: 36,
                  hintText: "Street Name, Building, House No."),
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

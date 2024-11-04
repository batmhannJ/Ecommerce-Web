import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/model/product.dart';
import 'package:indigitech_shop/view/checkout_view.dart';
import 'package:indigitech_shop/view/layout/default_view_layout.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:indigitech_shop/view_model/cart_view_model.dart';
import 'package:provider/provider.dart';
import 'package:indigitech_shop/services/address_service.dart';
import '../core/style/form_styles.dart';
import '../widget/buttons/custom_filled_button.dart';
import '../widget/form_fields/custom_text_form_field.dart';
import 'package:indigitech_shop/view/cart_view.dart'; // Import your AddressView

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
  bool isLoading = true;
  bool hasError = false;
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
    loadUserData();
    fetchRegions();
  }

  void loadUserData() {
    final authViewModel = context.read<AuthViewModel>();
    authViewModel.fetchUserDetails().then((_) {
      setState(() {
        final currentUser = authViewModel.user;
        _fullNameController.text = currentUser?.name ?? '';
        _phoneNumberController.text = currentUser?.phone ?? '';
        _emailController.text = currentUser?.email ?? '';
      });
    });

    authViewModel.fetchUserAddress().then((_) {
      setState(() {
        final userAddress = authViewModel.address;
        _streetController.text = userAddress?.street ?? '';
        _zipController.text = userAddress?.zip ?? '';
        selectedRegion = userAddress?.region;
        selectedProvince = userAddress?.province;
        selectedCity = userAddress?.municipality;
        selectedBarangay = userAddress?.barangay;

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
  }

  Future<void> fetchRegions() async {
    setState(() {
      isLoading = true;
      hasError = false;
      selectedRegion = null;
      selectedProvince = null;
      selectedCity = null;
      selectedBarangay = null;
      provinces.clear();
      cities.clear();
      barangays.clear(); // Reset all dropdown values
    });
    try {
      regions = await _addressService.regions();
      if (regions.isNotEmpty) {
        selectedRegion = regions[0]['region_code'];
        fetchProvinces(selectedRegion!);
      }
    } catch (error) {
      setState(() {
        hasError = true;
      });
      print("Error fetching regions: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProvinces(String regionCode) async {
    setState(() {
      isLoading = true;
      selectedProvince = null;
      provinces.clear(); // Clear previous values
      cities.clear(); // Clear related dropdowns
      barangays.clear();
      selectedCity = null;
      selectedBarangay = null;
    });
    try {
      provinces = await _addressService.provinces(regionCode);
      if (provinces.isNotEmpty) {
        selectedProvince = provinces[0]['province_code'];
        fetchCities(selectedProvince!);
      }
    } catch (error) {
      setState(() {
        hasError = true;
      });
      print("Error fetching provinces: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchCities(String provinceCode) async {
    setState(() {
      isLoading = true;
      selectedCity = null;
      cities.clear(); // Clear previous values
      barangays.clear();
      selectedBarangay = null;
    });
    try {
      cities = await _addressService.cities(provinceCode);
      if (cities.isNotEmpty) {
        selectedCity = cities[0]['city_code'];
        fetchBarangays(selectedCity!);
      }
    } catch (error) {
      setState(() {
        hasError = true;
      });
      print("Error fetching cities: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchBarangays(String cityCode) async {
    setState(() {
      isLoading = true;
      selectedBarangay = null;
      barangays.clear(); // Clear previous values
    });
    try {
      barangays = await _addressService.barangays(cityCode);
      if (barangays.isNotEmpty) {
        selectedBarangay = barangays[0]['brgy_code'];
      }
    } catch (error) {
      setState(() {
        hasError = true;
      });
      print("Error fetching barangays: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _zipController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadUserData(); // Reload data when re-entering the view
  }

  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("An error occurred while fetching data."),
            ElevatedButton(
              onPressed: () {
                fetchRegions(); // Retry fetching regions on error
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return DefaultViewLayout(
      title: "Address",
      content: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contact",
                  style: AppTextStyles.subtitle2
                      .copyWith(color: AppColors.darkGrey)),
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
              Text("Address",
                  style: AppTextStyles.subtitle2
                      .copyWith(color: AppColors.darkGrey)),
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
                    fetchCities(
                        selectedProvince!); // Fetch cities based on selected province
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
                    fetchBarangays(
                        selectedCity!); // Fetch barangays based on selected city
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
                          province: selectedProvince ??
                              '', // Ensure province is a non-null value
                          municipality: selectedCity ??
                              '', // Ensure city is a non-null value
                          barangay: selectedBarangay ??
                              '', // Ensure barangay is a non-null value
                          zip: _zipController.text, // Zip code
                          street: _streetController.text, // Street address
                        );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Address Updated Successfully")),
                    );
                  } else {
                    // Show an error message if required fields are missing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please fill all required fields")),
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

import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  final String fullName;
  final String phoneNumber; // Ensure this is defined
  final String province;
  final String municipality;
  final String barangay;
  final String zip;
  final String street;

  Address({
    this.fullName = '',
    this.phoneNumber = '', // Initialize phone number
    this.province = '',
    this.municipality = '',
    this.barangay = '',
    this.zip = '',
    this.street = '',
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '', // Ensure this key exists
      province: json['province'] ?? '',
      municipality: json['municipality'] ?? '',
      barangay: json['barangay'] ?? '',
      zip: json['zip'] ?? '',
      street: json['street'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber, // Include in JSON serialization
      'province': province,
      'municipality': municipality,
      'barangay': barangay,
      'zip': zip,
      'street': street,
    };
  }
}

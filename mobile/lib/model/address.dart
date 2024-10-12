class Address {
  final String name;
  final String phone;
  final String province;
  final String municipality;
  final String barangay;
  final String zip;
  final String street;

  Address({
    this.name = '',
    this.phone = '',
    this.province = '',
    this.municipality = '',
    this.barangay = '',
    this.zip = '',
    this.street = '',
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      province: json['province'] ?? '',
      municipality: json['municipality'] ?? '',
      barangay: json['barangay'] ?? '',
      zip: json['zip'] ?? '',
      street: json['street'] ?? '',
    );
  }
}

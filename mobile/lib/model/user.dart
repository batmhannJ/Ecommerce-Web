class User {
  final String name;
  final String phone;
  final String email;
  final String street;        // Add street
  final String barangay;      // Add barangay
  final String municipality;   // Add municipality
  final String province;       // Add province
  final String region;         // Add region
  final String zip;            // Add zip

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.street,
    required this.barangay,
    required this.municipality,
    required this.province,
    required this.region,
    required this.zip,
  });

  // Factory method to create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      street: json['street'] ?? '', // Add street
      barangay: json['barangay'] ?? '', // Add barangay
      municipality: json['municipality'] ?? '', // Add municipality
      province: json['province'] ?? '', // Add province
      region: json['region'] ?? '', // Add region
      zip: json['zip'] ?? '', // Add zip
    );
  }

  // Method to create a copy of the User object with updated properties
  User copyWith({
    String? name,
    String? phone,
    String? email,
    String? street,
    String? barangay,
    String? municipality,
    String? province,
    String? region,
    String? zip,
  }) {
    return User(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      street: street ?? this.street, // Add street
      barangay: barangay ?? this.barangay, // Add barangay
      municipality: municipality ?? this.municipality, // Add municipality
      province: province ?? this.province, // Add province
      region: region ?? this.region, // Add region
      zip: zip ?? this.zip, // Add zip
    );
  }
}

class User {
  final String name;
  final String phone;
  final String email;

    User({
    required this.name,
    required this.email,
    required this.phone,
  });

  // Factory method to create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  // Method to create a copy of the User object with updated properties
  User copyWith({String? name, String? phone, String? email}) {
    return User(
      name: name ?? this.name,   // Use the new name if provided, otherwise keep the existing one
      phone: phone ?? this.phone, // Use the new phone if provided, otherwise keep the existing one
      email: email ?? this.email, // Use the new email if provided, otherwise keep the existing one
    );
  }
}

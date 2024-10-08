import 'package:json_annotation/json_annotation.dart';
part 'address.g.dart';

@JsonSerializable()
class Address {
  final String fullName;
  final String phoneNumber;
  final String province;
  final String city;
  final String barangay;
  final String postalCode;
  final String line1;

  const Address({
    required this.fullName,
    required this.phoneNumber,
    String? province,
    String? city,
    String? barangay,
    required this.postalCode,
    required this.line1,
  })  : province = province ?? "",
        city = city ?? "",
        barangay = barangay ?? "";

  Address.empty()
      : fullName = "",
        phoneNumber = "",
        province = "",
        city = "",
        barangay = "",
        postalCode = "",
        line1 = "";

  bool isIncomplete() {
    List<String> addressDetails = [
      fullName,
      phoneNumber,
      province,
      city,
      barangay,
      postalCode,
      line1,
    ];

    return addressDetails.any((element) => element.isEmpty);
  }

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Address &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.province == province &&
        other.city == city &&
        other.barangay == barangay &&
        other.postalCode == postalCode &&
        other.line1 == line1;
  }

  @override
  int get hashCode => Object.hash(
        fullName,
        phoneNumber,
        province,
        city,
        barangay,
        postalCode,
        line1,
      );

  bool isEqual(Address other) {
    return this == other;
  }
}

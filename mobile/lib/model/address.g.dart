// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      province: json['province'] as String?,
      city: json['city'] as String?,
      barangay: json['barangay'] as String?,
      postalCode: json['postalCode'] as String,
      line1: json['line1'] as String,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'province': instance.province,
      'city': instance.city,
      'barangay': instance.barangay,
      'postalCode': instance.postalCode,
      'line1': instance.line1,
    };

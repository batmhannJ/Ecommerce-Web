import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressService {
  final String baseUrl;

  AddressService(this.baseUrl);

  Future<List<dynamic>> fetch(String jsonPathName) async {
    final response = await http.get(Uri.parse('$baseUrl/$jsonPathName.json'));

    if (response.statusCode == 200) {
      print('Fetched $jsonPathName: ${response.body}'); // Log fetched JSON
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  /// Fetch all regions
  Future<List<dynamic>> regions() async {
    try {
      final data = await fetch('region');
      return data.map((region) {
        return {
          'id': region['id'],
          'psgc_code': region['psgc_code'],
          'region_name': region['region_name'],
          'region_code': region['region_code'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching regions: $e');
    }
  }

  /// Fetch a region by its code
  Future<Map<String, dynamic>?> regionByCode(String code) async {
    try {
      final data = await fetch('region');
      return data.firstWhere((region) => region['region_code'] == code, orElse: () => null);
    } catch (e) {
      throw Exception('Error fetching region by code: $e');
    }
  }

Future<List<dynamic>> provinces(String code) async {
  try {
    final data = await fetch('province');
    print('Fetched provinces: ${jsonEncode(data)}'); // Log the fetched data

    List<dynamic> filteredProvinces = data.where((province) {
      print('Checking province: ${province['province_code']} against code: $code');
      return province['region_code'] == code; // Ensure you're filtering based on region code
    }).toList();
    
    if (filteredProvinces.isEmpty) {
      print('No provinces found for region code: $code');
    }

    return filteredProvinces.map((filtered) {
      return {
        'psgc_code': filtered['psgc_code'],
        'province_name': filtered['province_name'],
        'province_code': filtered['province_code'],
        'region_code': filtered['region_code'],
      };
    }).toList();
  } catch (e) {
    print('Error fetching provinces for code: $code');
    throw Exception('Error fetching provinces: $e');
  }
}

Future<Map<String, dynamic>?> provinceByCode(String code) async {
  try {
    final data = await fetch('province');
    print('Provinces fetched: ${jsonEncode(data)}'); // Log fetched provinces
    final province = data.firstWhere(
      (province) => province['province_code'] == code,
      orElse: () => null,
    );
    if (province == null) {
      print('Province not found for code: $code'); // Specific error logging
    }
    return province;
  } catch (e) {
    print('Error fetching province by code: $code');
    throw Exception('Error fetching province by code: $e');
  }
}


  /// Fetch all cities for a given province code
  Future<List<dynamic>> cities(String code) async {
    try {
      final data = await fetch('city');
      return data.where((city) => city['province_code'] == code).map((filtered) {
        return {
          'city_name': filtered['city_name'],
          'city_code': filtered['city_code'],
          'province_code': filtered['province_code'],
          'region_desc': filtered['region_desc'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching cities: $e');
    }
  }

  Future<Map<String, dynamic>?> citiesByCode(String code) async {
  try {
    final data = await fetch('municipality'); // Ensure this is the correct endpoint
    print('Fetched municipalities: ${jsonEncode(data)}'); // Log fetched municipalities
    return data.firstWhere((city) => city['municipality_code'] == code, orElse: () => null);
  } catch (e) {
    print('Error fetching municipality by code: $code');
    throw Exception('Error fetching municipality by code: $e');
  }
}

  /// Fetch all barangays for a given city code
  Future<List<dynamic>> barangays(String code) async {
    try {
      final data = await fetch('barangay');
      return data.where((barangay) => barangay['city_code'] == code).map((filtered) {
        return {
          'brgy_name': filtered['brgy_name'],
          'brgy_code': filtered['brgy_code'],
          'province_code': filtered['province_code'],
          'region_code': filtered['region_code'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching barangays: $e');
    }
  }

  Future<Map<String, dynamic>?> barangayByCode(String code) async {
  try {
    final data = await fetch('barangay'); // Ensure this is the correct endpoint
    print('Fetched barangays: ${jsonEncode(data)}'); // Log fetched barangays
    return data.firstWhere((barangay) => barangay['barangay_code'] == code, orElse: () => null);
  } catch (e) {
    print('Error fetching barangay by code: $code');
    throw Exception('Error fetching barangay by code: $e');
  }
}

  /// Fetch a province by its name
  Future<Map<String, dynamic>?> provinceByName(String name) async {
    try {
      final data = await fetch('province');
      return data.firstWhere((province) => province['province_name'] == name, orElse: () => null);
    } catch (e) {
      throw Exception('Error fetching province by name: $e');
    }
  }
}

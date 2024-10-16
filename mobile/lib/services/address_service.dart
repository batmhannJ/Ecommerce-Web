import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressService {
  final String baseUrl;

  AddressService(this.baseUrl);

  /// General fetch method to retrieve data from the API
  Future<List<dynamic>> fetch(String jsonPathName) async {
    final url = '$baseUrl/$jsonPathName.json';
    print('Fetching data from: $url'); // Log the URL
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Fetched $jsonPathName: ${response.body}'); // Log fetched JSON
      return jsonDecode(response.body);
    } else {
      print('Error fetching data: ${response.statusCode} - ${response.body}'); // Log error details
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
      print('Error fetching regions: $e');
      throw Exception('Error fetching regions: $e');
    }
  }

  /// Fetch a region by its code
  Future<Map<String, dynamic>?> regionByCode(String code) async {
    try {
      final data = await fetch('region');
      return data.firstWhere((region) => region['region_code'] == code, orElse: () => null);
    } catch (e) {
      print('Error fetching region by code: $e');
      throw Exception('Error fetching region by code: $e');
    }
  }

  /// Fetch all provinces for a given region code
  Future<List<dynamic>> provinces(String code) async {
    try {
      final data = await fetch('province');
      print('Fetched provinces: $data'); // Log the fetched data
      return data.where((province) => province['region_code'] == code).map((filtered) {
        return {
          'psgc_code': filtered['psgc_code'],
          'province_name': filtered['province_name'],
          'province_code': filtered['province_code'],
          'region_code': filtered['region_code'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching provinces: $e');
      throw Exception('Error fetching provinces: $e');
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
      print('Error fetching cities: $e');
      throw Exception('Error fetching cities: $e');
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
      print('Error fetching barangays: $e');
      throw Exception('Error fetching barangays: $e');
    }
  }

  /// Fetch a province by its name
  Future<Map<String, dynamic>?> provinceByName(String name) async {
    try {
      final data = await fetch('province');
      return data.firstWhere((province) => province['province_name'] == name, orElse: () => null);
    } catch (e) {
      print('Error fetching province by name: $e');
      throw Exception('Error fetching province by name: $e');
    }
  }
}

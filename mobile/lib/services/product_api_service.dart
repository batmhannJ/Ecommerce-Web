import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indigitech_shop/model/product.dart';
import 'package:indigitech_shop/core/constant/enum/product_size.dart';
import 'package:indigitech_shop/model/review.dart';

class ProductApiService {
  static const String baseUrl =
      'http://localhost:4000'; // Use your actual backend URL

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/allproducts'));

    if (response.statusCode == 200) {
      List<dynamic> productsJson = json.decode(response.body);
      return productsJson.map((json) => _parseProduct(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Product _parseProduct(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((r) => Review(
                    name: r['name'] ?? '',
                    rate: (r['rate'] ?? 0).toDouble(),
                    comment: r['comment'] ?? '',
                  ))
              .toList() ??
          [],
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((s) => ProductSize.values.firstWhere(
                    (e) => e.toString().split('.').last == s,
                    orElse: () => ProductSize.s,
                  ))
              .toList() ??
          [],
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? [])
          .map((image) => '$baseUrl/images/$image')
          .toList(),
      isNew: json['isNew'] ?? false,
      isPopular: json['isPopular'] ?? false,
    );
  }
}

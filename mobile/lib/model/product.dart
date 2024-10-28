import 'package:indigitech_shop/core/constant/enum/product_size.dart';
import 'package:indigitech_shop/model/review.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Product {
  final String name;
  final double old_price;
  final double new_price;
  final double discount;
  final String description;
  final List<Review> reviews;
  final Map<ProductSize, int> stocks; // Store stock levels per size
  final int s_stock;
  final int m_stock;
  final int l_stock;
  final int xl_stock;
  final String category;
  final List<String> tags;
  final List<String> image; // Change this to a list if you're expecting multiple images
  final bool available;
  final bool isNew;
  final double adjustedPrice; // Added to store adjusted price

  const Product({
    required this.name,
    required this.old_price,
    required this.new_price,
    required this.discount,
    required this.description,
    required this.reviews,
    required this.stocks,
    required this.s_stock,
    required this.m_stock,
    required this.xl_stock,
    required this.l_stock,
    required this.category,
    required this.tags,
    required this.image,
    required this.available,
    required this.isNew,
        required this.adjustedPrice,

  });

  double getRatingAverage() {
    double totalRate = 0;

    for (Review review in reviews) {
      totalRate += review.rate;
    }

    if (totalRate == 0) return 0;

    return totalRate / reviews.length;
  }

  double getPriceForSize(ProductSize size) {
    int sizeIndex = size.index; // s = 0, m = 1, l = 2, xl = 3
    return new_price + (sizeIndex * 100);
  }

  bool isInStock(ProductSize size) {
    return stocks[size]! > 0;
  }

  // Convert a Product object into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'old_price': old_price,
      'new_price': new_price,
      'discount': discount,
      'description': description,
      'reviews': reviews.map((review) => review.toJson()).toList(), // Assuming Review has toJson
      'stocks': stocks.map((key, value) => MapEntry(key.toString(), value)), // Convert Enum to String
      'category': category,
      's_stock': s_stock,
            'adjustedPrice': adjustedPrice,

      'm_stock': m_stock,
      'l_stock': l_stock,
      'xl_stock': xl_stock,
      'tags': tags,
      'image': image,
      'available': available,
      'isNew': isNew,
    };
  }

  // Create a Product object from a JSON map.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      old_price: json['old_price'],
      new_price: json['new_price'],
      discount: json['discount'],
      description: json['description'],
      reviews: List<Review>.from(json['reviews'].map((reviewJson) => Review.fromJson(reviewJson))), // Assuming Review has fromJson
      stocks: Map<ProductSize, int>.from(json['stocks'].map((key, value) {
        // Convert String back to Enum
        ProductSize size = ProductSize.values.firstWhere((e) => e.toString() == 'ProductSize.$key');
        return MapEntry(size, value);
      })),
      category: json['category'],
            adjustedPrice: json['adjustedPrice'],

      s_stock: json['s_stock'],
      m_stock: json['m_stock'],
      l_stock: json['l_stock'],
      xl_stock: json['xl_stock'],
      tags: List<String>.from(json['tags']),
      image: List<String>.from(json['image']),
      available: json['available'],
      isNew: json['isNew'],
    );
  }

  Product copyWith({
  String? name,
  double? new_price,
    double? adjustedPrice,

  double? old_price,
  double? discount,
  String? description,
  List<Review>? reviews,
  Map<ProductSize, int>? stocks,
      int? s_stock,
    int? m_stock,
    int? l_stock,
    int? xl_stock,
  String? category,
  List<String>? tags,
  List<String>? image,
  bool? available,
  bool? isNew,
}) {
  return Product(
    name: name ?? this.name,
        adjustedPrice: adjustedPrice ?? this.adjustedPrice,

    new_price: new_price ?? this.new_price,
    old_price: old_price ?? this.old_price,
    discount: discount ?? this.discount,
    description: description ?? this.description,
    reviews: reviews ?? this.reviews,
    stocks: stocks ?? this.stocks,
      s_stock: s_stock ?? this.s_stock,
      m_stock: m_stock ?? this.m_stock,
      l_stock: l_stock ?? this.l_stock,
      xl_stock: xl_stock ?? this.xl_stock,
    category: category ?? this.category,
    tags: tags ?? this.tags,
    image: image ?? this.image,
    available: available ?? this.available,
    isNew: isNew ?? this.isNew,
  );
}

}

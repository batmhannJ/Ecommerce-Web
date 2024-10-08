import 'package:indigitech_shop/core/constant/enum/product_size.dart';
import 'package:indigitech_shop/model/review.dart';

class Product {
  final String name;
  final double price;
  final double discount;
  final String description;
  final List<Review> reviews;
  final List<ProductSize> sizes;
  final String category;
  final List<String> tags;
  final List<String> images;
  final bool isNew;
  final bool isPopular;

  const Product({
    required this.name,
    required this.price,
    required this.discount,
    required this.description,
    required this.reviews,
    required this.sizes,
    required this.category,
    required this.tags,
    required this.images,
    required this.isNew,
    required this.isPopular,
  });

  double getRatingAverage() {
    double totalRate = 0;

    for (Review review in reviews) {
      totalRate += review.rate;
    }

    if (totalRate == 0) return 0;

    return totalRate / reviews.length;
  }
}

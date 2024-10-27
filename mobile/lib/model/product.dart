import 'package:indigitech_shop/core/constant/enum/product_size.dart';
import 'package:indigitech_shop/model/review.dart';

class Product {
  final String name;
  final double old_price;
  final double new_price;
  final double discount;
  final String description;
  final List<Review> reviews;
  final Map<ProductSize, int> stocks; // Store stock levels per size
  final String category;
  final List<String> tags;
  final List<String> image; // Change this to a list if you're expecting multiple images
  final bool available;
  final bool isNew;

  const Product({
    required this.name,
    required this.old_price,
    required this.new_price,
    required this.discount,
    required this.description,
    required this.reviews,
    required this.stocks,
    required this.category,
    required this.tags,
    required this.image,
    required this.available,
    required this.isNew,
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

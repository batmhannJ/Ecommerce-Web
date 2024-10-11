import 'package:flutter/material.dart';
import 'package:indigitech_shop/widget/product_list.dart';

import '../../../products.dart';

class FoodTabView extends StatefulWidget {
  const FoodTabView({super.key});

  @override
  State<FoodTabView> createState() => _FoodTabViewState();
}

class _FoodTabViewState extends State<FoodTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align items
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0), // Vertical padding
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, // Set width to 90% of screen width
              height: 50.0, // Set a specific height for the container
              decoration: BoxDecoration(
                color: Colors.white, // Set container color to white
                borderRadius: BorderRadius.circular(10.0), // Reduced border radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Lighten the shadow color
                    blurRadius: 5.0, // Reduced blur radius
                    offset: Offset(0, 2), // Adjusted shadow offset
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10.0), // Padding around the text
              child: Center( // Center the text within the container
                child: Text(
                  'FOOD', // Change the text to "FOOD"
                  style: Theme.of(context).textTheme.titleLarge?.copyWith( // Use titleLarge for Flutter 3.0+
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Change text color to black for contrast
                    fontSize: 24.0, // Maintain the original font size
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding for ProductList
            child: ProductList(
              products: products
                  .where((element) => element.category == "food")
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/product_view.dart';

import '../model/product.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  const ProductList({
    super.key,
    required this.products,
  });

  @override
Widget build(BuildContext context) {
  return AlignedGridView.count(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 20,
    itemCount: products.length,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) {
      Product product = products[index];

      return Container(
        width: MediaQuery.of(context).size.width / 2 - 22, // Adjust based on crossAxisCount and spacing
        height: 300, // Fixed height for the container
        decoration: BoxDecoration(
          color: AppColors.coolGrey,
          borderRadius: BorderRadius.circular(8), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              offset: const Offset(0, 4), // Offset of the shadow
              blurRadius: 6, // How blurred the shadow is
              spreadRadius: 1, // How much the shadow spreads
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductList(products: products),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Rounded corners for the image
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Smaller bottom margin
                  height: 200, // Fixed height for the image
                  width: double.infinity, // Make it full width
                  child: Image.asset(
                    product.images[0],
                    fit: BoxFit.contain, // Ensure the entire image is visible
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
            const Gap(15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding for text
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Further reduced font size for the product name
                  Text(
                    product.name,
                    overflow: TextOverflow.clip,
                    style: AppTextStyles.subtitle1.copyWith(
                      fontSize: 14, // Smaller size for the product name
                      fontWeight: FontWeight.bold, // Keep bold
                    ),
                  ),
                  const Gap(5),
                  Wrap(
                    children: [
                      if (product.discount != 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Text(
                            '₱${product.price - (product.price * product.discount)}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12, // Smaller size for discounted price
                              fontWeight: FontWeight.bold, // Keep bold
                            ),
                          ),
                        ),
                      Text(
                        '₱${product.price}',
                        style: product.discount != 0
                            ? AppTextStyles.caption.copyWith(
                                color: AppColors.greyAD,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppColors.greyAD,
                                fontSize: 12, // Smaller size for original price
                                fontWeight: FontWeight.bold, // Keep bold
                              )
                            : AppTextStyles.caption.copyWith(
                                fontSize: 12, // Smaller size for regular price
                                fontWeight: FontWeight.bold, // Keep bold
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

}

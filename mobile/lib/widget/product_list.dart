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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductView(product: product),
                  ),
                );
              },
              child: Container(
                height: 250,
                color: AppColors.coolGrey,
                child: Image.asset(
                  product.images[0],
                  alignment: Alignment.center,
                ),
              ),
            ),
            const Gap(15),
            Text(
              product.name,
              overflow: TextOverflow.clip,
              style: AppTextStyles.subtitle1,
            ),
            const Gap(5),
            Wrap(
              children: [
                if (product.discount != 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Text(
                      '₱${product.price - (product.price * product.discount)}',
                      style: AppTextStyles.caption,
                    ),
                  ),
                Text(
                  '₱${product.price}',
                  style: product.discount != 0
                      ? AppTextStyles.caption.copyWith(
                          color: AppColors.greyAD,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.greyAD,
                        )
                      : AppTextStyles.caption,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

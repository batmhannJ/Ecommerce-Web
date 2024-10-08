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
        children: [
          ProductList(
            products: products
                .where((element) => element.category == "food")
                .toList(),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

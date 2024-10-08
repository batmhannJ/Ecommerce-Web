import 'package:flutter/material.dart';
import 'package:indigitech_shop/widget/product_list.dart';

import '../../../products.dart';

class ClothesTabView extends StatefulWidget {
  const ClothesTabView({super.key});

  @override
  State<ClothesTabView> createState() => _ClothesTabViewState();
}

class _ClothesTabViewState extends State<ClothesTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          ProductList(
            products: products
                .where((element) => element.category == "clothes")
                .toList(),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

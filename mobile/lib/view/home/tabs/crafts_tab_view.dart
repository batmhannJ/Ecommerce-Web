import 'package:flutter/material.dart';
import 'package:indigitech_shop/widget/product_list.dart';

import '../../../products.dart';

class CraftsTabView extends StatefulWidget {
  const CraftsTabView({super.key});

  @override
  State<CraftsTabView> createState() => _CraftsTabViewState();
}

class _CraftsTabViewState extends State<CraftsTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          ProductList(
            products: products
                .where((element) => element.category == "crafts")
                .toList(),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

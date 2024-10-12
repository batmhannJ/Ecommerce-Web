import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/home/tabs/shop_tab_view.dart';

import '../../../core/style/colors.dart';
import '../../../products.dart';
import '../../../widget/buttons/custom_filled_button.dart';
import '../../../widget/product_list.dart';

class ShopTabView extends StatefulWidget {
  const ShopTabView({super.key});

  @override
  State<ShopTabView> createState() => _ShopTabViewState();
}

class _ShopTabViewState extends State<ShopTabView>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final _newCollectionsKey = GlobalKey();

  void _scrollToNewCollections() {
    final context = _newCollectionsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              const Color(0xfff8e2fb),
              const Color(0xfff8f3f9),
              const Color(0xffd0d5d1),
              AppColors.primary,
              AppColors.primary.withOpacity(.7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const <double>[
              .03,
              .1,
              .225,
              .275,
              1,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "WELCOME TO",
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 28,
                ),
              ),
            ),
            const Gap(10),
            Stack(
              alignment: Alignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    "assets/images/featured_item.png",
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  child: Text(
                    "TIENDA",
                    style: AppTextStyles.headline4.copyWith(
                      fontSize: 40,
                      color: AppColors.red,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 5,
                          color: AppColors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(20),
            // Add the SearchProductsWidget here
            SearchProductsWidget(
              products: products.map((product) => product.name).toList(),
            ),
            const Gap(20),
            CustomButton(
              text: "Explore Latest Collection",
              textStyle: AppTextStyles.button.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              command: _scrollToNewCollections,
              height: 48,
              fillColor: AppColors.red,
              contentPadding: const EdgeInsets.symmetric(horizontal: 30),
              borderRadius: 30,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primary,
              ),
              iconPadding: 8,
            ),
            const Gap(40),
            Padding(
              key: _newCollectionsKey,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    "NEW COLLECTIONS",
                    style: AppTextStyles.headline5.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 100,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        color: AppColors.black,
                        height: 0,
                        thickness: 3,
                      ),
                    ),
                  ),
                  ProductList(
                    products:
                        products.where((element) => element.isNew).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

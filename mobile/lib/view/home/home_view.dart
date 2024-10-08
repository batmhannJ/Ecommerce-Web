import 'package:flutter/material.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/home/tabs/clothes_tab_view.dart';
import 'package:indigitech_shop/view/home/tabs/crafts_tab_view.dart';
import 'package:indigitech_shop/view/home/tabs/food_tab_view.dart';
import 'package:indigitech_shop/view/home/tabs/shop_tab_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<Widget> _tabs = <Widget>[
    const Tab(text: "Shop"),
    const Tab(text: "Food"),
    const Tab(text: "Crafts"),
    const Tab(text: "Clothes"),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
      child: Column(
        children: [
          TabBar(
            tabs: _tabs,
            labelStyle: AppTextStyles.subtitle1,
            labelColor: AppColors.black,
            unselectedLabelColor: AppColors.greyAD,
            indicatorColor: AppColors.orange,
            indicatorSize: TabBarIndicatorSize.tab,
            overlayColor:
                MaterialStatePropertyAll(AppColors.black.withOpacity(.05)),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                ShopTabView(),
                FoodTabView(),
                CraftsTabView(),
                ClothesTabView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

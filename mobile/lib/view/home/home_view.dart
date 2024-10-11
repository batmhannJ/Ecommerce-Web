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
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.store),
                text: 'Shop',
              ),
              Tab(
                icon: Icon(Icons.fastfood),
                text: 'Food',
              ),
              Tab(
                icon: Icon(Icons.brush),
                text: 'Crafts',
              ),
              Tab(
                icon: Icon(Icons.shopping_bag),
                text: 'Clothes',
              ),
            ],
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey[700],
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.blue, // Color of the indicator
                  width: 3,
                ),
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.only(bottom: 5),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
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
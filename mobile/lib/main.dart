import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/cart_view.dart';
import 'package:indigitech_shop/view/home/home_view.dart';
import 'package:indigitech_shop/view/profile_view.dart';
import 'package:indigitech_shop/view_model/address_view_model.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:indigitech_shop/view_model/cart_view_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = <Widget>[
    const HomeView(),
    const CartView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CartViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => AddressViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Tienda',
        home: SafeArea(
          child: Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              elevation: 5,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Symbols.home,
                    fill: _selectedIndex == 0 ? 1 : 0,
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Builder(
                    builder: (context) {
                      int itemCount = context.select<CartViewModel, int>(
                          (value) => value.items.length);

                      return Badge(
                        label: Text("$itemCount"),
                        isLabelVisible: itemCount > 0,
                        child: Icon(
                          Symbols.shopping_cart,
                          fill: _selectedIndex == 1 ? 1 : 0,
                        ),
                      );
                    },
                  ),
                  label: "Cart",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Symbols.person,
                    fill: _selectedIndex == 2 ? 1 : 0,
                  ),
                  label: "Profile",
                ),
              ],
              selectedIconTheme: const IconThemeData(
                fill: 1,
              ),
              selectedLabelStyle: AppTextStyles.caption
                  .copyWith(fontWeight: AppFontWeights.bold),
              unselectedLabelStyle: AppTextStyles.caption,
              fixedColor: AppColors.black,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ),
        builder: (context, child) {
          return MediaQuery.withNoTextScaling(
              child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}

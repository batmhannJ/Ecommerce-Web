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
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart'; // For defaultTargetPlatform


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
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BottomNavigationBar(
              elevation: 10, // Slightly elevated for a floating effect
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Symbols.home,
                    size: 30, // Larger icon size
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
                          size: 30, // Larger icon size
                        ),
                      );
                    },
                  ),
                  label: "Cart",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Symbols.person,
                    size: 30, // Larger icon size
                  ),
                  label: "Profile",
                ),
              ],
              selectedIconTheme: const IconThemeData(
                color: AppColors.orange, // Custom active color
                size: 30,
              ),
              unselectedIconTheme: const IconThemeData(
                color: AppColors.greyAD,
                size: 30,
              ),
              selectedLabelStyle: AppTextStyles.caption
                  .copyWith(fontWeight: AppFontWeights.bold),
              unselectedLabelStyle: AppTextStyles.caption,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.white, // Background color
            ),
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

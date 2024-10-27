import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/extensions/string_extensions.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view_model/cart_view_model.dart';
import 'package:indigitech_shop/view/auth/login_view.dart';
import 'package:indigitech_shop/view/auth/signup_view.dart';
import 'package:indigitech_shop/view/home/home_view.dart';
import 'package:indigitech_shop/widget/buttons/custom_filled_button.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constant/enum/product_size.dart';
import '../products.dart';
import '../model/product.dart';
// import '../widget/image_carousel.dart';
import '../widget/product_list.dart';
import 'layout/default_view_layout.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import '../core/constant/enum/product_size.dart';


class ProductView extends StatefulWidget {
  final Product product;
    final List<Product> products;

  const ProductView({
    super.key,
    required this.product,
    required this.products, // Pass the products as a parameter
  });

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  late List<Product> _relatedProducts;
  ProductSize? _selectedSize;

  @override
  void initState() {
    _relatedProducts = widget.products
        .where((element) =>
            element.name != widget.product.name &&
            element.category == widget.product.category &&
            element.tags
                .toSet()
                .intersection(widget.product.tags.toSet())
                .isNotEmpty)
        .toList();
    super.initState();
  }

  // Function to save cart items to SharedPreferences
  Future<void> _saveToCart(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Retrieve existing cart items
    List<String>? cartItems = prefs.getStringList('cart') ?? [];
    
    // Add the new product to the cart (you may need to convert the product to a String or JSON)
    cartItems.add(product.name); // Simplified, you may want to serialize the whole product
    
    // Save updated cart
    await prefs.setStringList('cart', cartItems);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultViewLayout(
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ImageCarousel(
            //   images: widget.product.images.map((e) {
            //     return Image.asset(e);
            //   }).toList(),
            // ),
            const Gap(15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: AppTextStyles.headline5,
                  ),
                  const Gap(5),
                  RatingWidget(
                    product: widget.product,
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Text(
                          '₱${widget.product.new_price}.00',
                          style: widget.product.discount != 0
                              ? AppTextStyles.body1.copyWith(
                                  color: AppColors.greyAD,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.greyAD,
                                )
                              : AppTextStyles.body1,
                        ),
                      ),
                      if (widget.product.discount!= 0)
                        Text(
                          '₱${widget.product.old_price - (widget.product.new_price * widget.product.discount)}.00',
                          style: AppTextStyles.body1
                              .copyWith(color: AppColors.red),
                        ),
                    ],
                  ),
                  const Gap(20),
                  Text(
                    widget.product.description,
                    overflow: TextOverflow.clip,
                    style: AppTextStyles.body2,
                  ),
                  if (widget.product.stocks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: SizePicker(
                      sizes: widget.product.stocks.keys.toList(), // Convert Map keys to List
                        onSizeSelected: (value) {
                          setState(() {
                            _selectedSize = value;
                          });
                        },
                      ),
                    ),
                  const Gap(20),
                  //For qty button
                  Text(
                    widget.product.description,
                    overflow: TextOverflow.clip,
                    style: AppTextStyles.body2,
                  ),
                  if (widget.product.stocks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: SizePicker(
                      sizes: widget.product.stocks.keys.toList(), // Convert Map keys to List
                        onSizeSelected: (value) {
                          setState(() {
                            _selectedSize = value;
                          });
                        },
                      ),
                    ),
                  const Gap(20),
                  CustomButton(
                    disabled: _selectedSize == null && widget.product.stocks.isNotEmpty,
                    text: "ADD TO CART",
                    textStyle: AppTextStyles.button,
                    command: () async {
                      final prefs = await SharedPreferences.getInstance();
                      
                      // Check if user is logged in
                      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
                      
                      if (isLoggedIn) {
                        // User is logged in, proceed with adding to cart
                        context.read<CartViewModel>().addItem(widget.product);
                        _saveToCart(widget.product); // Save to SharedPreferences
                      } else {
                        // User is not logged in, redirect to login page using MaterialPageRoute
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => 
                              LoginView(
                                onLogin: () {
                                  final authViewModel = context.read<AuthViewModel>();
                                  authViewModel.logins().then((_) async {
                                    if (authViewModel.isLoggedIn) {
                                      // Get user info from authViewModel
                                      final userInfo = authViewModel.user; // Assuming this is where user info is stored

                                      // Store user info in SharedPreferences
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      await prefs.setString('userId', userInfo!.id); // Replace 'id' with actual field
                                      await prefs.setString('userName', userInfo.name); // Replace 'name' with actual field
                                      await prefs.setString('userEmail', userInfo.email); // Replace 'email' with actual field
                                      // Add other user details as needed

                                      // Redirect to HomeView after successful login
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => const HomeView()),
                                      );
                                    }
                                  });
                                },
                                
                                onCreateAccount: () {
                                  final authViewModel = context.read<AuthViewModel>();
                                  // Navigate to the Signup View
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SignupView(
                                        onLogin: () { 
                                          authViewModel.logins(); 
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ), // Replace with your login screen widget
                          ),
                        );
                      }
                    },
                    height: 48,
                    fillColor: AppColors.red,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  ),

                  const Gap(20),
                  RichText(
                    text: TextSpan(
                      text: "Category: ",
                      style: AppTextStyles.body1
                          .copyWith(fontWeight: AppFontWeights.bold),
                      children: [
                        TextSpan(
                          text: widget.product.category.capitalize(),
                          style: const TextStyle(
                              fontWeight: AppFontWeights.regular),
                        ),
                      ],
                    ),
                  ),
                  const Gap(10),
                  RichText(
                    text: TextSpan(
                      text: "Tags: ",
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: AppFontWeights.bold,
                        overflow: TextOverflow.clip,
                      ),
                      children: [
                        TextSpan(
                          text: widget.product.tags
                              .map((e) => e.capitalize())
                              .join(", "),
                          style: const TextStyle(
                              fontWeight: AppFontWeights.regular),
                        ),
                      ],
                    ),
                  ),
                  if (_relatedProducts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              "Related Products",
                              style: AppTextStyles.headline5,
                            ),
                            const SizedBox(
                              width: 100,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                  color: AppColors.black,
                                  height: 0,
                                  thickness: 2.5,
                                ),
                              ),
                            ),
                            ProductList(
                              products: _relatedProducts,
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RatingWidget extends StatelessWidget {
  final Product product;
  const RatingWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    double rating = product.getRatingAverage();
    double decimal = rating % 1;

    return Row(
      children: [
        ...List.generate(
          rating.truncate(),
          (index) {
            return const Icon(
              Symbols.star,
              fill: 1,
              color: AppColors.orange,
            );
          },
        ),
        if (decimal > 0)
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.orange, AppColors.orange.withOpacity(.5)],
                stops: [decimal, 0],
              ).createShader(bounds);
            },
            child: const Icon(
              Symbols.star,
              fill: 1,
            ),
          ),
        ...List.generate(
          5 - rating.truncate() - (decimal > 0 ? 1 : 0),
          (index) => Icon(
            Symbols.star,
            fill: 1,
            color: AppColors.orange.withOpacity(.5),
          ),
        ),
        const Gap(5),
        Text(
          "(${product.reviews.length})",
          style: AppTextStyles.body2,
        )
      ],
    );
  }
}

class SizePicker extends StatefulWidget {
  final List<ProductSize> sizes;
  final ValueChanged<ProductSize?> onSizeSelected;

  const SizePicker({
    super.key,
    required this.sizes,
    required this.onSizeSelected,
  });

  @override
  State<SizePicker> createState() => _SizePickerState();
}

class _SizePickerState extends State<SizePicker> {
  ProductSize? _selectedSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Size",
          style: AppTextStyles.headline6.copyWith(color: AppColors.greyAD),
        ),
        const Gap(10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(widget.sizes.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = widget.sizes[index];
                  widget.onSizeSelected(_selectedSize);
                });
              },
              child: Container(
                width: 40,
                height: 40,
                color: _selectedSize == widget.sizes[index]
                    ? AppColors.greyAD
                    : AppColors.lightGrey,
                child: Center(
                  child: Text(
                    widget.sizes[index].name.toUpperCase(),
                    style: AppTextStyles.button.copyWith(
                      color: _selectedSize == widget.sizes[index]
                          ? AppColors.primary
                          : AppColors.black,
                    ),
                  ),
                ),
              ),
            );
          }),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/form_styles.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/address_view.dart';
import 'package:indigitech_shop/view/auth/auth_view.dart';
import 'package:indigitech_shop/view/checkout_view.dart';
import 'package:indigitech_shop/widget/product_list.dart';
import 'package:indigitech_shop/view_model/address_view_model.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:indigitech_shop/view_model/cart_view_model.dart';
import 'package:indigitech_shop/widget/form_fields/custom_text_form_field.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

import '../model/product.dart';
import '../widget/buttons/custom_filled_button.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
 @override
Widget build(BuildContext context) {
  List<MapEntry<Product, int>> items =
      context.select<CartViewModel, List<MapEntry<Product, int>>>(
    (value) => value.items,
  );

  return Stack(
    fit: StackFit.expand,
    children: [
      Container(
        color: AppColors.lightGrey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Adjust padding for spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add the "CART" title here
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0), // Vertical padding for "CART"
                child: Center( // Center the container itself in the parent column
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9, // Set width to 90% of screen width
                    height: 50.0, // Set a specific height for the container
                    decoration: BoxDecoration(
                      color: Colors.white, // Set container color to white
                      borderRadius: BorderRadius.circular(10.0), // Reduced border radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Light shadow color
                          blurRadius: 5.0, // Reduced blur radius
                          offset: Offset(0, 2), // Adjusted shadow offset
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10.0), // Padding around the text
                    child: Center( // Center the text within the container
                      child: Text(
                        'CART', // Title for the cart section
                        style: AppTextStyles.headline5.copyWith( // Use a headline style
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Change text color to black for contrast
                          fontSize: 24.0, // Maintain the original font size
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Existing cart items list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  MapEntry<Product, int> item = items[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12), // Space between list items
                    padding: const EdgeInsets.all(10), // Padding for content spacing
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8), // Add rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 3), // Subtle shadow for depth
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8), // Add padding inside the list tile
                      leading: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductList(products: [item.key]), // Wrap item.key in a list
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6), // Rounded image corners
                          child: Image.asset(
                            item.key.images.first,
                            width: 50,
                            fit: BoxFit.cover, // Ensures image scaling is consistent
                          ),
                        ),
                      ),
                      title: Text(
                        item.key.name,
                        overflow: TextOverflow.ellipsis, // Better text handling for long product names
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Slightly smaller for compact display
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Builder(
                              builder: (context) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4), // Add padding for aesthetics
                                  decoration: BoxDecoration(
                                    color: Colors.transparent, // Background color if needed
                                    borderRadius: BorderRadius.circular(4), // Rounded corners for the container
                                  ),
                                  child: Text(
                                    "₱${context.read<CartViewModel>().totalItemPrice(item.key)}",
                                    style: AppTextStyles.body2.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black, // Changed to standard color
                                    ),
                                  ),
                                );
                              },
                            ),
                            QuantitySelector(
                              product: item.key,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20), // Increase spacing between list and totals section
              
              // Cart Totals Section wrapped in Container
              Container(
                padding: const EdgeInsets.all(16), // Add padding for the container
                decoration: BoxDecoration(
                  color: Colors.white, // Background color for the totals section
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cart Totals",
                      style: AppTextStyles.headline5.copyWith(
                        fontSize: 18, // Bold and larger font for "Cart Totals"
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Subtotal",
                          style: AppTextStyles.body2.copyWith(fontSize: 14),
                        ),
                        Text(
                          "₱${context.read<CartViewModel>().getSubtotal()}",
                          style: AppTextStyles.body2.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        color: AppColors.greyAD.withAlpha(100),
                        height: 0,
                        thickness: 1.5, // Thinner divider for a more refined look
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Shipping Fee",
                          style: AppTextStyles.body2.copyWith(fontSize: 14),
                        ),
                        Text(
                          "Free",
                          style: AppTextStyles.body2.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green, // Green for positive 'Free' indication
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        color: AppColors.greyAD.withAlpha(100),
                        height: 0,
                        thickness: 1.5,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: AppTextStyles.subtitle1.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16, // Make 'Total' text slightly larger
                          ),
                        ),
                        Text(
                          "₱${context.read<CartViewModel>().getSubtotal()}",
                          style: AppTextStyles.subtitle1.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      disabled: items.isEmpty,
                      text: "PROCEED TO CHECKOUT",
                      textStyle: AppTextStyles.button,
                      height: 50, // Slightly increased button height for better tap target
                      fillColor: AppColors.red,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14), // Adjusted button padding
                      command: () async {
                        if (!context.read<AuthViewModel>().isLoggedIn) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AuthView(),
                            ),
                          );
                        }

                        if (context.mounted &&
                            context.read<AddressViewModel>().address == null &&
                            context.read<AuthViewModel>().isLoggedIn) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddressView(),
                            ),
                          );
                        }

                        if (context.mounted &&
                            context.read<AddressViewModel>().address != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CheckoutView(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}


}

class PromoCodeForm extends StatefulWidget {
  const PromoCodeForm({super.key});

  @override
  State<PromoCodeForm> createState() => _PromoCodeFormState();
}

class _PromoCodeFormState extends State<PromoCodeForm> {
  final _promoCodeController = TextEditingController();

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "If you have a promo code, Enter it here",
            style: AppTextStyles.body2,
          ),
          const Gap(10),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: _promoCodeController,
                  formStyle: FormStyle(
                    textStyle: AppTextStyles.body1,
                    fillColor: AppColors.greyAD.withAlpha(100),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  height: 48,
                  hintText: "promo code",
                ),
              ),
              CustomButton(
                text: "Submit",
                textStyle: AppTextStyles.button,
                command: () {},
                height: 48,
                fillColor: AppColors.black,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final Product product;
  const QuantitySelector({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    int itemCount = context.watch<CartViewModel>().itemCount(product);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.greyAD.withAlpha(100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              context.read<CartViewModel>().subtractItem(product);
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                itemCount > 1 ? Symbols.remove : Symbols.delete,
                size: 15,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              border: Border(
                left: BorderSide(color: AppColors.greyAD.withAlpha(100)),
                right: BorderSide(color: AppColors.greyAD.withAlpha(100)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Text(
                "$itemCount",
                style: AppTextStyles.caption
                    .copyWith(fontWeight: AppFontWeights.bold),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<CartViewModel>().addItem(product);
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: const Icon(
                Symbols.add,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

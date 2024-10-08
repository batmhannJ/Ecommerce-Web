import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/form_styles.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/address_view.dart';
import 'package:indigitech_shop/view/auth/auth_view.dart';
import 'package:indigitech_shop/view/checkout_view.dart';
import 'package:indigitech_shop/view/product_view.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    MapEntry<Product, int> item = items[index];

                    return Container(
                      color: AppColors.primary,
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductView(product: item.key),
                              ),
                            );
                          },
                          child: Image.asset(
                            item.key.images.first,
                            width: 50,
                          ),
                        ),
                        title: Text(
                          item.key.name,
                          overflow: TextOverflow.clip,
                          style: AppTextStyles.body2,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Builder(
                                builder: (context) {
                                  return Text(
                                    "₱${context.read<CartViewModel>().totalItemPrice(item.key)}",
                                    style: AppTextStyles.body2,
                                  );
                                },
                              ),
                              QuantitySelector(
                                product: item.key,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Gap(20),
                Text(
                  "Cart Totals",
                  style: AppTextStyles.headline5,
                ),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Subtotal",
                      style: AppTextStyles.body2,
                    ),
                    Text(
                      "₱${context.read<CartViewModel>().getSubtotal()}",
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    color: AppColors.greyAD.withAlpha(100),
                    height: 0,
                    thickness: 2,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Shipping Fee",
                      style: AppTextStyles.body2,
                    ),
                    Text(
                      "Free",
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    color: AppColors.greyAD.withAlpha(100),
                    height: 0,
                    thickness: 2,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total",
                      style: AppTextStyles.subtitle1,
                    ),
                    Text(
                      "₱${context.read<CartViewModel>().getSubtotal()}",
                      style: AppTextStyles.subtitle1,
                    ),
                  ],
                ),
                const Gap(20),
                /* const PromoCodeForm(),
                const Gap(20),*/
                CustomButton(
                  disabled: items.isEmpty,
                  text: "PROCEED TO CHECKOUT",
                  textStyle: AppTextStyles.button,
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
                  height: 48,
                  fillColor: AppColors.red,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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

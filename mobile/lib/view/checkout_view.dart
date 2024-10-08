
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/colors.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/layout/default_view_layout.dart';
import 'package:indigitech_shop/view_model/address_view_model.dart';
import 'package:provider/provider.dart';

import '../model/address.dart';
import '../model/product.dart';
import '../view_model/cart_view_model.dart';
import '../widget/buttons/custom_filled_button.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultViewLayout(
      title: "Checkout",
      background: AppColors.coolGrey,
      content: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                orderDetailsCard(),
                itemsOrderedCard(context),
                shippingInformationCard(context),
                orderSummaryCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget orderDetailsCard() => InfoCard(
        title: "ORDER DETAILS",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Date",
              style: AppTextStyles.body2
                  .copyWith(fontWeight: AppFontWeights.semiBold),
            ),
            Text(
              "July 21, 2024",
              style: AppTextStyles.body2,
            ),
            const Gap(10),
            Text(
              "Order Number",
              style: AppTextStyles.body2
                  .copyWith(fontWeight: AppFontWeights.semiBold),
            ),
            Text(
              "072102",
              style: AppTextStyles.body2,
            ),
          ],
        ),
      );

  Widget itemsOrderedCard(BuildContext context) {
    List<MapEntry<Product, int>> items =
        context.select<CartViewModel, List<MapEntry<Product, int>>>(
      (value) => value.items,
    );

    return InfoCard(
      title: "ITEMS ORDERED",
      content: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          MapEntry<Product, int> item = items[index];

          return Padding(
            padding: EdgeInsets.only(top: index != 0 ? 20 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyAD)),
                  child: Image.asset(
                    item.key.images.first,
                    height: 80,
                    width: 80,
                  ),
                ),
                const Gap(10),
                SizedBox(
                  height: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.key.name,
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: AppFontWeights.bold,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.subtitle2,
                          text: "Quantity:  ",
                          children: [
                            TextSpan(
                              text: "${item.value}",
                              style: const TextStyle(
                                fontWeight: AppFontWeights.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget shippingInformationCard(BuildContext context) {
    Address address = context.read<AddressViewModel>().address!;

    return InfoCard(
      title: "SHIPPING INFORMATION",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.fullName,
            style: AppTextStyles.body2,
          ),
          Text(
            address.line1,
            style: AppTextStyles.body2,
          ),
          Text(
            "${address.barangay}, ${address.city}",
            style: AppTextStyles.body2,
          ),
          Text(
            "${address.postalCode}, ${address.province}",
            style: AppTextStyles.body2,
          ),
        ],
      ),
    );
  }

  Widget orderSummaryCard(BuildContext context) {
    return InfoCard(
      title: "ORDER SUMMARY",
      content: Column(
        children: [
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
            },
            children: [
              TableRow(children: [
                Text(
                  "Subtotal:",
                  style: AppTextStyles.subtitle2,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    "₱${context.read<CartViewModel>().getSubtotal()}",
                    style: AppTextStyles.body2,
                  ),
                ),
              ]),
              TableRow(children: [
                Text(
                  "Shipping:",
                  style: AppTextStyles.subtitle2,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    "Free",
                    style: AppTextStyles.body2,
                  ),
                ),
              ]),
              TableRow(children: [
                Text(
                  "Total:",
                  style: AppTextStyles.subtitle2
                      .copyWith(fontWeight: AppFontWeights.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    "₱${context.read<CartViewModel>().getSubtotal()}",
                    style: AppTextStyles.body2.copyWith(color: Colors.green),
                  ),
                ),
              ])
            ],
          ),
          const Gap(25),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  isExpanded: true,
                  text: "Proceed",
                  textStyle: AppTextStyles.button,
                  command: () {

                  },
                  height: 48,
                  fillColor: AppColors.red,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final Widget content;
  const InfoCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text(
            title,
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: AppFontWeights.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: content,
        ),
      ],
    );
  }
}

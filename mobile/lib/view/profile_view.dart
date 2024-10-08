import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/font_weights.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/address_view.dart';
import 'package:indigitech_shop/view/auth/auth_view.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../core/style/colors.dart';
import '../widget/buttons/custom_filled_button.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.watch<AuthViewModel>().isLoggedIn) {
      return Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi User!",
                  style: AppTextStyles.headline6,
                ),
                const Gap(25),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AddressView(),
                  )),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.black,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Symbols.location_pin),
                        const Gap(5),
                        Text(
                          "Shipping Address",
                          style: AppTextStyles.subtitle1,
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(10),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.black,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Symbols.lock_open),
                        const Gap(5),
                        Text(
                          "Change Password",
                          style: AppTextStyles.subtitle1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    isExpanded: true,
                    text: "Logout",
                    textStyle: AppTextStyles.button,
                    command: () {
                      context.read<AuthViewModel>().logout();
                    },
                    height: 48,
                    fillColor: AppColors.black,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return const AuthView(
        fromProfile: true,
      );
    }
  }
}

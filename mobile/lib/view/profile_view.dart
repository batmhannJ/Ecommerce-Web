import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:indigitech_shop/core/style/text_styles.dart';
import 'package:indigitech_shop/view/accountSetings_view.dart';
import 'package:indigitech_shop/view/address_view.dart';
import 'package:indigitech_shop/view/auth/auth_view.dart';
import 'package:indigitech_shop/view/changePasswordView.dart';
import 'package:indigitech_shop/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

import '../widget/buttons/custom_filled_button.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

@override
Widget build(BuildContext context) {
  if (context.watch<AuthViewModel>().isLoggedIn) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Light neutral background
        Container(
          color: const Color(0xFFF4F4F4), // Soft light gray background
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                "Hello, User!",
                style: AppTextStyles.headline5.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700, // Bold for emphasis
                ),
              ),
              const Gap(25),

              // Shipping Address card
              _buildCardSection(
                icon: Icons.location_pin,
                label: "Account Settings",
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AccountSettingsView(),
                )),
              ),
              const Gap(20),
              _buildCardSection(
                icon: Icons.location_pin,
                label: "Shipping Address",
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddressView(),
                )),
              ),
              const Gap(20),

              // Change Password card
              _buildCardSection(
                icon: Icons.lock_outline,
                label: "Change Password",
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ChangePasswordView(),
                )),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    isExpanded: true,
                    text: "Logout",
                    textStyle: AppTextStyles.button.copyWith(
                      color: Colors.white, // White text on the button
                      fontWeight: FontWeight.w600,
                    ),
                    command: () {
                      context.read<AuthViewModel>().logout();
                    },
                    height: 48,
                    fillColor: Colors.blueAccent, // Modern dark blue button
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    borderRadius: 8, // Slightly rounded for a clean, modern look
                  ),
                ),
              ],
            ),
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

// Card-based layout for each action (e.g., "Shipping Address")
Widget _buildCardSection({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white, // White background for the card
        borderRadius: BorderRadius.circular(12), // Smooth rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15), // Light shadow for depth
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4), // Slightly offset shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.blueAccent, // Modern blue icon color
          ),
          const Gap(20),
          Text(
            label,
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.w500, // Medium font weight
              color: Colors.black87, // Neutral dark text
            ),
          ),
        ],
      ),
    ),
  );
}




}

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
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white, // Darker background for contrast
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50], // Light background for header
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40, // Profile image placeholder
                    backgroundColor: Colors.blueGrey,
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, User!",
                          style: AppTextStyles.headline5.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Manage your account settings",
                          style: AppTextStyles.subtitle1.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action cards with more spacing
            Expanded(
              child: ListView(
                children: [
                  _buildActionCard(
                    icon: Icons.settings,
                    label: "Account Settings",
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AccountSettingsView(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    icon: Icons.location_on,
                    label: "Shipping Address",
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddressView(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    icon: Icons.lock,
                    label: "Change Password",
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordView(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          isExpanded: true,
          text: "Logout",
          textStyle: AppTextStyles.button.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          command: () {
            context.read<AuthViewModel>().logout();
          },
          height: 48,
          fillColor: const Color.fromARGB(255, 143, 34, 26), // Strong color for logout
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  } else {
    return const AuthView(
      fromProfile: true,
    );
  }
}

// Action card layout
Widget _buildActionCard({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white, // Clean white background
        borderRadius: BorderRadius.circular(8), // Slightly rounded corners
        border: Border.all(color: Colors.grey.withOpacity(0.2)), // Light border for definition
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 30,
            color: Colors.blueGrey, // Icon color for consistency
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey), // Navigation arrow
        ],
      ),
    ),
  );
}



}

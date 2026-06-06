// lib/features/market_profile/ui/screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_order/core/constants/app_design.dart';
import 'package:live_order/features/home/logic/cubit/home_cubit.dart';
import 'package:live_order/shared/widgets/avatar_widget.dart';

class MarketProfileScreen extends StatelessWidget {
  const MarketProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppDesign.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'My Profile',
          style: AppDesign.heading(fontSize: 18.0),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          String name = 'User Profile';
          String email = 'user@cargo.com';
          String initial = 'U';

          if (state is HomeLoaded) {
            name = state.user.name;
            email = state.user.email;
            initial = name.isNotEmpty ? name[0] : 'U';
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppDesign.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Block
                Container(
                  padding: const EdgeInsets.all(AppDesign.space16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDesign.radius12),
                    border: Border.all(color: AppDesign.border, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppDesign.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: AppDesign.heading(color: AppDesign.primary, fontSize: 20.0),
                        ),
                      ),
                      const SizedBox(width: AppDesign.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppDesign.heading(fontSize: 16.0),
                            ),
                            const SizedBox(height: AppDesign.space4),
                            Text(
                              email,
                              style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 13.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDesign.space24),

                // Account settings category
                _buildSectionTitle('ACCOUNT'),
                _buildSettingsCard([
                  _buildSettingRow(
                    context,
                    icon: Icons.map_outlined,
                    title: 'Saved Addresses',
                    subtitle: 'Home, work, and pickup details',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address Management coming soon.')),
                      );
                    },
                  ),
                  _buildSettingRow(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Payment Methods',
                    subtitle: 'Linked cards and billing history',
                    onTap: () => context.pushNamed('payments'),
                  ),
                  _buildSettingRow(
                    context,
                    icon: Icons.wallet_giftcard_rounded,
                    title: 'Rewards Program',
                    subtitle: 'View points balance and refer friends',
                    onTap: () => context.pushNamed('rewards'),
                  ),
                ]),

                const SizedBox(height: AppDesign.space24),

                // Support & Preferences category
                _buildSectionTitle('SUPPORT'),
                _buildSettingsCard([
                  _buildSettingRow(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center',
                    subtitle: 'FAQ and active ticket management',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact support at: support@cargomarketplace.com')),
                      );
                    },
                  ),
                  _buildSettingRow(
                    context,
                    icon: Icons.policy_outlined,
                    title: 'Legal & Policy',
                    subtitle: 'Terms of service and privacy rules',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Terms and Privacy Policies.')),
                      );
                    },
                  ),
                ]),

                const SizedBox(height: AppDesign.space24),

                // Danger zone / Log out category
                _buildSectionTitle('DANGER ZONE'),
                _buildSettingsCard([
                  _buildSettingRow(
                    context,
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    subtitle: 'Securely sign out of your account',
                    color: AppDesign.danger,
                    showArrow: false,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        context.go('/loginScreen');
                      }
                    },
                  ),
                ]),

                const SizedBox(height: AppDesign.space32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: AppDesign.space8),
      child: Text(
        title,
        style: AppDesign.body(
          color: AppDesign.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 11.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: AppDesign.border, width: 1.0),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: children.length,
        separatorBuilder: (context, index) => Divider(color: AppDesign.border, height: 1),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = AppDesign.textPrimary,
    bool showArrow = true,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color == AppDesign.textPrimary ? AppDesign.primary : color, size: 20),
      title: Text(
        title,
        style: AppDesign.body(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14.0,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppDesign.body(color: AppDesign.textSecondary, fontSize: 11.5),
      ),
      trailing: showArrow
          ? const Icon(Icons.arrow_forward_ios_rounded, color: AppDesign.textSecondary, size: 14)
          : null,
    );
  }
}

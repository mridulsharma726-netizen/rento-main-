import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/rento_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().userModel;
    final name = user?.displayNameOrPhone ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.accentSubtle,
                    child: Text(
                      name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 32,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: theme.textTheme.headlineSmall),
                  if (user?.phone != null) ...[
                    const SizedBox(height: 4),
                    Text(user!.phone!, style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 8),
                  // Rating badge
                  if (user?.rating != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentSubtle,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.accent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${user!.rating!.toStringAsFixed(1)} (${user.totalRatings ?? 0} ratings)',
                            style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Trust Score Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(user?.badgeColor ?? 0xFFFFC107).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Color(user?.badgeColor ?? 0xFFFFC107).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 12, color: Color(user?.badgeColor ?? 0xFFFFC107)),
                        const SizedBox(width: 4),
                        Text(
                          '${user?.trustBadge.toUpperCase()} (${user?.trustScore})',
                          style: TextStyle(
                            color: Color(user?.badgeColor ?? 0xFFFFC107),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // KYC Status
            RentoCard(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _kycBgColor(user?.kycStatus ?? 'not_submitted'),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_kycIcon(user?.kycStatus ?? 'not_submitted'),
                        color: _kycColor(user?.kycStatus ?? 'not_submitted'),
                        size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.kycVerification,
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          _kycLabel(user?.kycStatus ?? 'not_submitted'),
                          style: TextStyle(
                              color:
                                  _kycColor(user?.kycStatus ?? 'not_submitted'),
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (user?.kycStatus == 'not_submitted' ||
                      user?.kycStatus == 'rejected')
                    TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/kyc'),
                        child: const Text(AppStrings.submitIdProof)),
                ],
              ),
            ),
            const SizedBox(height: 16),

// Settings list
            RentoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _settingsTile(
                      context,
                      Icons.person_outline,
                      AppStrings.editProfile,
                      () => Navigator.pushNamed(context, '/edit-profile')),
                  const Divider(height: 1),
                  _settingsTile(
                      context,
                      Icons.chat_bubble_outline,
                      'Messages',
                      () => Navigator.pushNamed(context, '/chat-list')),
                  const Divider(height: 1),
                  _settingsTile(
                      context,
                      Icons.receipt_long_outlined,
                      AppStrings.myRentals,
                      () => Navigator.pushNamed(context, '/my-rentals')),
                  const Divider(height: 1),
                  _settingsTile(
                      context,
                      Icons.inventory_2_outlined,
                      AppStrings.myProductsLabel,
                      () => Navigator.pushNamed(context, '/my-products')),
                  const Divider(height: 1),
                  _settingsTile(
                      context,
                      Icons.settings_outlined,
                      AppStrings.settings,
                      () => Navigator.pushNamed(context, '/settings')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sign out
            RentoCard(
              padding: EdgeInsets.zero,
              child: _settingsTile(
                context,
                Icons.logout,
                AppStrings.logout,
                () => _confirmSignOut(context),
                isDestructive: true,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(
      BuildContext context, IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isDestructive ? AppColors.error : AppColors.textSecondary),
      title: Text(label,
          style: TextStyle(
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right,
              color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            },
            child: const Text(AppStrings.logout,
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Color _kycColor(String status) {
    switch (status) {
      case 'verified':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _kycBgColor(String status) {
    switch (status) {
      case 'verified':
        return AppColors.successSubtle;
      case 'pending':
        return AppColors.warningSubtle;
      case 'rejected':
        return AppColors.errorSubtle;
      default:
        return AppColors.surface;
    }
  }

  IconData _kycIcon(String status) {
    switch (status) {
      case 'verified':
        return Icons.verified_user;
      case 'pending':
        return Icons.hourglass_top_outlined;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.badge_outlined;
    }
  }

  String _kycLabel(String status) {
    switch (status) {
      case 'verified':
        return AppStrings.kycVerified;
      case 'pending':
        return AppStrings.kycPending;
      case 'rejected':
        return AppStrings.kycRejected;
      default:
        return AppStrings.kycNotSubmitted;
    }
  }
}

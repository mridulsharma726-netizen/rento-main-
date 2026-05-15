import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class BookingStatusChip extends StatelessWidget {
  final String status;

  const BookingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status) {
      case 'requested':
        return const _StatusConfig(AppStrings.statusRequested,
            AppColors.warningSubtle, AppColors.warning);
      case 'approved':
        return const _StatusConfig(
            AppStrings.statusApproved, AppColors.infoSubtle, AppColors.info);
      case 'booking_created':
        return const _StatusConfig(AppStrings.statusBookingCreated,
            AppColors.warningSubtle, AppColors.warning);
      case 'paid':
      case 'payment_done':
      case 'ready_for_pickup':
        return const _StatusConfig(AppStrings.statusReadyForPickup,
            AppColors.infoSubtle, AppColors.info);
      case 'active_rental':
      case 'active':
        return const _StatusConfig(AppStrings.statusActiveRental,
            AppColors.successSubtle, AppColors.success);
      case 'return_pending':
        return const _StatusConfig(AppStrings.statusReturnPending,
            AppColors.warningSubtle, AppColors.warning);
      case 'returned':
        return const _StatusConfig(AppStrings.statusReturned,
            AppColors.successSubtle, AppColors.success);
      case 'completed':
        return const _StatusConfig(AppStrings.statusCompleted,
            AppColors.successSubtle, AppColors.success);
      case 'cancelled':
        return const _StatusConfig(
            AppStrings.statusCancelled, AppColors.errorSubtle, AppColors.error);
      case 'rejected':
        return const _StatusConfig(
            AppStrings.statusRejected, AppColors.errorSubtle, AppColors.error);
      case 'expired':
        return const _StatusConfig(AppStrings.statusExpired, Color(0x1A52525B),
            AppColors.textSecondary);
      default:
        return _StatusConfig(status, AppColors.accentSubtle, AppColors.accent);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color bgColor;
  final Color textColor;
  const _StatusConfig(this.label, this.bgColor, this.textColor);
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../models/product_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/rento_button.dart';
import '../../widgets/rento_card.dart';

class BookingScreen extends StatelessWidget {
  final ProductModel product;
  final DateTime startDate;
  final DateTime endDate;

  const BookingScreen({
    super.key,
    required this.product,
    required this.startDate,
    required this.endDate,
  });

  int get _days => RentoDateUtils.daysBetween(startDate, endDate);
  double get _rental => product.pricePerDay * _days;
  double get _total => _rental + product.deposit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.bookingDetails)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product summary
            RentoCard(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.title,
                            style: theme.textTheme.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          product.category.isNotEmpty
                              ? product.category[0].toUpperCase() +
                                  product.category.substring(1)
                              : 'Other',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dates
            Text('Rental Period', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            RentoCard(
              child: Row(
                children: [
                  Expanded(
                      child: _dateCell(context, AppStrings.startDate,
                          RentoDateUtils.display(startDate))),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Expanded(
                      child: _dateCell(context, AppStrings.endDate,
                          RentoDateUtils.display(endDate))),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Expanded(
                      child: _dateCell(context, AppStrings.duration,
                          '$_days ${AppStrings.days}',
                          valueColor: AppColors.accent)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Price breakdown
            Text(AppStrings.paymentSummary, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            RentoCard(
              child: Column(
                children: [
                  _summaryRow(context, 'Price per day',
                      CurrencyUtils.format(product.pricePerDay)),
                  const SizedBox(height: 10),
                  _summaryRow(context, 'Duration', '$_days ${AppStrings.days}'),
                  const SizedBox(height: 10),
                  _summaryRow(context, AppStrings.rentalAmount,
                      CurrencyUtils.format(_rental)),
                  const Divider(height: 20),
                  _summaryRow(
                      context,
                      '${AppStrings.securityDeposit} (refundable)',
                      CurrencyUtils.format(product.deposit)),
                  const Divider(height: 20),
                  _summaryRow(context, AppStrings.totalAmount,
                      CurrencyUtils.format(_total),
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trust note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_outlined,
                      color: AppColors.success, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your request goes to the owner first. Payment unlocks only after approval.',
                      style: TextStyle(color: AppColors.success, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Consumer<BookingProvider>(
              builder: (_, provider, __) => RentoButton(
                label:
                    '${AppStrings.requestBooking} • ${CurrencyUtils.format(_total)}',
                onPressed: () => _createBooking(context, provider),
                isLoading: provider.isLoading,
                icon: Icons.send_outlined,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _createBooking(
      BuildContext context, BookingProvider provider) async {
    final booking = await provider.createBooking(
      productId: product.id,
      startDate: startDate,
      endDate: endDate,
    );
    if (!context.mounted) return;
    if (booking != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Booking request sent. Wait for the owner to approve it before payment.'),
          backgroundColor: AppColors.success,
        ),
      );
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/orders',
        (route) => route.settings.name == '/home',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.error ?? AppStrings.somethingWentWrong),
            backgroundColor: AppColors.error),
      );
    }
  }

  Widget _dateCell(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isTotal
                ? const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)
                : Theme.of(context).textTheme.bodyMedium),
        Text(value,
            style: TextStyle(
              color: isTotal ? AppColors.accent : AppColors.textPrimary,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              fontSize: isTotal ? 18 : 14,
            )),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/api_service.dart';
import '../../providers/booking_provider.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/rento_button.dart';
import '../../widgets/rento_card.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;
  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  final ApiService _api = ApiService();
  bool _isLoading = false;
  bool _isPaid = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _api.createPaymentOrder(widget.booking.id);
      if (!mounted) return;
      final data = res['data'] as Map<String, dynamic>;
      final user = context.read<AuthProvider>().userModel;

      final keyId = data['key_id'] as String?;
      if (keyId == null || keyId.isEmpty) {
        throw Exception('Payment gateway not configured. Contact support.');
      }
      final options = {
        'key': keyId,
        'amount': data['amount'],
        'order_id': data['orderId'],
        'currency': data['currency'] ?? 'INR',
        'name': 'RENTO',
        'description': 'Rental: ${widget.booking.productTitle}',
        'prefill': {
          'contact': user?.phone ?? '',
          'email': user?.email ?? 'user@rento.app',
        },
        'theme': {'color': '#B91C1C'},
      };
      _razorpay.open(options);
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await _api.verifyPayment({
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'razorpay_signature': response.signature,
      });
      if (mounted) {
        // Keep the orders list in sync — avoids the user seeing a stale
        // "Proceed to Payment" row after navigating back.
        context.read<BookingProvider>().markBookingPaid(widget.booking.id);
        setState(() {
          _isPaid = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is ApiException
              ? e.message
              : 'Payment verification failed. Contact support.';
          _isLoading = false;
        });
      }
    }
  }

  void _handleError(PaymentFailureResponse response) {
    setState(() {
      _error = response.message ?? 'Payment failed';
      _isLoading = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isPaid) {
      return _buildSuccess(context);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.orderSummary)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking ref
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_outlined,
                      color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text('Booking Ref: ', style: theme.textTheme.bodySmall),
                  Text(widget.booking.id,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(widget.booking.productTitle,
                style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),

            // Amount breakdown
            RentoCard(
              child: Column(
                children: [
                  _row(context, AppStrings.rentalAmount,
                      CurrencyUtils.format(widget.booking.rentalAmount)),
                  const SizedBox(height: 10),
                  _row(context, '${AppStrings.securityDeposit} (refundable)',
                      CurrencyUtils.format(widget.booking.deposit)),
                  const Divider(height: 20),
                  _row(context, AppStrings.totalAmount,
                      CurrencyUtils.format(widget.booking.totalAmount),
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment methods badge
            RentoCard(
              child: Row(
                children: [
                  const Icon(Icons.payment,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 10),
                  Text('UPI • Cards • Netbanking • Wallets',
                      style: theme.textTheme.bodySmall),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppColors.successSubtle,
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text('Secured',
                        style: TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.errorSubtle,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13))),
                  ],
                ),
              ),

            const SizedBox(height: 32),
            RentoButton(
              label:
                  '${AppStrings.payNow} • ${CurrencyUtils.format(widget.booking.totalAmount)}',
              onPressed: _initiatePayment,
              isLoading: _isLoading,
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('256-bit SSL encrypted payment',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: AppColors.successSubtle, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 48),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.paymentSuccessful,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('${CurrencyUtils.format(widget.booking.totalAmount)} paid',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Booking ID: ${widget.booking.id}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 40),
              RentoButton(
                label: 'View My Bookings',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/orders', (r) => r.settings.name == '/home'),
              ),
              const SizedBox(height: 12),
              RentoButton(
                label: 'Back to Home',
                variant: RentoButtonVariant.secondary,
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (_) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isTotal
                ? const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600)
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_status_chip.dart';
import '../../widgets/rento_card.dart';

class OrdersScreen extends StatefulWidget {
  final int initialTab;

  const OrdersScreen({super.key, this.initialTab = 0});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BookingProvider>();
      Future.wait([provider.loadUserBookings(), provider.loadOwnerBookings()]);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.myRentals),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: AppStrings.asRenter),
            Tab(text: AppStrings.asOwner),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.error!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Future.wait([
                        provider.loadUserBookings(),
                        provider.loadOwnerBookings(),
                      ]);
                    },
                    child: const Text(AppStrings.tryAgain),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _BookingList(
                bookings: provider.rentals,
                emptyLabel: AppStrings.noBookingsYet,
              ),
              _BookingList(
                bookings: provider.listings,
                emptyLabel: 'No listings booked yet',
                isOwner: true,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String emptyLabel;
  final bool isOwner;

  const _BookingList({
    required this.bookings,
    required this.emptyLabel,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              emptyLabel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _BookingCard(
        booking: bookings[index],
        isOwner: isOwner,
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isOwner;

  const _BookingCard({
    required this.booking,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startDate = RentoDateUtils.parse(booking.startDate);
    final endDate = RentoDateUtils.parse(booking.endDate);

    return RentoCard(
      onTap: () => Navigator.pushNamed(
        context,
        '/booking-detail',
        arguments: booking,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  booking.productTitle,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              BookingStatusChip(status: booking.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                startDate != null && endDate != null
                    ? '${RentoDateUtils.display(startDate)} → ${RentoDateUtils.display(endDate)}'
                    : '—',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoChip(
                Icons.access_time_outlined,
                '${booking.days} ${AppStrings.days}',
              ),
              const SizedBox(width: 12),
              _infoChip(
                Icons.currency_rupee,
                CurrencyUtils.format(booking.totalAmount),
                accent: true,
              ),
            ],
          ),
          ..._buildStateSections(context),
        ],
      ),
    );
  }

  List<Widget> _buildStateSections(BuildContext context) {
    final sections = <Widget>[];

    if (booking.isRequested) {
      sections.addAll([
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        if (isOwner)
          _OwnerDecisionRow(booking: booking)
        else
          _ActionMessageRow(
            icon: Icons.hourglass_top_outlined,
            color: AppColors.warning,
            message: 'Waiting for the owner to review this request.',
            trailing: TextButton(
              onPressed: () => _cancelBooking(context),
              style: _inlineButtonStyle(),
              child: const Text(AppStrings.cancelBooking),
            ),
          ),
      ]);
    }

    if (booking.isPendingPayment) {
      sections.addAll([
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        if (isOwner)
          const _ActionMessageRow(
            icon: Icons.info_outline,
            color: AppColors.info,
            message: 'Approved. Waiting for the renter to complete payment.',
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ActionMessageRow(
                icon: Icons.info_outline,
                color: AppColors.warning,
                message:
                    'Owner approved this request. Complete payment before the approval window expires.',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  TextButton(
                    onPressed: () => _cancelBooking(context),
                    style: _inlineButtonStyle(),
                    child: const Text(AppStrings.cancelBooking),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/payment',
                      arguments: booking,
                    ),
                    style: _inlineButtonStyle(),
                    child: const Text(AppStrings.proceedToPayment),
                  ),
                ],
              ),
            ],
          ),
      ]);
    }

    if (booking.isRejected) {
      sections.addAll([
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        _ActionMessageRow(
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          message: booking.ownerRejectionReason?.trim().isNotEmpty == true
              ? 'Owner declined this request: ${booking.ownerRejectionReason}'
              : 'Owner declined this request.',
        ),
      ]);
    }

    if (booking.isExpired) {
      sections.addAll(const [
        SizedBox(height: 12),
        Divider(height: 1),
        SizedBox(height: 12),
        _ActionMessageRow(
          icon: Icons.timer_off_outlined,
          color: AppColors.warning,
          message:
              'Payment window expired. Ask the owner to approve the request again.',
        ),
      ]);
    }

    if (booking.isPaid) {
      sections.addAll([
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        if (isOwner)
          _OtpGenerateRow(bookingId: booking.id)
        else
          _OtpVerifyRow(bookingId: booking.id),
      ]);
    }

    if (booking.isActive) {
      sections.addAll([
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        if (!isOwner && booking.returnId == null)
          _ReturnInitiateRow(bookingId: booking.id)
        else if (isOwner && booking.returnId != null)
          _ReturnConfirmRow(bookingId: booking.id),
      ]);
    }

    if (booking.isReturnPending) {
      sections.addAll([
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        if (isOwner)
          _ReturnConfirmRow(bookingId: booking.id)
        else
          const _ActionMessageRow(
            icon: Icons.assignment_return_outlined,
            color: AppColors.warning,
            message: 'Return submitted. Waiting for owner confirmation.',
          ),
      ]);
    }

    return sections;
  }

  Future<void> _cancelBooking(BuildContext context) async {
    final ok = await context.read<BookingProvider>().cancelBooking(booking.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Booking cancelled.' : 'Failed to cancel booking.'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {bool accent = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: accent ? AppColors.accent : AppColors.textSecondary,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: accent ? AppColors.accent : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static ButtonStyle _inlineButtonStyle() {
    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _ActionMessageRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final Widget? trailing;

  const _ActionMessageRow({
    required this.icon,
    required this.color,
    required this.message,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _OwnerDecisionRow extends StatefulWidget {
  final BookingModel booking;

  const _OwnerDecisionRow({required this.booking});

  @override
  State<_OwnerDecisionRow> createState() => _OwnerDecisionRowState();
}

class _OwnerDecisionRowState extends State<_OwnerDecisionRow> {
  bool _processing = false;

  Future<void> _approve() async {
    setState(() => _processing = true);
    final ok = await context.read<BookingProvider>().approveBooking(
          widget.booking.id,
        );
    if (!mounted) return;
    setState(() => _processing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Booking approved. Renter can pay now.'
              : 'Failed to approve booking.',
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _reject() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject booking request'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Reason for rejection (optional)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null) return;
    if (!mounted) return;

    setState(() => _processing = true);
    final ok = await context.read<BookingProvider>().rejectBooking(
          widget.booking.id,
          reason: reason,
        );
    if (!mounted) return;
    setState(() => _processing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Booking request rejected.' : 'Failed to reject booking.',
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Review this request before the payment step opens.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _processing ? null : _reject,
          style: _BookingCard._inlineButtonStyle(),
          child: const Text('Reject'),
        ),
        TextButton(
          onPressed: _processing ? null : _approve,
          style: _BookingCard._inlineButtonStyle(),
          child: _processing
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Approve'),
        ),
      ],
    );
  }
}

class _OtpGenerateRow extends StatefulWidget {
  final String bookingId;

  const _OtpGenerateRow({required this.bookingId});

  @override
  State<_OtpGenerateRow> createState() => _OtpGenerateRowState();
}

class _OtpGenerateRowState extends State<_OtpGenerateRow> {
  String? _otp;
  bool _loading = false;

  Future<void> _generate() async {
    setState(() => _loading = true);
    final otp = await context.read<BookingProvider>().generateOtp(
          widget.bookingId,
        );
    if (!mounted) return;
    setState(() {
      _otp = otp;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_otp != null) {
      return Row(
        children: [
          const Icon(
            Icons.lock_open_outlined,
            size: 13,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          const Text(
            'Pickup OTP:',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Text(
            _otp!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
              letterSpacing: 4,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.copy,
              size: 16,
              color: AppColors.textSecondary,
            ),
            onPressed: () => Clipboard.setData(ClipboardData(text: _otp!)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(Icons.qr_code, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        const Expanded(
          child: Text(
            'Share OTP with renter for pickup',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: _loading ? null : _generate,
          style: _BookingCard._inlineButtonStyle(),
          child: _loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Generate OTP'),
        ),
      ],
    );
  }
}

class _OtpVerifyRow extends StatefulWidget {
  final String bookingId;

  const _OtpVerifyRow({required this.bookingId});

  @override
  State<_OtpVerifyRow> createState() => _OtpVerifyRowState();
}

class _OtpVerifyRowState extends State<_OtpVerifyRow> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_ctrl.text.trim().length != 6) {
      setState(() => _error = 'Enter the 6-digit OTP');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await context.read<BookingProvider>().verifyOtp(
          widget.bookingId,
          _ctrl.text.trim(),
        );
    if (!mounted) return;

    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = 'Invalid OTP. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit OTP from owner',
                  hintStyle: const TextStyle(fontSize: 12),
                  counterText: '',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: _error,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _loading ? null : _verify,
              style: _BookingCard._inlineButtonStyle(),
              child: _loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReturnInitiateRow extends StatefulWidget {
  final String bookingId;

  const _ReturnInitiateRow({required this.bookingId});

  @override
  State<_ReturnInitiateRow> createState() => _ReturnInitiateRowState();
}

class _ReturnInitiateRowState extends State<_ReturnInitiateRow> {
  bool _loading = false;

  Future<void> _initiate() async {
    setState(() => _loading = true);
    final ok = await context.read<BookingProvider>().initiateReturn(
          widget.bookingId,
        );
    if (!mounted) return;

    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Return initiated. Waiting for owner confirmation.'
              : 'Failed to initiate return.',
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.assignment_return_outlined,
          size: 13,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: Text(
            'Ready to return the item?',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: _loading ? null : _initiate,
          style: _BookingCard._inlineButtonStyle(),
          child: _loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Return Item'),
        ),
      ],
    );
  }
}

class _ReturnConfirmRow extends StatefulWidget {
  final String bookingId;

  const _ReturnConfirmRow({required this.bookingId});

  @override
  State<_ReturnConfirmRow> createState() => _ReturnConfirmRowState();
}

class _ReturnConfirmRowState extends State<_ReturnConfirmRow> {
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final ok = await context.read<BookingProvider>().confirmReturn(
          widget.bookingId,
        );
    if (!mounted) return;

    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Return confirmed. Booking completed!'
              : 'Failed to confirm return.',
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 13,
          color: AppColors.warning,
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: Text(
            'Renter has initiated return',
            style: TextStyle(fontSize: 12, color: AppColors.warning),
          ),
        ),
        TextButton(
          onPressed: _loading ? null : _confirm,
          style: _BookingCard._inlineButtonStyle(),
          child: _loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirm Return'),
        ),
      ],
    );
  }
}

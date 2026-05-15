import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../core/constants/api_constants.dart';
import '../../widgets/rento_button.dart';
import '../../widgets/rento_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProduct(widget.productId);
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _bookNow(ProductModel product) {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select rental dates'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    Navigator.pushNamed(context, '/booking', arguments: {
      'product': product,
      'start_date': _startDate,
      'end_date': _endDate,
    });
  }

  int get _days => (_startDate != null && _endDate != null)
      ? RentoDateUtils.daysBetween(_startDate!, _endDate!)
      : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = context.watch<AuthProvider>().userModel?.uid;
    return Consumer<ProductProvider>(
      builder: (_, provider, __) {
        final product = provider.selectedProduct;
        final isOwnerViewing =
            product != null && currentUserId == product.ownerId;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: provider.isLoading || product == null
              ? _buildLoading()
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(product),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + category
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(product.title,
                                      style: theme.textTheme.headlineMedium),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentSubtle,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.category.toUpperCase(),
                                    style: const TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Status
                            Row(
                              children: [
                                Icon(
                                  product.isAvailable
                                      ? Icons.check_circle_outline
                                      : Icons.cancel_outlined,
                                  size: 14,
                                  color: product.isAvailable
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.isAvailable
                                      ? 'Available for rent'
                                      : 'Currently unavailable',
                                  style: TextStyle(
                                    color: product.isAvailable
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Pricing
                            RentoCard(
                              child: Column(
                                children: [
                                  _priceRow(context, AppStrings.pricePerDay,
                                      CurrencyUtils.format(product.pricePerDay),
                                      isAccent: true),
                                  const SizedBox(height: 10),
                                  _priceRow(context, AppStrings.securityDeposit,
                                      CurrencyUtils.format(product.deposit)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Date picker
                            Text(AppStrings.selectDates,
                                style: theme.textTheme.titleLarge),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _pickDateRange,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _startDate != null
                                          ? AppColors.accent
                                          : AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.date_range_outlined,
                                        color: AppColors.textSecondary,
                                        size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _startDate == null
                                            ? 'Tap to choose dates'
                                            : '${RentoDateUtils.display(_startDate!)}  →  ${RentoDateUtils.display(_endDate!)}',
                                        style: TextStyle(
                                          color: _startDate != null
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_days > 0) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                            color: AppColors.accentSubtle,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: Text('$_days ${AppStrings.days}',
                                            style: const TextStyle(
                                                color: AppColors.accent,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            if (_days > 0) ...[
                              const SizedBox(height: 12),
                              RentoCard(
                                color: AppColors.accentSubtle,
                                hasBorder: false,
                                child: Column(
                                  children: [
                                    _priceRow(
                                        context,
                                        'Rental (${_days}d × ${CurrencyUtils.format(product.pricePerDay)})',
                                        CurrencyUtils.format(
                                            product.pricePerDay * _days)),
                                    const SizedBox(height: 8),
                                    _priceRow(
                                        context,
                                        AppStrings.securityDeposit,
                                        CurrencyUtils.format(product.deposit)),
                                    const Divider(height: 16),
                                    _priceRow(
                                        context,
                                        AppStrings.totalAmount,
                                        CurrencyUtils.format(
                                            product.pricePerDay * _days +
                                                product.deposit),
                                        isAccent: true,
                                        isBold: true),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),

                            // Description
                            Text('About this item',
                                style: theme.textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text(product.description,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(height: 1.6)),
                            const SizedBox(height: 32),

                            // Owner section
                            Text('Owner', style: theme.textTheme.titleLarge),
                            const SizedBox(height: 12),
                            RentoCard(
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: AppColors.surface,
                                    child: Icon(Icons.person,
                                        color: AppColors.textDisabled),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              product.ownerName.isNotEmpty
                                                  ? product.ownerName
                                                  : 'Owner',
                                              style:
                                                  theme.textTheme.titleMedium,
                                            ),
                                            if (product.isKycVerified) ...[
                                              const SizedBox(width: 4),
                                              const Icon(Icons.verified,
                                                  size: 16,
                                                  color: AppColors.accent),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(Icons.shield,
                                                size: 10,
                                                color: Color(
                                                    product.ownerBadgeColor)),
                                            const SizedBox(width: 4),
                                            Text(
                                              product.ownerTrustBadge
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  color: Color(
                                                      product.ownerBadgeColor),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.5),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                _ownerMetaText(product),
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 11,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isOwnerViewing)
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/chat-detail',
                                            arguments: {
                                              'userId': product.ownerId,
                                              'userName':
                                                  product.ownerName.isNotEmpty
                                                      ? product.ownerName
                                                      : 'Owner',
                                              'productId': product.id,
                                            });
                                      },
                                      icon: const Icon(
                                          Icons.chat_bubble_outline,
                                          color: AppColors.accent),
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppColors.accentSubtle,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isOwnerViewing) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.infoSubtle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.storefront_outlined,
                                        color: AppColors.info),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'You are viewing your own listing. Edit it from My Products and monitor incoming requests from Orders.',
                                        style: TextStyle(
                                          color: AppColors.info,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton:
              product != null && product.isAvailable && !isOwnerViewing
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: RentoButton(
                        label: AppStrings.bookNow,
                        onPressed: () => _bookNow(product),
                        icon: Icons.calendar_month_outlined,
                      ),
                    )
                  : null,
        );
      },
    );
  }

  String _ownerMetaText(ProductModel product) {
    if (product.isKycVerified) {
      return 'KYC verified owner';
    }
    if (product.ownerCreatedAt != null && product.ownerCreatedAt!.isNotEmpty) {
      final joinedAt = DateTime.tryParse(product.ownerCreatedAt!);
      if (joinedAt != null) {
        return 'Member since ${joinedAt.year}';
      }
    }
    return 'Unverified owner';
  }

  Widget _buildAppBar(ProductModel product) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (product.images.isNotEmpty)
              PageView.builder(
                itemCount: product.images.length,
                itemBuilder: (context, index) {
                  final img = product.images[index];
                  return CachedNetworkImage(
                    imageUrl: img.startsWith('/')
                        ? '${ApiConstants.baseUrl.replaceAll('/api', '')}$img'
                        : img,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: AppColors.shimmerBase,
                      highlightColor: AppColors.shimmerHighlight,
                      child: Container(color: AppColors.shimmerBase),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surface,
                      child: const Icon(Icons.inventory_2_outlined,
                          size: 60, color: AppColors.textDisabled),
                    ),
                  );
                },
              )
            else
              Container(
                color: AppColors.surface,
                child: const Icon(Icons.inventory_2_outlined,
                    size: 60, color: AppColors.textDisabled),
              ),

            // Image indicators could be added here
            if (product.images.length > 1)
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.collections_outlined,
                      color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background),
      body: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          children: [
            Container(height: 280, color: AppColors.shimmerBase),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 24, width: 200, color: AppColors.shimmerBase),
                  const SizedBox(height: 8),
                  Container(
                      height: 16, width: 120, color: AppColors.shimmerBase),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(BuildContext context, String label, String value,
      {bool isAccent = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: TextStyle(
            color: isAccent ? AppColors.accent : AppColors.textPrimary,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

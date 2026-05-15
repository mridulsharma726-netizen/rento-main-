class BookingModel {
  final String id;
  final String productId;
  final String productTitle;
  final String renterId;
  final String ownerId;
  final String startDate;
  final String endDate;
  final String status;
  final String createdAt;
  final int days;
  final double rentalAmount;
  final double deposit;
  final double totalAmount;
  final String? paymentId;
  final String? razorpayOrderId;
  final String? expiresAt;
  final String? approvedAt;
  final String? paymentStatus;
  final String? orderId;
  final double? depositAmount;
  final double? commissionAmount;
  final String? returnId;
  final String? ownerRejectionReason;

  const BookingModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.renterId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.days,
    required this.rentalAmount,
    required this.deposit,
    required this.totalAmount,
    this.paymentId,
    this.razorpayOrderId,
    this.expiresAt,
    this.approvedAt,
    this.paymentStatus,
    this.orderId,
    this.depositAmount,
    this.commissionAmount,
    this.returnId,
    this.ownerRejectionReason,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productTitle: json['product_title'] as String? ?? '',
      renterId: json['renter_id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      days: (json['days'] as num?)?.toInt() ?? 0,
      rentalAmount: (json['rental_amount'] as num?)?.toDouble() ?? 0,
      deposit: (json['deposit'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      paymentId: (json['paymentId'] ?? json['payment_id']) as String?,
      razorpayOrderId: json['razorpay_order_id'] as String?,
      expiresAt: json['expires_at'] as String?,
      approvedAt: json['approved_at'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      orderId: json['orderId'] as String?,
      depositAmount: (json['depositAmount'] as num?)?.toDouble(),
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble(),
      returnId: json['return_id'] as String?,
      ownerRejectionReason: json['owner_rejection_reason'] as String?,
    );
  }

  bool get isRequested => status == 'requested';
  bool get isApproved => status == 'approved';
  bool get isPendingPayment => status == 'approved';
  bool get isPaid => status == 'paid';
  bool get isActive => status == 'active';
  bool get isReturnPending => status == 'return_pending';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired';

  BookingModel copyWith({
    String? status,
    String? paymentStatus,
    String? returnId,
    String? expiresAt,
    String? approvedAt,
    String? ownerRejectionReason,
  }) {
    return BookingModel(
      id: id,
      productId: productId,
      productTitle: productTitle,
      renterId: renterId,
      ownerId: ownerId,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
      createdAt: createdAt,
      days: days,
      rentalAmount: rentalAmount,
      deposit: deposit,
      totalAmount: totalAmount,
      paymentId: paymentId,
      razorpayOrderId: razorpayOrderId,
      expiresAt: expiresAt ?? this.expiresAt,
      approvedAt: approvedAt ?? this.approvedAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderId: orderId,
      depositAmount: depositAmount,
      commissionAmount: commissionAmount,
      returnId: returnId ?? this.returnId,
      ownerRejectionReason: ownerRejectionReason ?? this.ownerRejectionReason,
    );
  }

  Map<String, dynamic> toMinJson() => {
        'id': id,
        'product_id': productId,
        'product_title': productTitle,
        'renter_id': renterId,
        'owner_id': ownerId,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
        'created_at': createdAt,
        'days': days,
        'rental_amount': rentalAmount,
        'deposit': deposit,
        'total_amount': totalAmount,
        'expires_at': expiresAt,
        'approved_at': approvedAt,
        'paymentStatus': paymentStatus,
        'orderId': orderId,
        'depositAmount': depositAmount,
        'commissionAmount': commissionAmount,
        'owner_rejection_reason': ownerRejectionReason,
      };
}

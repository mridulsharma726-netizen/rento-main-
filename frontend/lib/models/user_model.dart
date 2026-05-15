class UserModel {
  final String uid;
  final String? displayName;
  final String? phone;
  final String? email;
  final double? rating;
  final int? totalRatings;
  final String kycStatus;
  final int trustScore;
  final int totalTransactions;
  final int completedTransactions;
  final bool isKycVerifiedFlag;

  const UserModel({
    required this.uid,
    this.displayName,
    this.phone,
    this.email,
    this.rating,
    this.totalRatings,
    this.kycStatus = 'not_submitted',
    this.trustScore = 20,
    this.totalTransactions = 0,
    this.completedTransactions = 0,
    this.isKycVerifiedFlag = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? json['id'] as String? ?? '',
      displayName: json['name'] as String? ?? json['display_name'] as String? ?? json['displayName'] as String?,
      phone: json['phone'] as String? ?? json['phone_number'] as String?,
      email: json['email'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalRatings: (json['total_ratings'] as num?)?.toInt(),
      kycStatus: json['kyc_status'] as String? ?? 'not_submitted',
      trustScore: (json['trust_score'] as num?)?.toInt() ?? 20,
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
      completedTransactions: (json['completed_transactions'] as num?)?.toInt() ?? 0,
      isKycVerifiedFlag: json['is_kyc_verified'] as bool? ?? false,
    );
  }

  String get trustBadge {
    if (trustScore <= 30) return 'Risky';
    if (trustScore >= 71) return 'Trusted';
    return 'Average';
  }

  dynamic get badgeColor {
    if (trustScore <= 30) return 0xFFF44336; // Red
    if (trustScore >= 71) return 0xFF4CAF50; // Green
    return 0xFFFFC107; // Amber
  }

  String get displayNameOrPhone {
    if (displayName != null && displayName!.trim().isNotEmpty) return displayName!;
    if (phone != null && phone!.trim().isNotEmpty) return phone!;
    if (email != null && email!.trim().isNotEmpty) return email!;
    return 'User';
  }

  bool get isKycVerified => kycStatus == 'verified';
}

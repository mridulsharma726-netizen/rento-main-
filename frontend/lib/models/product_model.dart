class ProductModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String ownerId;
  final String ownerName;
  final int ownerTrustScore;
  final double pricePerDay;
  final double deposit;
  final List<String> images;
  final String status;
  final String createdAt;
  final String? updatedAt;
  final bool isKycVerified;
  final String? ownerCreatedAt;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.ownerId,
    required this.ownerName,
    required this.ownerTrustScore,
    required this.pricePerDay,
    required this.deposit,
    required this.images,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.isKycVerified = false,
    this.ownerCreatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String ownerId = '';
    String ownerName = '';
    int ownerTrustScore = 20;
    bool isKycVerified = false;
    String? ownerCreatedAt;

    if (json['owner_id'] is Map) {
      ownerId = json['owner_id']['id']?.toString() ??
          json['owner_id']['_id']?.toString() ??
          '';
      ownerName = json['owner_id']['name']?.toString() ?? '';
      ownerTrustScore =
          (json['owner_id']['trust_score'] as num?)?.toInt() ?? 20;
      isKycVerified = json['owner_id']['is_kyc_verified'] as bool? ?? false;
      ownerCreatedAt = json['owner_id']['created_at']?.toString() ??
          json['owner_id']['createdAt']?.toString();
    } else {
      ownerId = json['owner_id']?.toString() ?? '';
    }

    return ProductModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      ownerId: ownerId,
      ownerName: ownerName,
      ownerTrustScore: ownerTrustScore,
      pricePerDay: (json['price_per_day'] as num?)?.toDouble() ?? 0,
      deposit: (json['deposit'] as num?)?.toDouble() ?? 0,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
      isKycVerified: isKycVerified,
      ownerCreatedAt: ownerCreatedAt,
    );
  }

  // Helper for owner badge
  String get ownerTrustBadge {
    if (ownerTrustScore <= 30) return 'Risky';
    if (ownerTrustScore >= 71) return 'Trusted';
    return 'Average';
  }

  int get ownerBadgeColor {
    if (ownerTrustScore <= 30) return 0xFFF44336; // Red
    if (ownerTrustScore >= 71) return 0xFF4CAF50; // Green
    return 0xFFFFC107; // Amber
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': category,
        'price_per_day': pricePerDay,
        'deposit': deposit,
        'images': images,
        'status': status,
      };

  bool get isAvailable => status == 'available';

  String get thumbnailUrl => images.isNotEmpty ? images.first : '';

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? ownerId,
    String? ownerName,
    int? ownerTrustScore,
    double? pricePerDay,
    double? deposit,
    List<String>? images,
    String? status,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerTrustScore: ownerTrustScore ?? this.ownerTrustScore,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      deposit: deposit ?? this.deposit,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isKycVerified: isKycVerified,
      ownerCreatedAt: ownerCreatedAt,
    );
  }
}

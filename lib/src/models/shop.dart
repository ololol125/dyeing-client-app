// lib/src/models/shop.dart
class Shop {
  final int shopId;
  final String shopName;
  final String baseAddress;
  final double latitude;
  final double longitude;
  final int rootPrice;
  final int fullPrice;
  final String? description;
  final String? phone;
  final String? businessHours;

  Shop({
    required this.shopId,
    required this.shopName,
    required this.baseAddress,
    required this.latitude,
    required this.longitude,
    required this.rootPrice,
    required this.fullPrice,
    this.description,
    this.phone,
    this.businessHours,
  });

  // Next.js (Prisma) 백엔드 GET /v1/shops 응답 데이터 파싱
  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shopId: json['shopId'],
      shopName: json['shopName'],
      baseAddress: json['baseAddress'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rootPrice: json['rootPrice'],
      fullPrice: json['fullPrice'],
      description: json['description'],
      phone: json['phone'],
      businessHours: json['businessHours'],
    );
  }
}

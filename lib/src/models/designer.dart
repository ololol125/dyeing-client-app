// lib/src/models/designer.dart
class Designer {
  final int designerId;
  final String designerName;
  final String position;

  Designer({
    required this.designerId,
    required this.designerName,
    required this.position,
  });

  // Next.js (Prisma) 백엔드 GET /v1/shops/{shopId}/designers 응답 데이터 파싱
  factory Designer.fromJson(Map<String, dynamic> json) {
    return Designer(
      designerId: json['designerId'],
      designerName: json['designerName'],
      position: json['position'],
    );
  }
}

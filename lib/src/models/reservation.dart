// lib/src/models/reservation.dart
class Reservation {
  final int reservationId;
  final int shopId;
  final int clientId;
  final DateTime reservationTime;
  final String menuType; // 'ROOT_DYE' or 'FULL_DYE'
  final int totalAmount;
  final String status; // 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'NOSHOW'
  final String? notes;
  final String? paymentStatus; // 온라인 결제 상태 ('PAID' 등), 현장 결제 예약은 null

  // 백엔드 관계형 데이터(include) 매핑 필드
  final String shopName;
  final String baseAddress;
  final String designerName;
  final String designerPosition;

  Reservation({
    required this.reservationId,
    required this.shopId,
    required this.clientId,
    required this.reservationTime,
    required this.menuType,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.paymentStatus,
    required this.shopName,
    required this.baseAddress,
    required this.designerName,
    required this.designerPosition,
  });

  // Next.js (Prisma) 백엔드 응답 데이터 파싱 로직
  factory Reservation.fromJson(Map<String, dynamic> json) {
    // 1. shop 오브젝트 안전하게 추출
    final shopJson = json['shop'] as Map<String, dynamic>? ?? {};

    // 2. designers 리스트 배열에서 디자이너 정보 추출
    final designersList = json['designers'] as List<dynamic>? ?? [];
    String dName = '지정 안 함';
    String dPos = '-';

    if (designersList.isNotEmpty) {
      final designerInfo =
          designersList[0]['designer'] as Map<String, dynamic>? ?? {};
      dName = designerInfo['designerName'] ?? '지정 안 함';
      dPos = designerInfo['position'] ?? '-';
    }

    final paymentJson = json['payment'] as Map<String, dynamic>?;

    return Reservation(
      reservationId: json['reservationId'],
      shopId: json['shopId'],
      clientId: json['clientId'],
      reservationTime: DateTime.parse(json['reservationTime']),
      menuType: json['menuType'],
      totalAmount: json['totalAmount'],
      status: json['status'],
      notes: json['notes'],
      paymentStatus: paymentJson?['status'],
      shopName: shopJson['shopName'] ?? '염색방',
      baseAddress: shopJson['baseAddress'] ?? '',
      designerName: dName,
      designerPosition: dPos,
    );
  }
}

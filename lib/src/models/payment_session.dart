// 서버(/v1/payments/prepare)가 내려주는 결제창 호출 정보.
// 금액·paymentId는 서버에서 결정되므로 앱은 이 값을 그대로 결제창에 전달한다.
class PaymentSession {
  final String storeId;
  final String channelKey;
  final String payMethod; // 'CARD' or 'EASY_PAY'
  final String paymentId;
  final String orderName;
  final int totalAmount;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;

  PaymentSession({
    required this.storeId,
    required this.channelKey,
    required this.payMethod,
    required this.paymentId,
    required this.orderName,
    required this.totalAmount,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
  });

  factory PaymentSession.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>? ?? {};
    return PaymentSession(
      storeId: json['storeId'],
      channelKey: json['channelKey'],
      payMethod: json['payMethod'],
      paymentId: json['paymentId'],
      orderName: json['orderName'],
      totalAmount: json['totalAmount'],
      customerName: customer['fullName'],
      customerPhone: customer['phoneNumber'],
      customerEmail: customer['email'],
    );
  }
}

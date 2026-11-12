import 'package:flutter/material.dart';
import 'package:portone_flutter/v2.dart';
import '../../core/constants.dart';
import '../../models/payment_session.dart';

// 포트원 V2 결제창을 웹뷰로 띄우는 화면.
// 결제창이 닫히면 PaymentResponse를 결과로 pop 한다 (뒤로가기로 닫으면 null).
class PaymentScreen extends StatelessWidget {
  final PaymentSession session;

  const PaymentScreen({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PortonePayment(
      appBar: AppBar(
        title: const Text('결제하기', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      initialChild: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('결제창을 불러오는 중입니다...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      data: PaymentRequest(
        storeId: session.storeId,
        channelKey: session.channelKey,
        paymentId: session.paymentId,
        orderName: session.orderName,
        totalAmount: session.totalAmount,
        currency: Currency.KRW,
        payMethod: session.payMethod == 'EASY_PAY'
            ? PaymentPayMethod.EASY_PAY
            : PaymentPayMethod.CARD,
        appScheme: AppConstants.portoneAppScheme,
        customer: Customer(
          fullName: session.customerName,
          phoneNumber: session.customerPhone,
          email: session.customerEmail,
        ),
      ),
      callback: (PaymentResponse response) {
        Navigator.of(context).pop(response);
      },
    );
  }
}

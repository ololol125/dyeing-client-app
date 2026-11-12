// lib/src/features/booking/booking_confirm_screen.dart
import 'package:flutter/material.dart';
import 'package:portone_flutter/v2.dart';
import '../../models/designer.dart';
import '../../models/shop.dart';
import '../../services/api_service.dart';
import '../payment/payment_screen.dart';

// 예약 최종 확인 화면. 예약 내용을 검토하고 포트원으로 온라인 결제를 진행한다.
// 결제가 서버에서 검증되면 예약이 확정된다 (결제 전에는 예약이 생성되지 않음).
class BookingConfirmScreen extends StatefulWidget {
  final Shop shop;
  final Designer designer;
  final String menuType; // 'ROOT_DYE' or 'FULL_DYE'
  final DateTime reservationTime;
  final int totalAmount;

  const BookingConfirmScreen({
    Key? key,
    required this.shop,
    required this.designer,
    required this.menuType,
    required this.reservationTime,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  bool _isSubmitting = false;
  String _payMethod = 'CARD'; // 'CARD' or 'KAKAOPAY'

  String get _menuLabel => widget.menuType == 'ROOT_DYE' ? '뿌리 염색' : '전체 염색';

  String get _dateTimeLabel {
    final t = widget.reservationTime;
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[t.weekday - 1];
    return '${t.year}.${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')} ($weekday) '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '예약 확인',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '예약 내용을 확인해 주세요',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.shop.shopName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.shop.baseAddress,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _infoRow(Icons.content_cut, '시술 종류', _menuLabel),
                    const SizedBox(height: 10),
                    _infoRow(
                      Icons.person_outline,
                      '담당 디자이너',
                      '${widget.designer.designerName} (${widget.designer.position})',
                    ),
                    const SizedBox(height: 10),
                    _infoRow(Icons.calendar_today, '예약 일시', _dateTimeLabel),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '결제 금액',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${widget.totalAmount}원',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '결제 수단',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _payMethodTile('CARD', Icons.credit_card, '신용·체크카드'),
            const SizedBox(height: 8),
            _payMethodTile('KAKAOPAY', Icons.chat_bubble, '카카오페이'),
            const SizedBox(height: 12),
            Text(
              '※ 결제가 완료되면 예약이 바로 확정됩니다.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSubmitting ? null : _payAndConfirm,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '${widget.totalAmount}원 결제하기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _payMethodTile(String value, IconData icon, String label) {
    final selected = _payMethod == value;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _isSubmitting ? null : () => setState(() => _payMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Colors.indigo : Colors.grey[300]!,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? Colors.indigo : Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? Colors.indigo : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payAndConfirm() async {
    setState(() => _isSubmitting = true);

    try {
      // 1. 서버에 결제 준비 요청 (금액 계산 + 포트원 사전 등록)
      final session = await ApiService.preparePayment(
        shopId: widget.shop.shopId,
        designerId: widget.designer.designerId,
        reservationTime: widget.reservationTime,
        menuType: widget.menuType,
        payMethod: _payMethod,
      );
      if (!mounted) return;

      // 2. 포트원 결제창 호출
      final response = await Navigator.of(context).push<PaymentResponse>(
        MaterialPageRoute(builder: (_) => PaymentScreen(session: session)),
      );
      if (!mounted) return;

      if (response == null) {
        _showMessage('결제가 취소되었습니다.');
        return;
      }
      if (response.code != null) {
        _showMessage(response.message ?? '결제에 실패했습니다.');
        return;
      }

      // 3. 서버에서 결제 검증 후 예약 확정
      await ApiService.completePayment(response.paymentId);
      if (!mounted) return;

      _showMessage('결제가 완료되어 예약이 확정되었습니다!');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

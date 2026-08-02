// lib/src/features/booking/booking_confirm_screen.dart
import 'package:flutter/material.dart';
import '../../models/designer.dart';
import '../../models/shop.dart';
import '../../services/api_service.dart';

// 예약 최종 확인 화면. 매장 방문 시 현장 결제를 전제로 하며,
// 여기서는 예약 내용을 최종 검토하고 확정(서버에 예약 생성)하는 역할만 한다.
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
                    '결제 예정 금액',
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
            const SizedBox(height: 8),
            Text(
              '※ 결제는 온라인으로 진행되지 않으며, 예약된 매장 방문 시 현장에서 결제됩니다.',
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
              onPressed: _isSubmitting ? null : _confirmAndSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '예약 확정하기',
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

  Future<void> _confirmAndSubmit() async {
    setState(() => _isSubmitting = true);

    final success = await ApiService.createReservation(
      shopId: widget.shop.shopId,
      designerId: widget.designer.designerId,
      reservationTime: widget.reservationTime,
      menuType: widget.menuType,
      totalAmount: widget.totalAmount,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 확정되었습니다!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약 신청에 실패했습니다. 다시 시도해 주세요.')),
      );
    }
  }
}

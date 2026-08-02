// lib/src/features/checkout/checkout_screen.dart
import 'package:flutter/material.dart';
import '../../models/reservation.dart';
import '../../services/api_service.dart';

// DB에 별도 결제 테이블이 없어, 예약(Reservation) 데이터를 결제 내역/영수증 형태로 재구성해 보여준다.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Reservation> _receipts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reservations = await ApiService.getMyReservations();
      // 최근 결제(예약) 건이 위로 오도록 정렬
      reservations.sort((a, b) => b.reservationTime.compareTo(a.reservationTime));
      setState(() => _receipts = reservations);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '결제 및 확인',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  TextButton(onPressed: _loadReceipts, child: const Text('다시 시도')),
                ],
              ),
            )
          : _receipts.isEmpty
          ? const Center(
              child: Text(
                '결제 내역이 없습니다.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReceipts,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _receipts.length,
                itemBuilder: (context, index) => _ReceiptCard(
                  reservation: _receipts[index],
                ),
              ),
            ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final Reservation reservation;

  const _ReceiptCard({required this.reservation});

  // 예약 상태를 결제 내역 관점의 라벨/색상으로 매핑
  ({String label, Color color}) get _statusInfo {
    switch (reservation.status) {
      case 'COMPLETED':
        return (label: '결제 완료', color: Colors.green);
      case 'CONFIRMED':
        return (label: '결제 예정 (이용 전)', color: Colors.indigo);
      case 'CANCELLED':
        return (label: '취소됨', color: Colors.grey);
      case 'NOSHOW':
        return (label: '노쇼', color: Colors.redAccent);
      default:
        return (label: reservation.status, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo;
    final time = reservation.reservationTime;
    final dateStr =
        '${time.year}.${time.month.toString().padLeft(2, '0')}.${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 매장명 + 결제 상태 배지
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reservation.shopName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: status.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            _receiptRow(
              Icons.calendar_today,
              '이용 일시',
              dateStr,
            ),
            const SizedBox(height: 6),
            _receiptRow(
              Icons.content_cut,
              '시술 종류',
              reservation.menuType == 'ROOT_DYE' ? '뿌리 염색' : '전체 염색',
            ),
            const SizedBox(height: 6),
            _receiptRow(
              Icons.person_outline,
              '담당 디자이너',
              '${reservation.designerName} (${reservation.designerPosition})',
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // 하단: 결제 금액
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('총 결제 금액', style: TextStyle(color: Colors.grey)),
                Text(
                  '${reservation.totalAmount}원',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

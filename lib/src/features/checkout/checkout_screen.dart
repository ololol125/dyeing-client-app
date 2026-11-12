import 'package:flutter/material.dart';
import '../../core/format.dart';
import '../../core/messages.dart';
import '../../core/theme.dart';
import '../../models/reservation.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';

// 예약(Reservation) 데이터와 연결된 결제(payment) 상태를 결제 내역/영수증 형태로 재구성해 보여준다.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

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
      setState(() => _errorMessage = friendlyError(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('결제 내역')),
      body: _isLoading
          ? const LoadingMessage(text: '결제 내역을 불러오는 중입니다')
          : _errorMessage != null
              ? StateMessage.error(message: _errorMessage!, onRetry: _loadReceipts)
              : _receipts.isEmpty
                  ? const StateMessage(
                      icon: Icons.receipt_long_outlined,
                      title: '결제 내역이 없어요',
                      message: '예약하고 결제하시면 여기에 영수증이 보여요.',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadReceipts,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          AppSpacing.sm,
                          AppSpacing.screen,
                          AppSpacing.xxl,
                        ),
                        itemCount: _receipts.length,
                        itemBuilder: (context, index) => ContentWidth(
                          child: _ReceiptCard(reservation: _receipts[index]),
                        ),
                      ),
                    ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final Reservation reservation;

  const _ReceiptCard({required this.reservation});

  // 결제 관점의 상태 (색 + 아이콘 + 글자)
  AppStatusStyle get _paymentStatus {
    final paidOnline = reservation.paymentStatus == 'PAID';
    switch (reservation.status) {
      case 'CANCELLED':
        return const AppStatusStyle('예약 취소', Icons.cancel_outlined, AppColors.inkSub, AppColors.background);
      case 'NOSHOW':
        return const AppStatusStyle('방문 안 함', Icons.error_outline, AppColors.error, AppColors.errorSoft);
      default:
        return paidOnline || reservation.status == 'COMPLETED'
            ? const AppStatusStyle('결제 완료', Icons.check_circle_outline, AppColors.success, AppColors.successSoft)
            : const AppStatusStyle('매장에서 결제 예정', Icons.storefront_outlined, AppColors.warning, AppColors.warningSoft);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                Text(reservation.shopName, style: Theme.of(context).textTheme.titleLarge),
                StatusBadge(_paymentStatus),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.xs),
            InfoRow(
              icon: Icons.calendar_today_outlined,
              label: '이용 일시',
              value: formatDateTime(reservation.reservationTime),
            ),
            InfoRow(icon: Icons.content_cut, label: '시술', value: menuLabel(reservation.menuType)),
            InfoRow(icon: Icons.person_outline, label: '담당 선생님', value: reservation.designerName),
            const SizedBox(height: AppSpacing.xs),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            AmountRow(label: '결제 금액', amount: formatWon(reservation.totalAmount)),
          ],
        ),
      ),
    );
  }
}

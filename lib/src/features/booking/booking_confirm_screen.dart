import 'package:flutter/material.dart';
import 'package:portone_flutter/v2.dart';
import '../../core/format.dart';
import '../../core/messages.dart';
import '../../core/theme.dart';
import '../../models/designer.dart';
import '../../models/shop.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';
import '../payment/payment_screen.dart';
import 'booking_screen.dart' show kBookingTotalSteps;

// 예약 마지막 단계: 예약 내용을 큰 글씨로 다시 보여주고 포트원으로 온라인 결제를 진행한다.
// 결제가 서버에서 검증되면 예약이 확정된다 (결제 전에는 예약이 생성되지 않음).
class BookingConfirmScreen extends StatefulWidget {
  final Shop shop;
  final Designer designer;
  final String menuType; // 'ROOT_DYE' or 'FULL_DYE'
  final DateTime reservationTime;
  final int totalAmount;

  const BookingConfirmScreen({
    super.key,
    required this.shop,
    required this.designer,
    required this.menuType,
    required this.reservationTime,
    required this.totalAmount,
  });

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  bool _isSubmitting = false;
  String _payMethod = 'CARD'; // 'CARD' or 'KAKAOPAY'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('예약하기')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StepIndicator(
                  current: kBookingTotalSteps,
                  total: kBookingTotalSteps,
                  label: '확인하고 결제하기',
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionTitle('예약 내용이 맞는지 확인해 주세요'),
                _buildSummaryCard(),
                const SizedBox(height: AppSpacing.xl),
                const SectionTitle('결제 방법'),
                SelectOptionCard(
                  title: '신용카드 · 체크카드',
                  icon: Icons.credit_card,
                  selected: _payMethod == 'CARD',
                  onTap: () {
                    if (!_isSubmitting) setState(() => _payMethod = 'CARD');
                  },
                ),
                SelectOptionCard(
                  title: '카카오페이',
                  subtitle: '카카오톡이 설치된 휴대폰에서 이용',
                  icon: Icons.chat_bubble_outline,
                  selected: _payMethod == 'KAKAOPAY',
                  onTap: () {
                    if (!_isSubmitting) setState(() => _payMethod = 'KAKAOPAY');
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  '결제가 끝나면 예약이 바로 확정됩니다.\n잘못 고르셨다면 화면 위 뒤로가기를 눌러 바꿀 수 있어요.',
                  style: TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: PrimaryButton(
          label: '${formatWon(widget.totalAmount)} 결제하고 예약하기',
          isLoading: _isSubmitting,
          loadingLabel: '결제를 준비하고 있어요',
          onPressed: _payAndConfirm,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(icon: Icons.storefront_outlined, label: '매장', value: widget.shop.shopName),
            InfoRow(icon: Icons.content_cut, label: '시술', value: menuLabel(widget.menuType)),
            InfoRow(icon: Icons.person_outline, label: '담당 선생님', value: widget.designer.designerName),
            InfoRow(icon: Icons.calendar_today_outlined, label: '날짜', value: formatDate(widget.reservationTime)),
            InfoRow(
              icon: Icons.schedule,
              label: '시간',
              value: formatTime(widget.reservationTime.hour, widget.reservationTime.minute),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            AmountRow(
              label: '결제 금액',
              amount: formatWon(widget.totalAmount),
              amountSize: AppTextSize.display,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payAndConfirm() async {
    if (_isSubmitting) return;
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
        showAppMessage(context, '결제를 취소하셨어요. 예약은 되지 않았습니다.');
        return;
      }
      if (response.code != null) {
        final message = response.message ?? '';
        showAppMessage(
          context,
          message.contains('취소')
              ? '결제를 취소하셨어요. 예약은 되지 않았습니다.'
              : '결제가 완료되지 않았어요. ${friendlyError(message)}',
        );
        return;
      }

      // 3. 서버에서 결제 검증 후 예약 확정
      await ApiService.completePayment(response.paymentId);
      if (!mounted) return;

      await _showCompletedDialog();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // 예약 완료 안내: 자동으로 사라지지 않도록 대화상자로 보여준다
  Future<void> _showCompletedDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, size: 56, color: AppColors.success),
        title: const Text('예약이 확정되었어요', textAlign: TextAlign.center),
        content: Text(
          '${widget.shop.shopName}\n${formatDateTime(widget.reservationTime)}\n\n'
          '예약 내용은 아래 \'내 예약\'에서 다시 볼 수 있어요.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ),
        ],
      ),
    );
  }
}

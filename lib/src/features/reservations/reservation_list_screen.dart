import 'package:flutter/material.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/reservation.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';
import '../auth/require_login.dart';
import 'reservation_controller.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  final ReservationController _controller = ReservationController();

  bool? _loggedIn; // null: 확인 중

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateUI);
    _checkLoginAndLoad();
  }

  Future<void> _checkLoginAndLoad() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;
    setState(() => _loggedIn = loggedIn);
    if (loggedIn) _controller.fetchReservations(); // 로그인돼 있을 때만 불러오기
  }

  void _updateUI() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_updateUI);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 예약')),
      body: _loggedIn == null
          ? const LoadingMessage()
          : _loggedIn == false
              ? LoginPrompt(
                  title: '로그인하면 예약을 볼 수 있어요',
                  message: '예약하신 날짜와 시간, 매장을 한눈에 확인할 수 있어요.',
                  onLoggedIn: _checkLoginAndLoad,
                )
              : Column(
        children: [
          ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm, AppSpacing.screen, 0),
              child: Row(
                children: [
                  _buildTabButton('다가오는 예약', ReservationController.upcoming),
                  const SizedBox(width: AppSpacing.sm),
                  _buildTabButton('지난 예약', ReservationController.past),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const LoadingMessage(text: '예약 내역을 불러오는 중입니다');
    }
    if (_controller.errorMessage != null) {
      return StateMessage.error(
        message: _controller.errorMessage!,
        onRetry: _controller.fetchReservations,
      );
    }

    final reservations = _controller.filteredReservations;
    if (reservations.isEmpty) {
      final isUpcoming = _controller.currentFilter == ReservationController.upcoming;
      return StateMessage(
        icon: Icons.event_busy_outlined,
        title: isUpcoming ? '다가오는 예약이 없어요' : '지난 예약이 없어요',
        message: isUpcoming ? '\'염색방 찾기\'에서 원하는 매장을 골라 예약해 보세요.' : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.fetchReservations,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xxl),
        itemCount: reservations.length,
        itemBuilder: (context, index) => ContentWidth(
          child: _ReservationCard(reservation: reservations[index]),
        ),
      ),
    );
  }

  // 큰 탭 버튼 (선택 상태는 색 + 체크 아이콘으로)
  Widget _buildTabButton(String label, String filter) {
    final isSelected = _controller.currentFilter == filter;
    final style = isSelected
        ? FilledButton.styleFrom(minimumSize: const Size(0, kAppTouchTarget))
        : OutlinedButton.styleFrom(minimumSize: const Size(0, kAppTouchTarget));
    void onPressed() => _controller.changeFilter(filter);
    return Expanded(
      child: isSelected
          ? FilledButton.icon(
              style: style,
              onPressed: onPressed,
              icon: const Icon(Icons.check),
              label: Text(label),
            )
          : OutlinedButton(style: style, onPressed: onPressed, child: Text(label)),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final time = reservation.reservationTime;
    final status = AppStatusStyle.reservation(
      reservation.status,
      paid: reservation.paymentStatus == 'PAID',
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusBadge(status),
            const SizedBox(height: AppSpacing.md),
            // 언제 가야 하는지가 가장 중요하므로 가장 크게
            Text(
              formatDateWithRelative(time),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              formatTime(time.hour, time.minute),
              style: const TextStyle(
                fontSize: AppTextSize.title,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.xs),
            InfoRow(icon: Icons.storefront_outlined, label: '매장', value: reservation.shopName),
            InfoRow(icon: Icons.content_cut, label: '시술', value: menuLabel(reservation.menuType)),
            InfoRow(icon: Icons.person_outline, label: '담당 선생님', value: reservation.designerName),
            InfoRow(icon: Icons.payments_outlined, label: '금액', value: formatWon(reservation.totalAmount)),
          ],
        ),
      ),
    );
  }
}

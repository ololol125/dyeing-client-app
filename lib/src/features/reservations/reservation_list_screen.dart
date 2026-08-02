// lib/src/features/reservations/reservation_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'reservation_controller.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({Key? key}) : super(key: key);

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  final ReservationController _controller = ReservationController();

  @override
  void initState() {
    super.initState();
    _controller.fetchReservations(1); // 화면 켜질 때 데이터 로드
    _controller.addListener(_updateUI);
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
      appBar: AppBar(
        title: const Text(
          '내 예약 내역',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      // 화면 UI 파일 내 body: Column 부분 수정 스니펫
      body: Column(
        children: [
          Row(
            children: [
              _buildTabButton("이용 예정", "CONFIRMED"),
              _buildTabButton("이용 완료", "COMPLETED"),
            ],
          ),
          const Divider(height: 1),
          // 로딩 상태에 따라 다른 화면 연출
          Expanded(
            child: _controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  ) // 뱅글뱅글 도는 로딩 인디케이터
                : _controller.filteredReservations.isEmpty
                ? const Center(child: Text("예약 내역이 없습니다."))
                : ListView.builder(
                    itemCount: _controller.filteredReservations.length,
                    itemBuilder: (context, index) {
                      final reservation =
                          _controller.filteredReservations[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            reservation.shopName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "일시: ${reservation.reservationTime.toString().substring(0, 16)}\n시술: ${reservation.menuType == 'ROOT_DYE' ? '뿌리 염색' : '전체 염색'}",
                          ),
                          trailing: Text(
                            "${reservation.totalAmount}원",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService.logout();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildTabButton(String label, String status) {
    final isSelected = _controller.currentFilter == status;
    return Expanded(
      child: InkWell(
        onTap: () => _controller.changeFilter(status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.indigo : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.indigo : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

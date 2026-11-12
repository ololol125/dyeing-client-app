import 'package:flutter/material.dart';
import '../../core/messages.dart';
import '../../models/reservation.dart';
import '../../services/api_service.dart';

// 내 예약 목록: '다가오는 예약'(확정) / '지난 예약'(완료·취소·노쇼)으로 나눠 보여준다.
class ReservationController extends ChangeNotifier {
  static const upcoming = 'UPCOMING';
  static const past = 'PAST';

  String _currentFilter = upcoming;
  String get currentFilter => _currentFilter;

  List<Reservation> _reservations = [];
  List<Reservation> get filteredReservations {
    final list = _reservations
        .where((res) => (res.status == 'CONFIRMED') == (_currentFilter == upcoming))
        .toList();
    // 다가오는 예약은 가까운 순, 지난 예약은 최근 순
    list.sort((a, b) => _currentFilter == upcoming
        ? a.reservationTime.compareTo(b.reservationTime)
        : b.reservationTime.compareTo(a.reservationTime));
    return list;
  }

  // 화면 로딩 상태 제어 변수
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void changeFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // 실제 백엔드 API 연동
  Future<void> fetchReservations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reservations = await ApiService.getMyReservations();
    } catch (e) {
      debugPrint('데이터를 가져오는 중 오류 발생: $e');
      _errorMessage = friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

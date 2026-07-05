// lib/src/features/reservations/reservation_controller.dart
import 'package:flutter/material.dart';
import '../../models/reservation.dart';
import '../../services/api_service.dart';

class ReservationController extends ChangeNotifier {
  String _currentFilter = 'CONFIRMED';
  String get currentFilter => _currentFilter;

  List<Reservation> _reservations = [];
  List<Reservation> get filteredReservations =>
      _reservations.where((res) => res.status == _currentFilter).toList();

  // 화면 로딩 상태 제어 변수
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void changeFilter(String newStatus) {
    _currentFilter = newStatus;
    notifyListeners();
  }

  // 실제 백엔드 API 연동
  Future<void> fetchReservations(int clientId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // ApiService를 호출하여 데이터베이스 데이터를 동기화
      _reservations = await ApiService.getMyReservations();
    } catch (e) {
      debugPrint('데이터를 가져오는 중 오류 발생: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// lib/src/features/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'checkout/checkout_screen.dart';
import 'reservations/reservation_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // 현재 선택된 하단 탭의 인덱스
  int _currentIndex = 0;

  // 바텀 네비게이션바로 연결할 화면들 리스트
  final List<Widget> _screens = [
    const HomeScreen(),
    const CheckoutScreen(),
    const ReservationListScreen(), // 이전에 만든 예약 내역 화면을 '마이 예약' 탭으로 활용
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 인덱스에 해당하는 화면을 본문에 띄워줌
      body: _screens[_currentIndex],

      // 하단 네비게이션 바 디자인
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // 탭 클릭 시 화면 전환
          });
        },
        type: BottomNavigationBarType.fixed, // 탭이 3개 이상일 때 스타일 고정
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈 탐색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            activeIcon: Icon(Icons.credit_card),
            label: '결제/확인',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: '예약관리',
          ),
        ],
      ),
    );
  }
}

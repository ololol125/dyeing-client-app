// lib/src/features/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'checkout/checkout_screen.dart';
import 'reservations/reservation_list_screen.dart';
import 'account/my_info_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // 현재 선택된 하단 탭의 인덱스
  int _currentIndex = 0;

  // 바텀 네비게이션바로 연결할 화면들 리스트
  final List<Widget> _screens = const [
    HomeScreen(),
    ReservationListScreen(),
    CheckoutScreen(),
    MyInfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      // 하단 메뉴: 아이콘과 글자를 항상 함께, 쉬운 이름으로 (스타일은 theme.dart)
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: '염색방 찾기',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: '내 예약',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: '결제 내역',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
      ),
    );
  }
}

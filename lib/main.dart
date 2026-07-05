import 'package:flutter/material.dart';
import 'src/features/main_navigation_screen.dart'; // 허브 파일 임포트

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '염색방 예약 시스템',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo, // 구글 머티리얼3 디자인 기준 색상 설정
      ),
      home: const MainNavigationScreen(),
    );
  }
}

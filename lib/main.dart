import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'src/core/constants.dart';
import 'src/features/auth/login_screen.dart';
import 'src/features/main_navigation_screen.dart'; // 허브 파일 임포트
import 'src/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 네이버 지도 SDK는 Android/iOS 네이티브 전용이라 그 외 플랫폼(Web/데스크톱)에서는 초기화를 건너뜀
  final isMobilePlatform =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  if (isMobilePlatform) {
    // 첫 NaverMap 위젯이 뜨기 전에 반드시 완료돼야 함
    await FlutterNaverMap().init(
      clientId: AppConstants.naverMapClientId,
      onAuthFailed: (ex) {
        debugPrint('🚨 네이버 지도 인증 실패: $ex');
      },
    );
  }

  // 토큰 만료로 세션이 끊기면 어느 화면에 있든 로그인 화면으로 이동
  AuthService.onSessionExpired = () {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    ScaffoldMessenger.of(navigator.context).showSnackBar(
      const SnackBar(content: Text('로그인이 만료되었습니다. 다시 로그인해 주세요.')),
    );
  };

  runApp(const MainApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '염색방 예약 시스템',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo, // 구글 머티리얼3 디자인 기준 색상 설정
      ),
      home: const AuthGate(),
    );
  }
}

// 앱 시작 시 저장된 토큰 유무를 확인해 로그인 화면 또는 메인 화면으로 분기
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == true
            ? const MainNavigationScreen()
            : const LoginScreen();
      },
    );
  }
}

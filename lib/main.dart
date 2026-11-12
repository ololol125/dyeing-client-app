import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'src/core/constants.dart';
import 'src/core/theme.dart';
import 'src/core/messages.dart';
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

  // 토큰 만료로 세션이 끊기면 첫 화면으로 돌아가 안내 (둘러보기는 로그인 없이 가능)
  AuthService.onSessionExpired = () {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
    showAppMessage(navigator.context, '로그인이 만료되었어요. 예약하시려면 다시 로그인해 주세요.');
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
      theme: AppTheme.light,
      // 복사·붙여넣기 메뉴 등 기본 안내 문구도 한국어로
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 기기의 '글자 크게' 설정은 따르되, 화면이 깨지지 않도록 최대 1.6배로 제한
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.6,
        child: child!,
      ),
      // 매장 둘러보기는 로그인 없이 가능, 예약·내역 확인 때만 로그인 요청
      home: const MainNavigationScreen(),
    );
  }
}

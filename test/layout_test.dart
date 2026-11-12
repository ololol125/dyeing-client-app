import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dyeing_client_app/src/core/theme.dart';
import 'package:dyeing_client_app/src/features/account/my_info_screen.dart';
import 'package:dyeing_client_app/src/features/auth/login_screen.dart';
import 'package:dyeing_client_app/src/features/auth/signup_screen.dart';
import 'package:dyeing_client_app/src/features/booking/booking_confirm_screen.dart';
import 'package:dyeing_client_app/src/models/designer.dart';
import 'package:dyeing_client_app/src/models/shop.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 작은 휴대폰(360x640)에서 기기 글자 크기를 최대(1.6배)로 키워도
// 화면이 넘치지(overflow) 않는지 확인한다.
Future<void> _loadFonts() async {
  final loader = FontLoader('Pretendard');
  for (final w in ['Regular', 'SemiBold', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/Pretendard-$w.otf'));
  }
  await loader.load();
}

Widget _wrap(Widget screen, double scale) => MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(size: const Size(360, 640), textScaler: TextScaler.linear(scale)),
        child: screen,
      ),
    );

final _shop = Shop(
  shopId: 1,
  shopName: '영현 바버샵',
  baseAddress: '서울특별시 관악구 신림동 1554-29',
  latitude: 37.48,
  longitude: 126.93,
  rootPrice: 6000,
  fullPrice: 10000,
);

void main() {
  setUpAll(_loadFonts);
  // 로그인하지 않은 상태(저장된 토큰 없음)로 화면을 그린다
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final screens = <String, Widget>{
    '로그인': const LoginScreen(),
    '회원가입': const SignupScreen(),
    '내 정보(로그인 전)': const MyInfoScreen(),
    '예약 확인': BookingConfirmScreen(
      shop: _shop,
      designer: Designer(designerId: 1, designerName: '박 디자이너', position: '원장'),
      menuType: 'FULL_DYE',
      reservationTime: DateTime(2026, 11, 14, 14, 30),
      totalAmount: 10000,
    ),
  };

  for (final scale in [1.0, 1.6]) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} 화면 - 글자 $scale배', (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_wrap(entry.value, scale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}

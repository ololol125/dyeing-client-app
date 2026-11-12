import 'package:flutter/material.dart';

// 염색온 디자인 시스템 (시안 B: 따뜻한 밤색)
//
// 주 사용자는 40~80대. 노안과 스마트폰 미숙을 기준으로 설계한다.
// - 본문 18sp 이상, 버튼·제목 20~24sp
// - 글자 대비 WCAG AA 이상 (아래 색은 모두 실측 7:1 이상, 상태색 5.4:1 이상)
// - 누르는 영역 최소 56dp
// - 아이콘은 항상 글자와 함께, 상태는 색 + 글자로 표시
// 웹(dyeing-shop-saas)의 Tailwind 토큰(src/app/globals.css)과 같은 값을 쓴다.

class AppColors {
  AppColors._();

  // 브랜드 (밤색)
  static const primary = Color(0xFF6E3B2A); // 흰 글씨 대비 9.0
  static const primaryPressed = Color(0xFF572E20);
  static const primarySoft = Color(0xFFF3E9E2); // 선택된 항목 배경 (위 글씨 대비 7.6)

  // 배경·면
  static const background = Color(0xFFFAF7F3);
  static const surface = Color(0xFFFFFFFF);

  // 글자 (연한 회색 글씨는 쓰지 않는다)
  static const ink = Color(0xFF231B17); // 본문 (배경 대비 15.8)
  static const inkSub = Color(0xFF55483F); // 보조 설명 (배경 대비 8.2)

  // 선
  static const line = Color(0xFFE3D8CF); // 카드 테두리, 구분선 (장식용)
  static const lineStrong = Color(0xFF8C7466); // 입력창 테두리 (배경 대비 4.1)

  // 상태 (글씨색 / 배경색) - 항상 아이콘·글자와 함께 사용
  static const success = Color(0xFF1E6B37);
  static const successSoft = Color(0xFFE3F1E7);
  static const warning = Color(0xFF8A4B00);
  static const warningSoft = Color(0xFFFBEBD5);
  static const error = Color(0xFFB3261E);
  static const errorSoft = Color(0xFFFBE4E2);
  static const info = Color(0xFF1F4E79);
  static const infoSoft = Color(0xFFE6EEF6);
}

// 글자 크기 단계 (sp). 이보다 작은 글씨는 쓰지 않는다.
class AppTextSize {
  AppTextSize._();

  static const double display = 28; // 화면 큰 제목, 금액 강조
  static const double title = 24; // 화면 제목
  static const double heading = 22; // 카드 제목, 앱바
  static const double button = 20; // 버튼, 강조 항목
  static const double body = 18; // 본문 (최소 기준)
  static const double caption = 16; // 보조 설명, 배지 (예외적으로만)
}

// 간격 단위 (dp)
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  // 화면 좌우 여백
  static const double screen = 20;
}

// 모서리 둥글기
class AppRadius {
  AppRadius._();

  static const double sm = 8; // 배지, 작은 칩
  static const double md = 12; // 버튼, 입력창
  static const double lg = 16; // 카드, 다이얼로그
}

// 누르는 영역 최소 높이
const double kAppTouchTarget = 56;

// 예약 상태 → 색·아이콘·글자 (색만으로 구분하지 않도록 세트로 사용)
class AppStatusStyle {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;

  const AppStatusStyle(this.label, this.icon, this.foreground, this.background);

  static AppStatusStyle reservation(String status, {bool paid = false}) {
    switch (status) {
      case 'CONFIRMED':
        return AppStatusStyle(
          paid ? '결제 완료 · 예약 확정' : '예약 확정',
          Icons.check_circle_outline,
          AppColors.success,
          AppColors.successSoft,
        );
      case 'COMPLETED':
        return const AppStatusStyle(
          '시술 완료',
          Icons.done_all,
          AppColors.info,
          AppColors.infoSoft,
        );
      case 'CANCELLED':
        return const AppStatusStyle(
          '예약 취소',
          Icons.cancel_outlined,
          AppColors.inkSub,
          AppColors.background,
        );
      case 'NOSHOW':
        return const AppStatusStyle(
          '방문 안 함',
          Icons.error_outline,
          AppColors.error,
          AppColors.errorSoft,
        );
      default:
        return AppStatusStyle(
          status,
          Icons.info_outline,
          AppColors.inkSub,
          AppColors.background,
        );
    }
  }
}

class AppTheme {
  AppTheme._();

  static const _fontFamily = 'Pretendard';

  static const _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.primaryPressed,
    secondary: AppColors.inkSub,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.primarySoft,
    onSecondaryContainer: AppColors.ink,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorSoft,
    onErrorContainer: AppColors.error,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.inkSub,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.background,
    surfaceContainer: AppColors.background,
    surfaceContainerHigh: AppColors.primarySoft,
    surfaceContainerHighest: AppColors.primarySoft,
    outline: AppColors.lineStrong,
    outlineVariant: AppColors.line,
  );

  // 줄간격은 한글 가독성을 위해 1.5 내외
  static const _textTheme = TextTheme(
    displaySmall: TextStyle(fontSize: AppTextSize.display, fontWeight: FontWeight.w700, height: 1.35),
    headlineMedium: TextStyle(fontSize: AppTextSize.display, fontWeight: FontWeight.w700, height: 1.35),
    headlineSmall: TextStyle(fontSize: AppTextSize.title, fontWeight: FontWeight.w700, height: 1.4),
    titleLarge: TextStyle(fontSize: AppTextSize.heading, fontWeight: FontWeight.w700, height: 1.4),
    titleMedium: TextStyle(fontSize: AppTextSize.button, fontWeight: FontWeight.w600, height: 1.45),
    titleSmall: TextStyle(fontSize: AppTextSize.body, fontWeight: FontWeight.w600, height: 1.5),
    bodyLarge: TextStyle(fontSize: AppTextSize.body, fontWeight: FontWeight.w400, height: 1.55),
    bodyMedium: TextStyle(fontSize: AppTextSize.body, fontWeight: FontWeight.w400, height: 1.55),
    bodySmall: TextStyle(fontSize: AppTextSize.caption, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.inkSub),
    labelLarge: TextStyle(fontSize: AppTextSize.button, fontWeight: FontWeight.w700, height: 1.3),
    labelMedium: TextStyle(fontSize: AppTextSize.caption, fontWeight: FontWeight.w600, height: 1.3),
    labelSmall: TextStyle(fontSize: AppTextSize.caption, fontWeight: FontWeight.w600, height: 1.3),
  );

  static final _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
  );
  static const _buttonPadding = EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md);
  static const _buttonText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppTextSize.button,
    fontWeight: FontWeight.w700,
  );

  static OutlineInputBorder _inputBorder(Color color, [double width = 1.5]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      fontFamily: _fontFamily,
      textTheme: _textTheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      // 터치 영역이 줄어들지 않도록 표준 밀도 + 최소 터치 크기 유지
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkRipple.splashFactory,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 64,
        iconTheme: IconThemeData(size: 28, color: AppColors.ink),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: AppTextSize.heading,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.line),
        ),
      ),

      // 주요 버튼: 화면당 하나, 색이 채워진 버튼
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(kAppTouchTarget * 2, kAppTouchTarget),
          padding: _buttonPadding,
          shape: _buttonShape,
          textStyle: _buttonText,
          iconSize: 24,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(kAppTouchTarget * 2, kAppTouchTarget),
          padding: _buttonPadding,
          shape: _buttonShape,
          textStyle: _buttonText,
          iconSize: 24,
        ),
      ),
      // 보조 버튼: 굵은 테두리
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(kAppTouchTarget * 2, kAppTouchTarget),
          padding: _buttonPadding,
          shape: _buttonShape,
          side: const BorderSide(color: AppColors.primary, width: 2),
          textStyle: _buttonText,
          iconSize: 24,
        ),
      ),
      // 글자 버튼도 누르는 영역은 56dp 확보
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(kAppTouchTarget, kAppTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: _buttonShape,
          textStyle: _buttonText.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(kAppTouchTarget, kAppTouchTarget),
          iconSize: 28,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 18),
        labelStyle: const TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
        floatingLabelStyle: const TextStyle(fontSize: AppTextSize.body, color: AppColors.primary, fontWeight: FontWeight.w600),
        // 안내 문구도 본문과 같은 색 계열로 (연한 회색 금지)
        hintStyle: const TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
        helperStyle: const TextStyle(fontSize: AppTextSize.caption, color: AppColors.inkSub),
        errorStyle: const TextStyle(fontSize: AppTextSize.caption, color: AppColors.error, fontWeight: FontWeight.w600),
        prefixIconColor: AppColors.inkSub,
        suffixIconColor: AppColors.inkSub,
        border: _inputBorder(AppColors.lineStrong),
        enabledBorder: _inputBorder(AppColors.lineStrong),
        focusedBorder: _inputBorder(AppColors.primary, 2.5),
        errorBorder: _inputBorder(AppColors.error, 2),
        focusedErrorBorder: _inputBorder(AppColors.error, 2.5),
      ),

      // 시간 선택 등 칩: 선택 여부를 색 + 체크 아이콘으로 표시
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySoft,
        checkmarkColor: AppColors.primary,
        showCheckmark: true,
        labelStyle: const TextStyle(fontSize: AppTextSize.body, fontWeight: FontWeight.w600, color: AppColors.ink),
        secondaryLabelStyle: const TextStyle(fontSize: AppTextSize.body, fontWeight: FontWeight.w700, color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        side: const BorderSide(color: AppColors.lineStrong, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.primary : AppColors.lineStrong,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent,
        ),
        side: const BorderSide(color: AppColors.lineStrong, width: 2),
      ),

      listTileTheme: const ListTileThemeData(
        minVerticalPadding: AppSpacing.md,
        minTileHeight: kAppTouchTarget,
        iconColor: AppColors.inkSub,
        titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: AppTextSize.body, fontWeight: FontWeight.w600, color: AppColors.ink),
        subtitleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: AppTextSize.caption, color: AppColors.inkSub),
      ),

      // 하단 메뉴: 아이콘과 글자를 항상 함께 표시
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primarySoft,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 28,
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.inkSub,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: _fontFamily,
            fontSize: AppTextSize.caption,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.inkSub,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.inkSub,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedIconTheme: IconThemeData(size: 28),
        unselectedIconTheme: IconThemeData(size: 28),
        selectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: AppTextSize.caption, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: AppTextSize.caption, fontWeight: FontWeight.w500),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        titleTextStyle: const TextStyle(fontFamily: _fontFamily, fontSize: AppTextSize.heading, fontWeight: FontWeight.w700, color: AppColors.ink),
        contentTextStyle: const TextStyle(fontFamily: _fontFamily, fontSize: AppTextSize.body, height: 1.55, color: AppColors.ink),
      ),

      // 안내 메시지: 화면 아래 떠 있는 형태, 큰 글씨
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(fontFamily: _fontFamily, fontSize: AppTextSize.body, color: Colors.white, height: 1.45),
        actionTextColor: AppColors.primarySoft,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primarySoft,
        selectionHandleColor: AppColors.primary,
      ),
    );
  }
}

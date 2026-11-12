import 'package:flutter/material.dart';

// 서비스 계층의 예외 메시지를 사용자에게 보여줄 쉬운 말로 바꾼다.
// 서버가 내려준 한국어 안내(예: "결제가 완료되지 않았습니다.")는 그대로 쓰고,
// 상태 코드·영문 예외처럼 기술적인 내용은 일반 안내 문구로 대체한다.
String friendlyError(Object error) {
  var message = error.toString();
  while (message.startsWith('Exception: ')) {
    message = message.substring('Exception: '.length);
  }
  // "예약 내역 동기화 실패: Exception: 실제 메시지" 형태는 마지막 메시지만 사용
  final nested = message.lastIndexOf('Exception: ');
  if (nested >= 0) message = message.substring(nested + 'Exception: '.length);

  final lower = message.toLowerCase();
  if (lower.contains('socketexception') ||
      lower.contains('clientexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('network') ||
      message.contains('네트워크')) {
    return '인터넷 연결을 확인한 뒤 다시 시도해 주세요.';
  }
  final looksTechnical = message.contains('코드:') ||
      RegExp(r'[A-Za-z]{6,}').hasMatch(message) ||
      message.trim().isEmpty;
  if (looksTechnical) {
    return '잠시 후 다시 시도해 주세요. 계속 안 되면 매장으로 전화 주세요.';
  }
  return message;
}

// 화면 아래 안내 메시지. 천천히 읽을 수 있도록 5초 동안 보여주고 '확인' 버튼을 둔다.
void showAppMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(label: '확인', onPressed: messenger.hideCurrentSnackBar),
    ),
  );
}

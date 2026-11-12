import 'package:flutter_test/flutter_test.dart';
import 'package:dyeing_client_app/src/core/format.dart';
import 'package:dyeing_client_app/src/core/messages.dart';

void main() {
  test('금액 표기', () {
    expect(formatWon(0), '0원');
    expect(formatWon(6000), '6,000원');
    expect(formatWon(1234567), '1,234,567원');
  });

  test('오전/오후 시간 표기', () {
    expect(formatTime(10, 0), '오전 10시');
    expect(formatTime(12, 0), '오후 12시');
    expect(formatTime(14, 30), '오후 2시 30분');
    expect(formatTime(0, 0), '오전 12시');
  });

  test('날짜·상대 날짜 표기', () {
    final now = DateTime(2026, 11, 13, 9); // 금요일
    expect(formatDate(DateTime(2026, 11, 14)), '11월 14일 (토)');
    expect(formatDateWithRelative(DateTime(2026, 11, 13), now: now), '오늘 · 11월 13일 (금)');
    expect(formatDateWithRelative(DateTime(2026, 11, 14, 14, 30), now: now), '내일 · 11월 14일 (토)');
    expect(formatDateWithRelative(DateTime(2026, 11, 20), now: now), '11월 20일 (금)');
  });

  test('오류 메시지를 쉬운 말로', () {
    expect(friendlyError(Exception('결제가 완료되지 않았습니다.')), '결제가 완료되지 않았습니다.');
    expect(
      friendlyError(Exception('예약 내역 동기화 실패: Exception: 서버 오류가 발생했습니다. (코드: 500)')),
      '잠시 후 다시 시도해 주세요. 계속 안 되면 매장으로 전화 주세요.',
    );
    expect(
      friendlyError(Exception('매장 목록 조회 실패: ClientException with SocketException: Failed host lookup')),
      '인터넷 연결을 확인한 뒤 다시 시도해 주세요.',
    );
    expect(friendlyError(Exception('이메일 또는 비밀번호가 올바르지 않습니다.')), '이메일 또는 비밀번호가 올바르지 않습니다.');
  });
}

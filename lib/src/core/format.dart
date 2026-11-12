// 중장년층이 읽기 쉬운 한국어 표기 모음 (오전/오후, 요일, 천 단위 쉼표)

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

// 6000 → "6,000원"
String formatWon(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}$buffer원';
}

// → "11월 14일 (금)"
String formatDate(DateTime date) =>
    '${date.month}월 ${date.day}일 (${_weekdays[date.weekday - 1]})';

// → "오후 2시 30분", "오전 10시"
String formatTime(int hour, int minute) {
  final period = hour < 12 ? '오전' : '오후';
  final h12 = hour % 12 == 0 ? 12 : hour % 12;
  return minute == 0 ? '$period $h12시' : '$period $h12시 $minute분';
}

// → "11월 14일 (금) 오후 2시 30분"
String formatDateTime(DateTime dateTime) =>
    '${formatDate(dateTime)} ${formatTime(dateTime.hour, dateTime.minute)}';

// 오늘/내일/모레는 앞에 붙여서 헷갈리지 않게 → "내일 · 11월 14일 (금)"
String formatDateWithRelative(DateTime date, {DateTime? now}) {
  final today = _dateOnly(now ?? DateTime.now());
  final diff = _dateOnly(date).difference(today).inDays;
  const relative = {0: '오늘', 1: '내일', 2: '모레'};
  final prefix = relative[diff];
  return prefix == null ? formatDate(date) : '$prefix · ${formatDate(date)}';
}

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// 'ROOT_DYE' → "뿌리 염색"
String menuLabel(String menuType) => menuType == 'ROOT_DYE' ? '뿌리 염색' : '전체 염색';

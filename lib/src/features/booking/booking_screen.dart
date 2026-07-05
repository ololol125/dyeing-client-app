// lib/src/features/booking/booking_screen.dart
import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  final String shopName;

  const BookingScreen({Key? key, required this.shopName}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // 1. 시술 메뉴 상태 관리 (DB의 menu_type 스키마와 1:1 매핑)
  String _selectedMenuType = 'ROOT_DYE'; // 기본값: 뿌리 염색

  // 가상의 매장 가격 데이터 (실제 연동 시 shop 테이블의 root_price, full_price 컬럼에서 받아옴)
  final int _rootPrice = 29000;
  final int _fullPrice = 59000;

  // 2. 예약 날짜 및 시간 상태 관리
  DateTime _selectedDate = DateTime.now().add(
    const Duration(days: 1),
  ); // 기본값: 내일
  String? _selectedTimeSlot; // 선택된 시간 타임셋

  // 예약 가능한 시간 타임 슬롯 리스트
  final List<String> _timeSlots = [
    "10:00",
    "11:30",
    "13:00",
    "14:30",
    "16:00",
    "17:30",
    "19:00",
  ];

  @override
  Widget build(BuildContext context) {
    // 선택된 메뉴에 따라 결제 금액 실시간 계산 (DB의 total_amount 조건 충족)
    int totalAmount = _selectedMenuType == 'ROOT_DYE' ? _rootPrice : _fullPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '예약 및 시술 선택',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 선택 매장 타이틀
                  Text(
                    widget.shopName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🎨 섹션 1: 시술 메뉴 선택 (라디오 형태)
                  const Text(
                    '1. 시술 종류 선택',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('뿌리 염색 (Root Dyeing)'),
                          subtitle: Text('$_rootPrice원 / 기장 제한 없음'),
                          value: 'ROOT_DYE',
                          groupValue: _selectedMenuType,
                          activeColor: Colors.indigo,
                          onChanged: (value) {
                            setState(() {
                              _selectedMenuType = value!;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        RadioListTile<String>(
                          title: const Text('전체 염색 (Full Dyeing)'),
                          subtitle: Text('$_fullPrice원 / 단발 기준 (기장 추가 발생 가능)'),
                          value: 'FULL_DYE',
                          groupValue: _selectedMenuType,
                          activeColor: Colors.indigo,
                          onChanged: (value) {
                            setState(() {
                              _selectedMenuType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 📅 섹션 2: 날짜 선택
                  const Text(
                    '2. 예약 날짜 선택',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      // 플러터 내장 날짜 선택 모달창 띄우기
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 30),
                        ), // 한 달 뒤까지만 예약 허용
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.indigo,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ⏰ 섹션 3: 시간 선택 (Chip 위젯 배치)
                  const Text(
                    '3. 예약 시간 선택',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0, // 가로 공간 여백
                    runSpacing: 4.0, // 세로 줄바꿈 공간 여백
                    children: _timeSlots.map((time) {
                      final isSelected = _selectedTimeSlot == time;
                      return ChoiceChip(
                        label: Text(time),
                        selected: isSelected,
                        selectedColor: Colors.indigo,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedTimeSlot = selected ? time : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // 💳 하단 결제 금액 확인 및 최종 예약 버튼 고정 영역
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200]!,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // 실시간 총 결제금액 표시
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '최종 결제 금액',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        '$totalAmount원',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // 예약 완료 처리 액션 버튼
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTimeSlot == null
                              ? Colors.grey[400]
                              : Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // 시간을 무조건 골라야만 버튼이 활성화되도록 방어 코딩
                        onPressed: _selectedTimeSlot == null
                            ? null
                            : () {
                                _submitBooking(totalAmount);
                              },
                        child: const Text(
                          '예약 신청하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 예약을 최종 확정 지을 때 호출되는 가상 로직 함수
  void _submitBooking(int finalAmount) {
    // 날짜 스트링과 시간 슬롯 스트링 결합 연산
    String appointmentTimeStr =
        "${_selectedDate.toString().substring(0, 10)} ${_selectedTimeSlot!}:00";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 확인'),
        content: Text(
          '시술 종류: ${_selectedMenuType == 'ROOT_DYE' ? '뿌리 염색' : '전체 염색'}\n일시: $appointmentTimeStr\n금액: ${finalAmount}원으로 신청하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 팝업 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('예약 요청이 성공적으로 완료되었습니다!')),
              );
              Navigator.pop(context); // 홈 화면으로 귀환
            },
            child: const Text(
              '확정',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

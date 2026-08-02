// lib/src/features/booking/booking_screen.dart
import 'package:flutter/material.dart';
import '../../models/designer.dart';
import '../../models/shop.dart';
import '../../services/shop_service.dart';
import 'booking_confirm_screen.dart';

class BookingScreen extends StatefulWidget {
  final Shop shop;

  const BookingScreen({Key? key, required this.shop}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // 1. 시술 메뉴 상태 관리 (DB의 menu_type 스키마와 1:1 매핑)
  String _selectedMenuType = 'ROOT_DYE'; // 기본값: 뿌리 염색

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

  // 3. 디자이너 목록 상태 관리 (실제 DB 연동)
  List<Designer> _designers = [];
  Designer? _selectedDesigner;
  bool _isLoadingDesigners = true;
  String? _designerError;

  @override
  void initState() {
    super.initState();
    _loadDesigners();
  }

  Future<void> _loadDesigners() async {
    setState(() {
      _isLoadingDesigners = true;
      _designerError = null;
    });

    try {
      final designers = await ShopService.getDesigners(widget.shop.shopId);
      setState(() => _designers = designers);
    } catch (e) {
      setState(() {
        _designerError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _isLoadingDesigners = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 메뉴에 따라 결제 금액 실시간 계산 (DB의 total_amount 조건 충족)
    final int totalAmount = _selectedMenuType == 'ROOT_DYE'
        ? widget.shop.rootPrice
        : widget.shop.fullPrice;

    final bool canSubmit =
        _selectedTimeSlot != null && _selectedDesigner != null;

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
                    widget.shop.shopName,
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
                          subtitle: Text('${widget.shop.rootPrice}원 / 기장 제한 없음'),
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
                          subtitle: Text(
                            '${widget.shop.fullPrice}원 / 단발 기준 (기장 추가 발생 가능)',
                          ),
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

                  // 👤 섹션 2: 디자이너 선택 (실제 DB 연동)
                  const Text(
                    '2. 담당 디자이너 선택',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDesignerSection(),
                  const SizedBox(height: 24),

                  // 📅 섹션 3: 날짜 선택
                  const Text(
                    '3. 예약 날짜 선택',
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

                  // ⏰ 섹션 4: 시간 선택 (Chip 위젯 배치)
                  const Text(
                    '4. 예약 시간 선택',
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
                          backgroundColor: canSubmit
                              ? Colors.indigo
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // 디자이너·시간을 모두 골라야만 버튼이 활성화되도록 방어 코딩
                        onPressed: canSubmit
                            ? () => _goToConfirmScreen(totalAmount)
                            : null,
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

  Widget _buildDesignerSection() {
    if (_isLoadingDesigners) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_designerError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_designerError!, style: const TextStyle(color: Colors.grey)),
          TextButton(onPressed: _loadDesigners, child: const Text('다시 시도')),
        ],
      );
    }

    if (_designers.isEmpty) {
      return const Text(
        '현재 예약 가능한 디자이너가 없습니다.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _designers.map((designer) {
        final isSelected = _selectedDesigner?.designerId == designer.designerId;
        return ChoiceChip(
          label: Text('${designer.designerName} · ${designer.position}'),
          selected: isSelected,
          selectedColor: Colors.indigo,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (selected) {
            setState(() {
              _selectedDesigner = selected ? designer : null;
            });
          },
        );
      }).toList(),
    );
  }

  // 예약 확인 화면으로 이동 (실제 예약 생성은 해당 화면에서 처리)
  void _goToConfirmScreen(int finalAmount) {
    final timeParts = _selectedTimeSlot!.split(':');
    final reservationTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmScreen(
          shop: widget.shop,
          designer: _selectedDesigner!,
          menuType: _selectedMenuType,
          reservationTime: reservationTime,
          totalAmount: finalAmount,
        ),
      ),
    );
  }
}

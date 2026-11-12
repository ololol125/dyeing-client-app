import 'package:flutter/material.dart';
import '../../core/format.dart';
import '../../core/messages.dart';
import '../../core/theme.dart';
import '../../models/designer.dart';
import '../../models/shop.dart';
import '../../services/shop_service.dart';
import '../../widgets/app_widgets.dart';
import 'booking_confirm_screen.dart';

// 예약 화면: 한 화면에 한 가지만 묻는다.
// 1 시술 → 2 담당 선생님 → 3 날짜 → 4 시간 → (5 예약 확인·결제: BookingConfirmScreen)
const kBookingTotalSteps = 5;

class BookingScreen extends StatefulWidget {
  final Shop shop;

  const BookingScreen({super.key, required this.shop});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const _stepLabels = ['시술 고르기', '담당 선생님 고르기', '날짜 고르기', '시간 고르기'];

  // 예약 가능한 날짜 범위 (오늘부터 2주)
  static const _bookableDays = 14;

  // 예약 가능한 시간 (매장 공통)
  static const List<String> _timeSlots = [
    '10:00',
    '11:30',
    '13:00',
    '14:30',
    '16:00',
    '17:30',
    '19:00',
  ];

  int _step = 0; // 0부터 시작 (화면 표시는 +1)

  // 1. 시술 메뉴 (DB의 menu_type과 1:1 매핑)
  String? _selectedMenuType;

  // 2. 담당 선생님 (디자이너)
  List<Designer> _designers = [];
  Designer? _selectedDesigner;
  bool _isLoadingDesigners = true;
  String? _designerError;

  // 3·4. 날짜와 시간
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

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
      setState(() {
        _designers = designers;
        // 선생님이 한 분뿐이면 미리 골라 둔다
        if (designers.length == 1) _selectedDesigner = designers.first;
      });
    } catch (e) {
      setState(() => _designerError = friendlyError(e));
    } finally {
      setState(() => _isLoadingDesigners = false);
    }
  }

  int get _totalAmount =>
      _selectedMenuType == 'FULL_DYE' ? widget.shop.fullPrice : widget.shop.rootPrice;

  DateTime _slotDateTime(DateTime date, String slot) {
    final parts = slot.split(':');
    return DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  // 오늘은 이미 지난 시간을 빼고 보여준다 (30분 여유)
  List<String> _availableSlots(DateTime date) {
    final limit = DateTime.now().add(const Duration(minutes: 30));
    return _timeSlots.where((slot) => _slotDateTime(date, slot).isAfter(limit)).toList();
  }

  List<DateTime> get _bookableDates {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(_bookableDays, (i) => today.add(Duration(days: i)))
        .where((date) => _availableSlots(date).isNotEmpty)
        .toList();
  }

  void _goNext() {
    final missing = switch (_step) {
      0 when _selectedMenuType == null => '받으실 시술을 먼저 골라 주세요.',
      1 when _selectedDesigner == null => '담당 선생님을 먼저 골라 주세요.',
      2 when _selectedDate == null => '예약할 날짜를 먼저 골라 주세요.',
      3 when _selectedTimeSlot == null => '예약할 시간을 먼저 골라 주세요.',
      _ => null,
    };
    if (missing != null) {
      showAppMessage(context, missing);
      return;
    }

    if (_step < _stepLabels.length - 1) {
      setState(() => _step++);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmScreen(
          shop: widget.shop,
          designer: _selectedDesigner!,
          menuType: _selectedMenuType!,
          reservationTime: _slotDateTime(_selectedDate!, _selectedTimeSlot!),
          totalAmount: _totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _step == _stepLabels.length - 1;

    // 뒤로가기는 이전 단계로 (첫 단계에서만 화면을 닫음)
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('예약하기')),
        body: ListView(
          key: ValueKey(_step), // 단계가 바뀌면 맨 위부터 보이도록
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.xxl,
          ),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StepIndicator(
                    current: _step + 1,
                    total: kBookingTotalSteps,
                    label: _stepLabels[_step],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildStep(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          child: PrimaryButton(
            label: isLastStep ? '예약 내용 확인하기' : '다음',
            icon: Icons.arrow_forward,
            onPressed: _goNext,
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildMenuStep();
      case 1:
        return _buildDesignerStep();
      case 2:
        return _buildDateStep();
      default:
        return _buildTimeStep();
    }
  }

  Widget _buildMenuStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          '어떤 시술을 받으시나요?',
          description: widget.shop.shopName,
        ),
        SelectOptionCard(
          title: '뿌리 염색',
          subtitle: '자라난 뿌리 부분만 염색',
          trailing: formatWon(widget.shop.rootPrice),
          selected: _selectedMenuType == 'ROOT_DYE',
          onTap: () => setState(() => _selectedMenuType = 'ROOT_DYE'),
        ),
        SelectOptionCard(
          title: '전체 염색',
          subtitle: '단발 기준 · 길이에 따라 추가 요금',
          trailing: formatWon(widget.shop.fullPrice),
          selected: _selectedMenuType == 'FULL_DYE',
          onTap: () => setState(() => _selectedMenuType = 'FULL_DYE'),
        ),
      ],
    );
  }

  Widget _buildDesignerStep() {
    final Widget content;
    if (_isLoadingDesigners) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: LoadingMessage(text: '선생님 목록을 불러오는 중입니다'),
      );
    } else if (_designerError != null) {
      content = StateMessage.error(message: _designerError!, onRetry: _loadDesigners);
    } else if (_designers.isEmpty) {
      content = const StateMessage(
        icon: Icons.person_off_outlined,
        title: '지금 예약할 수 있는 선생님이 없어요',
        message: '매장으로 전화해 예약해 주세요.',
      );
    } else {
      content = Column(
        children: _designers.map((designer) {
          return SelectOptionCard(
            title: designer.designerName,
            subtitle: designer.position,
            icon: Icons.person_outline,
            selected: _selectedDesigner?.designerId == designer.designerId,
            onTap: () => setState(() => _selectedDesigner = designer),
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('담당 선생님을 골라 주세요'),
        content,
      ],
    );
  }

  Widget _buildDateStep() {
    final dates = _bookableDates;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('언제 오시나요?', description: '오늘부터 2주 안에서 고를 수 있어요.'),
        ...dates.map((date) {
          return SelectOptionCard(
            title: formatDateWithRelative(date),
            icon: Icons.calendar_today_outlined,
            selected: _selectedDate != null && isSameDate(_selectedDate!, date),
            onTap: () => setState(() {
              if (_selectedDate == null || !isSameDate(_selectedDate!, date)) {
                _selectedTimeSlot = null; // 날짜가 바뀌면 시간은 다시 고르기
              }
              _selectedDate = date;
            }),
          );
        }),
      ],
    );
  }

  Widget _buildTimeStep() {
    final date = _selectedDate!;
    final slots = _availableSlots(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle('몇 시에 오시나요?', description: formatDateWithRelative(date)),
        if (slots.isEmpty)
          const StateMessage(
            icon: Icons.schedule,
            title: '이 날은 예약할 수 있는 시간이 없어요',
            message: '이전 단계에서 다른 날짜를 골라 주세요.',
          )
        else
          // 큰 버튼 두 줄 배치
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 520 ? 3 : 2;
              final width = (constraints.maxWidth - AppSpacing.md * (columns - 1)) / columns;
              return Wrap(
                spacing: AppSpacing.md,
                children: slots.map((slot) {
                  final parts = slot.split(':');
                  return SizedBox(
                    width: width,
                    child: SelectOptionCard(
                      title: formatTime(int.parse(parts[0]), int.parse(parts[1])),
                      selected: _selectedTimeSlot == slot,
                      onTap: () => setState(() => _selectedTimeSlot = slot),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}

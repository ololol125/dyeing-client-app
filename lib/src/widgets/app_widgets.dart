import 'package:flutter/material.dart';
import '../core/theme.dart';

// 여러 화면에서 반복되는 UI 조각. 색·크기는 모두 theme.dart 토큰에서 가져온다.

// 태블릿·가로 화면에서 내용이 너무 넓게 퍼지지 않도록 가운데 정렬 + 최대 폭 제한
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentWidth({super.key, required this.child, this.maxWidth = 720});

  @override
  Widget build(BuildContext context) {
    // heightFactor: 1 → 세로로는 내용 높이만 차지 (하단 버튼 영역 등에서 화면 전체로 늘어나지 않게)
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

// 화면 아래에 고정되는 버튼 영역 (주요 행동 버튼은 항상 같은 자리에)
class BottomActionBar extends StatelessWidget {
  final Widget child;

  const BottomActionBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              AppSpacing.md,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// 가로 폭을 꽉 채우는 주요 버튼 (로딩 중에는 안내 문구와 함께 표시)
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String loadingLabel;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.loadingLabel = '잠시만 기다려 주세요',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(loadingLabel),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon), const SizedBox(width: AppSpacing.sm)],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        // 로딩 중에는 눌러도 아무 일도 없도록 (색은 유지해 '꺼진 버튼'처럼 보이지 않게)
        onPressed: isLoading ? () {} : onPressed,
        child: content,
      ),
    );
  }
}

// 섹션 제목
class SectionTitle extends StatelessWidget {
  final String text;
  final String? description;

  const SectionTitle(this.text, {super.key, this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: Theme.of(context).textTheme.titleLarge),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              description!,
              style: const TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
            ),
          ],
        ],
      ),
    );
  }
}

// 아이콘 + 항목명 + 내용 한 줄 (아이콘은 항상 글자와 함께)
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelWidth = MediaQuery.textScalerOf(context).scale(92);
    final labelText = Text(
      label,
      style: const TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
    );
    final valueText = Text(
      value,
      style: TextStyle(
        fontSize: emphasize ? AppTextSize.button : AppTextSize.body,
        fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
        color: emphasize ? AppColors.primary : AppColors.ink,
      ),
    );
    final iconWidget = Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Icon(icon, size: 24, color: AppColors.inkSub),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 글자를 크게 키워 내용 칸이 좁아지면 항목명 아래로 내용을 내린다
          final stacked = constraints.maxWidth - labelWidth < 160;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconWidget,
              const SizedBox(width: AppSpacing.md),
              if (stacked)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [labelText, valueText],
                  ),
                )
              else ...[
                SizedBox(width: labelWidth, child: labelText),
                Expanded(child: valueText),
              ],
            ],
          );
        },
      ),
    );
  }
}

// 항목명 ↔ 금액 한 줄. 글자를 크게 키워 한 줄에 안 들어가면 금액이 다음 줄로 내려간다.
class AmountRow extends StatelessWidget {
  final String label;
  final String amount;
  final double labelSize;
  final double amountSize;
  final FontWeight labelWeight;

  const AmountRow({
    super.key,
    required this.label,
    required this.amount,
    this.labelSize = AppTextSize.button,
    this.amountSize = AppTextSize.title,
    this.labelWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.md,
      children: [
        Text(label, style: TextStyle(fontSize: labelSize, fontWeight: labelWeight, color: AppColors.ink)),
        Text(
          amount,
          style: TextStyle(fontSize: amountSize, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ],
    );
  }
}

// 예약 상태 배지 (색 + 아이콘 + 글자)
class StatusBadge extends StatelessWidget {
  final AppStatusStyle style;

  const StatusBadge(this.style, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: style.foreground.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 20, color: style.foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              style.label,
              style: TextStyle(
                fontSize: AppTextSize.caption,
                fontWeight: FontWeight.w700,
                color: style.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 로딩 / 빈 화면 / 오류 안내 (큰 아이콘 + 쉬운 문장 + 큰 버튼)
class StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  const StateMessage.error({
    super.key,
    required String this.message,
    required VoidCallback onRetry,
  })  : icon = Icons.wifi_off_rounded,
        title = '정보를 불러오지 못했어요',
        actionLabel = '다시 불러오기',
        onAction = onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ContentWidth(
          maxWidth: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.inkSub),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingMessage extends StatelessWidget {
  final String text;

  const LoadingMessage({super.key, this.text = '불러오는 중입니다'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 4)),
          const SizedBox(height: AppSpacing.lg),
          Text(text, style: const TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub)),
        ],
      ),
    );
  }
}

// 하나를 고르는 큰 선택 카드 (라디오 대신 사용: 카드 전체가 눌리는 영역)
class SelectOptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const SelectOptionCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 72),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.lineStrong,
                  width: selected ? 2.5 : 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    size: 28,
                    color: selected ? AppColors.primary : AppColors.lineStrong,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  if (icon != null) ...[
                    Icon(icon, size: 26, color: AppColors.ink),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: AppTextSize.button,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: const TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      trailing!,
                      style: const TextStyle(
                        fontSize: AppTextSize.button,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 예약 단계 표시: "2 / 5단계 · 담당 선생님 고르기" + 진행 막대
class StepIndicator extends StatelessWidget {
  final int current; // 1부터 시작
  final int total;
  final String label;

  const StepIndicator({super.key, required this.current, required this.total, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$current / $total단계',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              TextSpan(text: '  ·  $label'),
            ],
          ),
          style: const TextStyle(fontSize: AppTextSize.body, color: AppColors.ink),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(total, (i) {
            return Expanded(
              child: Container(
                height: 8,
                margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                decoration: BoxDecoration(
                  color: i < current ? AppColors.primary : AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// 매장 대표 사진 (없거나 불러오지 못하면 아이콘)
class ShopThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double iconSize;

  const ShopThumbnail({super.key, required this.imageUrl, this.iconSize = 48});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.primarySoft,
      alignment: Alignment.center,
      child: Icon(Icons.storefront_outlined, size: iconSize, color: AppColors.primary),
    );
    if (imageUrl == null || imageUrl!.isEmpty) return placeholder;
    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
      loadingBuilder: (context, child, progress) => progress == null ? child : placeholder,
    );
  }
}

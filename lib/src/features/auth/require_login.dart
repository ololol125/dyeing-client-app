import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';
import 'login_screen.dart';

// 로그인이 필요한 행동(예약 등) 전에 호출. 로그인돼 있으면 바로 true,
// 아니면 로그인 화면을 띄우고 로그인에 성공했을 때만 true를 돌려준다.
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (await AuthService.isLoggedIn()) return true;
  if (!context.mounted) return false;
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
  return result == true;
}

// 로그인해야 볼 수 있는 화면에서 대신 보여주는 안내
class LoginPrompt extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onLoggedIn;

  const LoginPrompt({
    super.key,
    required this.title,
    required this.message,
    required this.onLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ContentWidth(
          maxWidth: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_open_outlined, size: 56, color: AppColors.inkSub),
              const SizedBox(height: AppSpacing.lg),
              Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: '로그인하기',
                icon: Icons.login,
                onPressed: () async {
                  if (await ensureLoggedIn(context)) onLoggedIn();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

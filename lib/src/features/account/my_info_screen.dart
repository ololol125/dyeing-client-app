import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/links.dart';
import '../../core/messages.dart';
import '../../core/theme.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';
import '../auth/require_login.dart';

// 내 정보: 로그인 상태, 로그아웃, 개인정보처리방침·이용약관, 회원 탈퇴
class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  AppUser? _user;
  bool _loading = true;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final loggedIn = await AuthService.isLoggedIn();
    final user = loggedIn ? await AuthService.getCurrentUser() : null;
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _login() async {
    if (await ensureLoggedIn(context)) _loadUser();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃 하시겠어요?'),
        content: const Text('매장 둘러보기는 로그인 없이도 할 수 있어요.'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('아니요')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('로그아웃')),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService.logout();
    if (!mounted) return;
    showAppMessage(context, '로그아웃했어요.');
    _loadUser();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.error),
        title: const Text('정말 탈퇴하시겠어요?'),
        content: const Text(
          '탈퇴하면 이름, 연락처, 이메일, 시술 기록이 삭제되고 되돌릴 수 없어요.\n\n'
          '결제·예약 기록은 법에 따라 5년간 이름 없이 보관돼요.\n\n'
          '다가오는 예약이 있으면 먼저 매장에 연락해 정리해 주세요.',
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          FilledButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('그만두기')),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 2),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('탈퇴하기'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await AuthService.deleteAccount();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('탈퇴가 끝났어요'),
          content: const Text('그동안 염색온을 이용해 주셔서 감사합니다.'),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인')),
            ),
          ],
        ),
      );
      _loadUser();
    } catch (e) {
      if (mounted) showAppMessage(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 정보')),
      body: _loading
          ? const LoadingMessage()
          : ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm, AppSpacing.screen, AppSpacing.xxl),
              children: [
                ContentWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAccountCard(),
                      const SizedBox(height: AppSpacing.xl),
                      const SectionTitle('안내'),
                      _menuTile(
                        icon: Icons.privacy_tip_outlined,
                        label: '개인정보처리방침',
                        onTap: () => openWebPage(context, AppConstants.privacyUrl),
                      ),
                      _menuTile(
                        icon: Icons.description_outlined,
                        label: '이용약관',
                        onTap: () => openWebPage(context, AppConstants.termsUrl),
                      ),
                      _menuTile(
                        icon: Icons.support_agent,
                        label: '고객센터 ${AppConstants.supportPhone}',
                        onTap: () => openWebPage(context, 'tel:${AppConstants.supportPhone}'),
                      ),
                      if (_user != null) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        const Divider(),
                        const SizedBox(height: AppSpacing.lg),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error, width: 2),
                          ),
                          onPressed: _deleting ? null : _deleteAccount,
                          icon: const Icon(Icons.person_remove_outlined),
                          label: Text(_deleting ? '탈퇴 처리 중이에요' : '회원 탈퇴'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAccountCard() {
    final user = _user;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: user == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('로그인하지 않았어요', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    '예약하고 내 예약을 보려면 로그인해 주세요.',
                    style: TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: '로그인 / 회원가입', icon: Icons.login, onPressed: _login),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                        child: const Icon(Icons.person, size: 32, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${user.name} 님', style: Theme.of(context).textTheme.titleLarge),
                            Text(
                              user.email,
                              style: const TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('로그아웃'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _menuTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, size: 28),
        onTap: onTap,
      ),
    );
  }
}

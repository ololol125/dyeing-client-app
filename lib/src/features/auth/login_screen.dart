import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/links.dart';
import '../../core/messages.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';
import '../main_navigation_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      // 예약하기 등에서 열린 경우 원래 화면으로 돌아가고, 아니면 첫 화면으로
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop(true);
      } else {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 로그인 없이도 둘러볼 수 있도록 뒤로가기(닫기)를 항상 제공
      appBar: AppBar(title: const Text('로그인')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
            child: ContentWidth(
              maxWidth: 520,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                      child: const Icon(Icons.content_cut, size: 44, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '염색온',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      '동네 염색방, 전화 없이 편하게 예약하세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      style: const TextStyle(fontSize: AppTextSize.button),
                      decoration: const InputDecoration(
                        labelText: '이메일 주소',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이메일 주소를 적어 주세요.';
                        }
                        if (!value.contains('@')) return '이메일 주소에 @가 들어가야 해요.';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      style: const TextStyle(fontSize: AppTextSize.button),
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        prefixIcon: const Icon(Icons.lock_outline),
                        // 아이콘 대신 글자로 '보기/숨기기'
                        suffixIcon: TextButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Text(_obscurePassword ? '보기' : '숨기기'),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 적어 주세요.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: '로그인',
                      isLoading: _isLoading,
                      loadingLabel: '로그인하고 있어요',
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      '처음 오셨나요?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const SignupScreen()),
                              );
                            },
                      child: const Text('회원가입 하기'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const LegalLinks(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 개인정보처리방침 · 이용약관 링크 (로그인·회원가입·내 정보 화면 공통)
class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      children: [
        TextButton(
          onPressed: () => openWebPage(context, AppConstants.privacyUrl),
          child: const Text('개인정보처리방침', style: TextStyle(decoration: TextDecoration.underline)),
        ),
        TextButton(
          onPressed: () => openWebPage(context, AppConstants.termsUrl),
          child: const Text('이용약관', style: TextStyle(decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
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

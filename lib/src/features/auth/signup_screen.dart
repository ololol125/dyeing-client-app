import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';
import '../../core/links.dart';
import '../../core/messages.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreed = false; // 이용약관·개인정보 수집·이용 동의 (필수)

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    if (!_agreed) {
      showAppMessage(context, '이용약관과 개인정보 수집·이용에 동의해 주셔야 가입할 수 있어요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;
      showAppMessage(context, '가입이 끝났어요. 방금 만든 이메일과 비밀번호로 로그인해 주세요.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? helper,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
    TextInputAction action = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscure,
        textInputAction: action,
        onFieldSubmitted: onSubmitted,
        style: const TextStyle(fontSize: AppTextSize.button),
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 2,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toggle = TextButton(
      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      child: Text(_obscurePassword ? '보기' : '숨기기'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xxl),
          child: ContentWidth(
            maxWidth: 520,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionTitle('아래 내용을 적어 주세요', description: '예약 확인 연락을 위해 필요해요.'),
                  _field(
                    controller: _nameController,
                    label: '이름',
                    icon: Icons.person_outline,
                    validator: (v) => v == null || v.trim().isEmpty ? '이름을 적어 주세요.' : null,
                  ),
                  _field(
                    controller: _phoneController,
                    label: '휴대폰 번호',
                    helper: '숫자만 적어 주세요. 예) 01012345678',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '휴대폰 번호를 적어 주세요.';
                      if (v.trim().length < 10) return '번호가 너무 짧아요. 다시 확인해 주세요.';
                      return null;
                    },
                  ),
                  _field(
                    controller: _emailController,
                    label: '이메일 주소',
                    helper: '로그인할 때 아이디로 써요.',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '이메일 주소를 적어 주세요.';
                      if (!v.contains('@')) return '이메일 주소에 @가 들어가야 해요.';
                      return null;
                    },
                  ),
                  _field(
                    controller: _passwordController,
                    label: '비밀번호',
                    helper: '8자 이상으로 만들어 주세요.',
                    icon: Icons.lock_outline,
                    obscure: _obscurePassword,
                    suffix: toggle,
                    validator: (v) {
                      if (v == null || v.isEmpty) return '비밀번호를 적어 주세요.';
                      if (v.length < 8) return '비밀번호는 8자 이상이어야 해요.';
                      return null;
                    },
                  ),
                  _field(
                    controller: _passwordConfirmController,
                    label: '비밀번호 한 번 더',
                    icon: Icons.lock_outline,
                    obscure: _obscurePassword,
                    action: TextInputAction.done,
                    onSubmitted: (_) => _handleSignup(),
                    validator: (v) => v != _passwordController.text ? '위에 적은 비밀번호와 달라요.' : null,
                  ),
                  _buildConsent(),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: '가입하기',
                    isLoading: _isLoading,
                    loadingLabel: '가입하고 있어요',
                    onPressed: _handleSignup,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 필수 동의: 카드 전체를 눌러 체크, 약관 내용은 링크로 확인
  Widget _buildConsent() {
    // Material로 감싸야 체크 줄을 눌렀을 때 물결 효과가 배경 위에 보인다
    return Material(
      color: _agreed ? AppColors.primarySoft : AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: _agreed ? AppColors.primary : AppColors.lineStrong, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            title: const Text(
              '[필수] 이용약관과 개인정보 수집·이용에 동의합니다',
              style: TextStyle(fontSize: AppTextSize.body, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              '수집 항목: 이름, 휴대폰 번호, 이메일 주소\n이용 목적: 예약 확인 연락, 회원 식별\n보유 기간: 탈퇴할 때까지 (결제 기록은 법에 따라 5년)',
              style: TextStyle(fontSize: AppTextSize.caption, color: AppColors.inkSub, height: 1.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
            child: Wrap(
              spacing: AppSpacing.xs,
              children: [
                TextButton(
                  onPressed: () => openWebPage(context, AppConstants.termsUrl),
                  child: const Text('이용약관 보기', style: TextStyle(decoration: TextDecoration.underline)),
                ),
                TextButton(
                  onPressed: () => openWebPage(context, AppConstants.privacyUrl),
                  child: const Text('개인정보처리방침 보기', style: TextStyle(decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

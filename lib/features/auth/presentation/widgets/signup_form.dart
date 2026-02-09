import 'package:concession_tracker_ui/core/google_auth_service.dart';
import 'package:concession_tracker_ui/core/facebook_auth_service.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/select_market_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'terms_checkbox_row.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;

  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FacebookAuthService _facebookAuthService = FacebookAuthService();

  // =========================
  // 🔵 GOOGLE SIGN-UP
  // =========================
  Future<void> _handleGoogleSignUp() async {
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);

    try {
      final user = await _googleAuthService.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SelectMarketPage()),
        );
      } else {
        _showSnack('Google sign-up cancelled', Colors.orange);
      }
    } catch (e) {
      _showSnack('Google sign-up failed', Colors.red);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // =========================
  // 🔵 FACEBOOK SIGN-UP
  // =========================
  Future<void> _handleFacebookSignUp() async {
    if (_isFacebookLoading) return;

    setState(() => _isFacebookLoading = true);

    try {
      final userData = await FacebookAuthService.login();

      if (!mounted) return;

      if (userData != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SelectMarketPage()),
        );
      } else {
        _showSnack('Facebook sign-up cancelled', Colors.orange);
      }
    } catch (e) {
      _showSnack('Facebook sign-up failed', Colors.red);
    } finally {
      if (mounted) setState(() => _isFacebookLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Center(child: Image.asset('assets/logo.png', height: 70)),

        const SizedBox(height: 24),

        const Text("Let's get you started!", style: AppTextStyles.heading),
        const SizedBox(height: 6),
        const Text(
          "First, let’s finish setting up your account",
          style: AppTextStyles.subHeading,
        ),

        const SizedBox(height: 30),

        _label('Name'),
        _textField('Your name'),

        const SizedBox(height: 16),

        _label('Email'),
        _textField('Your email address'),

        const SizedBox(height: 16),

        _label('Password'),
        _passwordField(
          obscure: obscurePassword,
          onToggle: () =>
              setState(() => obscurePassword = !obscurePassword),
        ),

        const SizedBox(height: 16),

        _label('Confirm Password'),
        _passwordField(
          obscure: obscureConfirmPassword,
          onToggle: () => setState(
              () => obscureConfirmPassword = !obscureConfirmPassword),
        ),

        const SizedBox(height: 16),

        const TermsCheckboxRow(),

        const SizedBox(height: 22),

        _signUpButton(),

        const SizedBox(height: 22),

        _socialSignup(),

        const SizedBox(height: 20),

        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Have an account? ', style: AppTextStyles.subHeading),
              Text(
                'Sign In',
                style: TextStyle(
                  color: AppColors.appleBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================
  // WIDGETS
  // =========================
  Widget _label(String text) =>
      Text(text, style: AppTextStyles.label);

  Widget _textField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _passwordField({
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: AppColors.white,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _signUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SelectMarketPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenCTA,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _socialSignup() {
    return Column(
      children: [
        const Text('or sign up with', style: AppTextStyles.subHeading),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon(
              asset: 'assets/google.png',
              isLoading: _isGoogleLoading,
              onTap: _handleGoogleSignUp,
            ),
            const SizedBox(width: 16),
            _socialIcon(
              asset: 'assets/facebook.png',
              isLoading: _isFacebookLoading,
              onTap: _handleFacebookSignUp,
            ),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon({
    required String asset,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Image.asset(asset, height: 22),
        ),
      ),
    );
  }
}

import 'package:concession_tracker_ui/core/facebook_auth_service.dart';
import 'package:concession_tracker_ui/core/google_auth_service.dart';
import 'package:concession_tracker_ui/core/global_fcm.dart';
import 'package:concession_tracker_ui/features/auth/presentation/widgets/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../widgets/remember_me_row.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscurePassword = true;

  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;

  final GoogleAuthService _googleAuthService =
      GoogleAuthService();

  // ================= NORMAL LOGIN =================
  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Please enter email and password", Colors.red);
      return;
    }

    context.read<LoginBloc>().add(
          Login(
            email: email,
            password: password,
            fcmToken: GlobalFCM.token ?? "",
          ),
        );
  }

  // ================= GOOGLE =================
  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);

    try {
      final user = await _googleAuthService.signInWithGoogle();

      if (user != null) {
        _showSnack("Google login success", Colors.green);
      }
    } catch (e) {
      _showSnack("Google login failed", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  // ================= FACEBOOK =================
  Future<void> _handleFacebookSignIn() async {
    if (_isFacebookLoading) return;

    setState(() => _isFacebookLoading = true);

    try {
      final success = await FacebookAuthService.login();

      if (success) {
        _showSnack("Facebook login success", Colors.green);
      }
    } catch (e) {
      _showSnack("Facebook login failed", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isFacebookLoading = false);
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Image.asset('assets/logo.png', height: 70),

        const SizedBox(height: 20),
        const Text('Sign in your account',
            style: AppTextStyles.heading),

        const SizedBox(height: 6),
        const Text(
          'Sign up or log in to get started',
          style: AppTextStyles.subHeading,
        ),

        const SizedBox(height: 30),

        _label('Email'),
        _textField(_emailController, 'Your email'),

        const SizedBox(height: 16),

        _label('Password'),
        _passwordField(),

        const SizedBox(height: 12),
        const RememberMeRow(),

        const SizedBox(height: 22),
        _signInButton(),

        const SizedBox(height: 22),
        _divider(),

        const SizedBox(height: 22),
        _googleButton(),

        const SizedBox(height: 12),
        _facebookButton(),

        const SizedBox(height: 22),
        _signupRow(),
      ],
    );
  }

  // ================= WIDGETS =================

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: AppTextStyles.label),
    );
  }

  Widget _textField(
      TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      cursorColor: AppColors.appleBlack,
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

  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: AppColors.white,
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: () {
            setState(
                () => obscurePassword = !obscurePassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _signInButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _handleLogin, // ✅ BLOC TRIGGER
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenCTA,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _googleButton() {
    return _socialButton(
      isLoading: _isGoogleLoading,
      text: 'Continue with Google',
      icon: Image.asset('assets/google.png', height: 22),
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      onTap: _handleGoogleSignIn,
    );
  }

  Widget _facebookButton() {
    return _socialButton(
      isLoading: _isFacebookLoading,
      text: 'Continue with Facebook',
      icon: const Icon(Icons.facebook, color: Colors.white),
      backgroundColor: const Color(0xFF1877F2),
      textColor: Colors.white,
      onTap: _handleFacebookSignIn,
    );
  }

  Widget _socialButton({
    required bool isLoading,
    required String text,
    required Widget icon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _divider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child:
              Text('or', style: AppTextStyles.subHeading),
        ),
        Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _signupRow() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ",
            style: AppTextStyles.subHeading),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      const SignUpPage()),
            );
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: AppColors.appleBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }
}


import 'package:concession_tracker_ui/core/facebook_auth_service.dart';
import 'package:concession_tracker_ui/core/global_fcm.dart';
import 'package:concession_tracker_ui/core/google_auth_service.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/signup/auth_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/signup/auth_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/signup/auth_state.dart';
import 'package:concession_tracker_ui/features/auth/presentation/widgets/login_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/select_market_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/terms_checkbox_row.dart';

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


  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phonenumberController = TextEditingController();

    final GoogleAuthService _googleAuthService =
      GoogleAuthService();


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ================= GOOGLE SIGNUP =================
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

  // ================= FACEBOOK SIGNUP =================
  Future<void> _handleFacebookSignUp() async {
    setState(() => _isFacebookLoading = true);

    try {
      final success = await FacebookAuthService.login();

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SelectMarketPage()),
        );
      } else {
        _showSnack("Facebook signup cancelled", Colors.orange);
      }
    } catch (e) {
      _showSnack("Facebook signup failed", Colors.red);
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

  Widget _phoneField() {
  return TextField(
    controller: phonenumberController,
    keyboardType: TextInputType.number,
    maxLength: 10,
    decoration: InputDecoration(
      counterText: "", // removes 0/10 counter
      prefixIcon: Container(
        alignment: Alignment.center,
        width: 60,
        child: const Text(
          "+1",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      hintText: "Enter 10 digit number",
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(10),
    ],
  );
}

  // ================= UI =================
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
        _textField('Your name', nameController),

        const SizedBox(height: 16),

        _label('Email'),
        _textField('Your email address', emailController),

        const SizedBox(height: 16),

        _label('Password'),
        _passwordField(
          obscure: obscurePassword,
          controller: passwordController,
          onToggle: () =>
              setState(() => obscurePassword = !obscurePassword),
        ),

        const SizedBox(height: 16),

        _label('Confirm Password'),
        _passwordField(
          obscure: obscureConfirmPassword,
          controller: confirmPasswordController,
          onToggle: () =>
              setState(() =>
                  obscureConfirmPassword = !obscureConfirmPassword),
        ),

        _label('Phone Number'),
        _phoneField(),

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
            children: [
              const Text('Have an account? ',
                  style: AppTextStyles.subHeading),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: AppColors.appleBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // ================= WIDGETS =================

  Widget _label(String text) =>
      Text(text, style: AppTextStyles.label);

  Widget _textField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
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
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: AppColors.white,
        suffixIcon: IconButton(
          icon: Icon(obscure
              ? Icons.visibility_off
              : Icons.visibility),
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
  return BlocConsumer<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state is AuthSuccess) {
        // ✅ Direct navigation (no snackbar)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SelectMarketPage()),
          (route) => false,
        );
      }

      if (state is AuthFailure) {
        // ❌ Remove snackbar if you want silent failure
        // OR keep this if you still want error feedback
        _showSnack(state.message, Colors.red);
      }
    },
    builder: (context, state) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: state is AuthLoading
              ? null
              : () {
                  if (nameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty) {
                    _showSnack("Please fill all fields", Colors.red);
                    return;
                  }

                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    _showSnack("Passwords do not match", Colors.red);
                    return;
                  }

                  context.read<AuthBloc>().add(
                    RegisterRequested(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      phoneNumber: phonenumberController.text.trim(),
                      fcmToken: GlobalFCM.token, // ✅ fetch FCM from global
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.greenCTA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: state is AuthLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    },
  );
}


  Widget _socialSignup() {
    return Column(
      children: [
        const Text('or sign up with',
            style: AppTextStyles.subHeading),
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

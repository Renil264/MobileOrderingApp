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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Center(
          child: Image.asset(
            'assets/logo.png',
            height: 70,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          "Let's get you started!",
          style: AppTextStyles.heading,
        ),
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
          onToggle: () {
            setState(() => obscurePassword = !obscurePassword);
          },
        ),

        const SizedBox(height: 16),

        _label('Confirm Password'),
        _passwordField(
          obscure: obscureConfirmPassword,
          onToggle: () {
            setState(() =>
                obscureConfirmPassword = !obscureConfirmPassword);
          },
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
              Text(
                'Have an account? ',
                style: AppTextStyles.subHeading,
              ),
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

  Widget _label(String text) {
    return Text(text, style: AppTextStyles.label);
  }

  Widget _textField(String hint) {
    return TextField(
      cursorColor: Colors.black,
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
      cursorColor: Colors.black,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: AppColors.white,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
          ),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SelectMarketPage(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.greenCTA,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Sign Up',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.white
        ),
      ),
    ),
  );
}


  Widget _socialSignup() {
    return Column(
      children: [
        const Text(
          'or sign up with',
          style: AppTextStyles.subHeading,
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon('assets/google.png'),
            const SizedBox(width: 16),
            _socialIcon('assets/facebook.png'),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(String asset) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Image.asset(asset, height: 22),
      ),
    );
  }
}

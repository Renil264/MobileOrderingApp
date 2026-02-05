import 'package:concession_tracker_ui/features/auth/presentation/pages/select_market_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'remember_me_row.dart';
import 'social_login_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),

        Image.asset('assets/logo.png', height: 70),

        const SizedBox(height: 20),

        const Text('Sign in your account', style: AppTextStyles.heading),
        const SizedBox(height: 6),
        const Text(
          'Sign up or log in to get started',
          style: AppTextStyles.subHeading,
        ),

        const SizedBox(height: 30),
        
        
        _label('Email'),
        _textField('Your email'),

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

        SocialLoginButton.facebook(),
        const SizedBox(height: 12),
        SocialLoginButton.google(),
        const SizedBox(height: 12),
        // SocialLoginButton.apple(),

        const SizedBox(height: 22),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: AppTextStyles.subHeading,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignUpPage(),
                  ),
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
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Align( 
      alignment: Alignment.centerLeft,
      child: Text(text, style: AppTextStyles.label),
    );
  }

  Widget _textField(String hint) {
    return TextField(
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
      cursorColor: AppColors.appleBlack,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: AppColors.white,
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => obscurePassword = !obscurePassword);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Sign In',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    ),
  );
}


  Widget _divider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('or', style: AppTextStyles.subHeading),
        ),
        Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}


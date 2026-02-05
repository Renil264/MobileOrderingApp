import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final Color backgroundColor;
  final Widget icon;
  final String text;
  final bool outlined;

  const SocialLoginButton({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.text,
    this.outlined = false,
  });

    factory SocialLoginButton.google() {
    return SocialLoginButton(
      backgroundColor: Colors.transparent,
      outlined: true,
      icon: Image.asset(
        'assets/google.png',
        height: 20,
      ),
      text: 'Continue with Google',
    );
  }

  factory SocialLoginButton.facebook() {
    return SocialLoginButton(
      backgroundColor: AppColors.facebookBlue,
      icon: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.facebook, color: AppColors.facebookBlue, size: 18),
      ),
      text: 'Continue with Facebook',
    );
  }

  factory SocialLoginButton.apple() {
    return const SocialLoginButton(
      backgroundColor: Colors.black,
      icon: Icon(Icons.apple, color: Colors.white, size: 22),
      text: 'Continue with Apple',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          side: outlined
              ? const BorderSide(color: Colors.white, width: 1)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

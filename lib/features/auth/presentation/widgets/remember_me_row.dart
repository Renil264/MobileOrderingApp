import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RememberMeRow extends StatefulWidget {
  const RememberMeRow({super.key});

  @override
  State<RememberMeRow> createState() => _RememberMeRowState();
}

class _RememberMeRowState extends State<RememberMeRow> {
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              rememberMe = !rememberMe;
            });
          },
          child: Icon(
            rememberMe
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            size: 18,
            color: AppColors.white,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              rememberMe = !rememberMe;
            });
          },
          child: const Text(
            'Remember me',
            style: TextStyle(color: AppColors.white),
          ),
        ),
        const Spacer(),
        const Text(
          'Forgot password',
          style: TextStyle(
            color: AppColors.appleBlack,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}

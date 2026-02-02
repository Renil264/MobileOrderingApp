import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TermsCheckboxRow extends StatefulWidget {
  const TermsCheckboxRow({super.key});

  @override
  State<TermsCheckboxRow> createState() => _TermsCheckboxRowState();
}

class _TermsCheckboxRowState extends State<TermsCheckboxRow> {
  bool accepted = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() => accepted = !accepted);
          },
          child: Icon(
            accepted
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            size: 18,
            color: AppColors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            children: const [
              Text(
                'I understood the ',
                style: TextStyle(color: AppColors.white),
              ),
              Text(
                'terms & policy',
                style: TextStyle(
                  color: AppColors.appleBlack,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

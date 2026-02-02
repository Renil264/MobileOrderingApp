import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/signup_form.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      body: Stack(
        children: [
          // 1️⃣ BASE GRADIENT (ALWAYS FILLS SCREEN)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [  
                    AppColors.gradientBottom,
                    AppColors.gradientTop,   // #FFBB00
                  ],
                ),
              ),
            ),
          ),

          // 2️⃣ BACKGROUND IMAGE (NO COLOR HERE)
          Positioned.fill(
            child: Image.asset(
              'assets/login_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 3️⃣ VERY LIGHT GRADIENT OVERLAY (BLENDS IMAGE WITH BOTH COLORS)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.gradientBottom.withOpacity(0.85),
                    AppColors.gradientTop.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          // 4️⃣ CONTENT (FULL HEIGHT + SCROLL SAFE)
          SafeArea(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - padding.vertical,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                      vertical: 24,
                    ),
                    child: const SignUpForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

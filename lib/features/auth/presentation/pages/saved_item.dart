import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      // 🔹 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),

      // 🔹 BODY
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 📘 Illustration
                Image.asset(
                  'assets/book_icon.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 12),

                // 🔹 TITLE
                const Text(
                  'Nothing saved just yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.appleBlack,
                  ),
                ),

                const SizedBox(height: 6),

                // 🔹 SUBTITLE
                const Text(
                  'Save your favorite items to see them here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 CTA BUTTON
                SizedBox(
                  width: 220,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Switch back to HOME tab
                      //Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.gradientTop,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Find favorite food',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

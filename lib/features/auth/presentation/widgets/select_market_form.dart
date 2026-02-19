import 'package:concession_tracker_ui/features/auth/presentation/pages/home_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/main_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';


class SelectMarketForm extends StatefulWidget {
  const SelectMarketForm({super.key});

  @override
  State<SelectMarketForm> createState() => _SelectMarketFormState();
}

class _SelectMarketFormState extends State<SelectMarketForm> {
  String? selectedCity;
  String? selectedMarket;

  @override
  Widget build(BuildContext context) {
    final bool canContinue =
        selectedCity != null && selectedMarket != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),

        Center(
          child: Image.asset(
            'assets/logo.png',
            height: 70,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Select Your City and Market',
          style: AppTextStyles.heading,
        ),

        const SizedBox(height: 6),

        const Text(
          'Please choose your city and market to log in to your account.',
          style: AppTextStyles.subHeading,
        ),

        const SizedBox(height: 30),

        _label('Choose a City'),
        const SizedBox(height: 6),
        _cityDropdown(),

        const SizedBox(height: 30),

        _label('Choose a Market'),
        const SizedBox(height: 6),
        _marketDropdown(),

        const SizedBox(height: 30),

        _continueButton(context, canContinue),
      ],
    );
  }

  Widget _label(String text) {
    return Text(text, style: AppTextStyles.label);
  }

  /// ---------------- CITY DROPDOWN ----------------
  Widget _cityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCity,
          hint: const Text('Select city'),
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'Aromas', child: Text('Aromas')),
            DropdownMenuItem(value: 'Houston', child: Text('Houston')),
            DropdownMenuItem(value: 'Lexington', child: Text('Lexington')),
            DropdownMenuItem(value: 'Antioch', child: Text('Antioch')),
          ],
          onChanged: (value) {
            setState(() {
              selectedCity = value;
              selectedMarket = null; // reset market
            });
          },
        ),
      ),
    );
  }

  /// ---------------- MARKET DROPDOWN ----------------
  Widget _marketDropdown() {
    final bool isEnabled = selectedCity != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMarket,
          hint: const Text('Select market'),
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          items: isEnabled
              ? const [
                  DropdownMenuItem(value: 'market1', child: Text('Market 1')),
                  DropdownMenuItem(value: 'market2', child: Text('Market 2')),
                  DropdownMenuItem(value: 'market3', child: Text('Market 3')),
                ]
              : [],
          onChanged: isEnabled
              ? (value) {
                  setState(() {
                    selectedMarket = value;
                  });
                }
              : null,
        ),
      ),
    );
  }

  /// ---------------- CONTINUE BUTTON ----------------
  Widget _continueButton(BuildContext context, bool canContinue) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canContinue
            ? () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainShellPage(),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenCTA,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

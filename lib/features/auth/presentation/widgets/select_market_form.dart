// lib/features/auth/presentation/pages/select_market_page.dart
// UPDATED: stores market in GlobalMarket and provides ConcessionBloc to next page

import 'package:concession_tracker_ui/core/global_market.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/main_page.dart';
import 'package:concession_tracker_ui/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  final Map<String, List<String>> cityMarketMap = {
    'WINSTON SALEM - North California': ['Cooks Flea Market'],
    'BONITA SPRINGS - Florida': ['Flamingo Island Flea Market'],
    'SHEPHERDSVILLE - Kentucky': ['Awesome Flea Market'],
    'PEARLAND - Texas': ['Coles Antique Village'],
    'Colorado Springs - Colorado': ['Colorado Springs Flea Market'],
    'FT. MYERS - Florida': ['Fleamasters Flea Market'],
    'ATHENS - Georgia': ['J & J Flea Market'],
    'SAVANNAH - Georgia': ['Kellers Flea Market'],
    'HENDERSON - Nevada': ['Mile High Flea Market'],
    'MOBILE - Alabama': ['Mobile Flea Market'],
    'JACKSONVILLE - Florida': ['Ramona Flea Market'],
    'RIVERSIDE - California': ['Rubidoux Swap Meet'],
    'PENSACOLA - Florida': ['T&W Flea Market'],
    'TUCSON - Arizona': ['Tanque Verde Swap Meet'],
    'MONROE - Washington': ['Treasure Aisles Flea Market'],
  };

  @override
  Widget build(BuildContext context) {
    final bool canContinue = selectedCity != null && selectedMarket != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Center(child: Image.asset('assets/logo.png', height: 70)),
        const SizedBox(height: 24),
        const Text('Select Your City and Market', style: AppTextStyles.heading),
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

  Widget _label(String text) => Text(text, style: AppTextStyles.label);

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
          items: cityMarketMap.keys.map((city) {
            return DropdownMenuItem(value: city, child: Text(city));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCity = value;
              selectedMarket = null;
            });
          },
        ),
      ),
    );
  }

  Widget _marketDropdown() {
    final bool isEnabled = selectedCity != null;
    final List<String> markets =
        selectedCity != null ? cityMarketMap[selectedCity]! : [];

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
          items: markets.map((market) {
            return DropdownMenuItem(value: market, child: Text(market));
          }).toList(),
          onChanged: isEnabled
              ? (value) => setState(() => selectedMarket = value)
              : null,
        ),
      ),
    );
  }

  Widget _continueButton(BuildContext context, bool canContinue) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canContinue
            ? () async {
                // 1. Store market name globally + persist to SharedPreferences
                GlobalMarket.setMarket(selectedMarket!);

                // 2. Navigate and provide BLoC, then immediately fetch
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<ConcessionBloc>()
                          ..add(FetchConcessions(selectedMarket!)),
                        child: const MainShellPage(),
                      ),
                    ),
                  );
                }
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
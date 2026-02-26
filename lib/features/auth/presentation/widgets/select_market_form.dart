import 'dart:convert';
import 'package:concession_tracker_ui/core/global_fcm.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/user_storage.dart';
import 'package:http/http.dart' as http;
import 'package:concession_tracker_ui/core/global_market.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/main_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/widgets/login_page.dart';
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

  bool isLogoutLoading = false;

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

  /// ================= LOGOUT API =================
  Future<void> _logoutUser(BuildContext context) async {
    const String url =
        "http://192.168.10.144/ConcessionTracker/api/Users/logout";

    if (isLogoutLoading) return;

    setState(() {
      isLogoutLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": GlobalUser.email,
          "fcmToken": GlobalFCM.token,
        }),
      );

      print("EMAIL: ${GlobalUser.email}");
      print("FCM: ${GlobalFCM.token}");

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Logout successful")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Logout failed (${response.statusCode})"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLogoutLoading = false;
      });
    }
  }
  /// ===================================================

  @override
  Widget build(BuildContext context) {
    final bool canContinue =
        selectedCity != null && selectedMarket != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Center(child: Image.asset('assets/logo.png', height: 70)),
        const SizedBox(height: 24),
        const Text('Select Your City and Market',
            style: AppTextStyles.heading),
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
        const SizedBox(height: 16),

        /// ================= LOGOUT BUTTON =================
        Center(
          child: TextButton(
            onPressed: isLogoutLoading
                ? null
                : () => _logoutUser(context),
            child: isLogoutLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.appleBlack,
                    ),
                  )
                : const Text(
                    'Go Back to SignIn',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: AppColors.appleBlack,
                    ),
                  ),
          ),
        )
      ],
    );
  }

  Widget _label(String text) =>
      Text(text, style: AppTextStyles.label);

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
            return DropdownMenuItem(
                value: city, child: Text(city));
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
        color: isEnabled
            ? AppColors.white
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMarket,
          hint: const Text('Select market'),
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          items: markets.map((market) {
            return DropdownMenuItem(
                value: market, child: Text(market));
          }).toList(),
          onChanged: isEnabled
              ? (value) =>
                  setState(() => selectedMarket = value)
              : null,
        ),
      ),
    );
  }

  Widget _continueButton(
      BuildContext context, bool canContinue) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canContinue
            ? () {
                GlobalMarket.setMarket(selectedMarket!);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<ConcessionBloc>()
                        ..add(FetchConcessions(
                            selectedMarket!)),
                      child: const MainShellPage(),
                    ),
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
import 'package:concession_tracker_ui/core/constants/app_colors.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/main_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SwitchMarketPage extends StatefulWidget {
  const SwitchMarketPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SwitchMarketPageState createState() => _SwitchMarketPageState();
}

class _SwitchMarketPageState extends State<SwitchMarketPage> {
  String? selectedCity;
  String? selectedMarket;

  final Map<String, List<String>> cityMarkets = {
    "Aromas": ["Mile High Flea Market", "Red Barn Flea Market"],
    "Houston": ["Cole's Flea Market",],
    "Lexington": ["Flamingo Island"],
    "Antioch": ["Antioch Fleamarket"]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      
      // ORANGE APPBAR
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gradientTop),
          onPressed: () => Navigator.of(context).pop(),
        ),
        
        
      ),
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // ICON
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gradientTop.withOpacity(0.1),
                    shape: BoxShape.circle,
                    
                  ),
                  child: const Icon(
                    Icons.store,
                    size: 48,
                    color: AppColors.gradientTop,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // TITLE
              const Text(
                'Select Your Market',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // SUBTITLE
              Text(
                'Please choose your city and market to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // CITY DROPDOWN LABEL
              const Text(
                'City',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // CITY DROPDOWN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCity,
                    isExpanded: true,
                    hint: Text(
                      'Select a city',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    items: cityMarkets.keys.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(
                          city,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCity = newValue;
                        selectedMarket = null; // Reset market when city changes
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // MARKET DROPDOWN LABEL
              const Text(
                'Market Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // MARKET DROPDOWN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(
                    color: selectedCity == null 
                        ? Colors.grey.shade200 
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedMarket,
                    isExpanded: true,
                    hint: Text(
                      selectedCity == null 
                          ? 'Please select a city first'
                          : 'Select a market',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down, 
                      color: selectedCity == null ? Colors.grey.shade300 : Colors.grey,
                    ),
                    items: selectedCity == null
                        ? []
                        : cityMarkets[selectedCity]!.map((String market) {
                            return DropdownMenuItem<String>(
                              value: market,
                              child: Text(
                                market,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                    onChanged: selectedCity == null
                        ? null
                        : (String? newValue) {
                            setState(() {
                              selectedMarket = newValue;
                            });
                          },
                  ),
                ),
              ),
              
              const Spacer(),
              
              // GREEN CONTINUE BUTTON
              ElevatedButton(
                onPressed: (selectedCity == null || selectedMarket == null)
                    ? null
                    : () {
                        if (kDebugMode) {
                          print("Selected City: $selectedCity");
                          print("Selected Market: $selectedMarket");
                        }

                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainShellPage(),
                  ),
                );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gradientTop,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: (selectedCity == null || selectedMarket == null) 
                        ? Colors.grey[500] 
                        : AppColors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
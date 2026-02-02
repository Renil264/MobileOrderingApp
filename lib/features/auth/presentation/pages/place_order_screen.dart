import 'dart:async';
import 'package:concession_tracker_ui/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'order_placed_screen.dart'; // ✅ Make sure to import your OrderPlacedScreen file

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to OrderPlacedScreen after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderPlacedScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.gradientTop, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/placing_order.png',
                      height: 180,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Placing your order…",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "We are placing your order. You will be\n"
                      "notified once your order is confirmed by\n"
                      "restaurant.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

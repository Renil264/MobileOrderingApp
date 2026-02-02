import 'package:concession_tracker_ui/core/constants/app_colors.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/place_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentOptionsDialog extends StatefulWidget {
  final VoidCallback onApplePay;
  final VoidCallback onGooglePay;
  final VoidCallback onCardPayment;

  const PaymentOptionsDialog({
    super.key,
    required this.onApplePay,
    required this.onGooglePay,
    required this.onCardPayment,
  });

  @override
  State<PaymentOptionsDialog> createState() => _PaymentOptionsDialogState();
}

class _PaymentOptionsDialogState extends State<PaymentOptionsDialog> {
  String? selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.55,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // 🔘 DRAG HANDLE
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pay with",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildPaymentButton(
              svgPath: 'assets/apple.svg',
              label: "Apple Pay",
              paymentMethod: 'apple',
            ),

            const SizedBox(height: 12),

            _buildPaymentButton(
              svgPath: 'assets/google_logo.svg',
              label: "Google Pay",
              paymentMethod: 'google',
            ),

            const SizedBox(height: 12),

            _buildPaymentButton(
              svgPath: 'assets/card_payment.svg',
              label: "Card Payment",
              subtitle: "Add Debit or Credit Card",
              paymentMethod: 'card',
            ),

            const Spacer(),

            // ✅ CONTINUE BUTTON
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPaymentMethod != null
                      ? AppColors.gradientTop
                      : Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: selectedPaymentMethod != null
                    ? () {
                        if (selectedPaymentMethod == 'apple') {
                          widget.onApplePay();
                        } else if (selectedPaymentMethod == 'google') {
                          widget.onGooglePay();
                        } else {
                          widget.onCardPayment();
                        }

                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlaceOrderScreen(),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 PAYMENT BUTTON
  Widget _buildPaymentButton({
    required String svgPath,
    required String label,
    required String paymentMethod,
    String? subtitle,
  }) {
    final isSelected = selectedPaymentMethod == paymentMethod;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => selectedPaymentMethod = paymentMethod);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.gradientTop
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? AppColors.gradientTop.withOpacity(0.05)
                : Colors.white,
          ),
          child: Row(
            children: [
              SvgPicture.asset(svgPath, height: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 13),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.gradientTop,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

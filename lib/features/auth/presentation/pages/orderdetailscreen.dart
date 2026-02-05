
import 'package:concession_tracker_ui/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.gradientTop,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Detail',
          style: TextStyle(
            color: AppColors.gradientTop,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '#5689045678',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4EDDA),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Delivered',
                          style: TextStyle(
                            color: Color(0xFF28A745),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '07 November, 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Delivered to',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1633 Hampton Meadows, Chicago',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // const Text(
                  //   'Apple Pay',
                  //   style: TextStyle(
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.black87,
                  //   ),
                  // ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),

            // Order Items Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildOrderItem(
                    'Burrtos x 2',
                    'Single',
                    '\$ 9.00',
                  ),
                  const SizedBox(height: 20),
                  _buildOrderItem(
                    'Bacon x 2',
                    'Single',
                    '\$9.00',
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),

            // Price Breakdown Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPriceRow('Item Total', '\$ 18.00', false),
                  const SizedBox(height: 12),
                  _buildPriceRow('Credits', '4', false),
                  const SizedBox(height: 12),
                  _buildPriceRow('Paid', '\$ 14.00', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(String title, String subtitle, String price) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.gradientTop,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
            color: isBold ? Colors.black87 : Colors.black87,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: AppColors.gradientTop
          ),
        ),
      ],
    );
  }
}
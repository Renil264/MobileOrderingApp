
import 'package:concession_tracker_ui/core/constants/app_colors.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/orderdetailscreen.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  int selectedIndex = 0; 

  final List<Map<String, String>> newOrders = [
    {
      "id": "#98765",
      "date": "09/25/2025",
      "amount": "\$65.90",
      "status": "Preparing",
    },
    {
      "id": "#98452",
      "date": "09/22/2025",
      "amount": "\$42.00",
      "status": "Ready to Pick",
    },
  ];

  final List<Map<String, String>> pastOrders = [
    {
      "id": "#12345",
      "date": "08/25/2025",
      "amount": "\$80.50",
      "status": "Completed",
    },
    {
      "id": "#24561",
      "date": "08/20/2025",
      "amount": "\$45.50",
      "status": "Completed",
    },
    {
      "id": "#72345",
      "date": "08/13/2025",
      "amount": "\$70.40",
      "status": "Completed",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.white,
        title: const Text(
          "My Orders",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.appleBlack,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // --- Segmented Control ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gradientTop, width: 1.2),
            ),
            child: Row(
              children: [
                _buildSegmentButton("New orders", 0),
                _buildSegmentButton("Past orders", 1),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: selectedIndex == 0
                ? _newOrdersListView()
                : _pastOrdersListView(),
          ),
        ],
      ),
    );
  }

  Widget _newOrdersListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: newOrders.length,
      itemBuilder: (context, index) => _newOrderCard(newOrders[index]),
    );
  }

  Widget _newOrderCard(Map<String, String> order) {
  Color statusColor;
  Color textColor;

  
  switch (order["status"]) {
    case "Preparing":
      statusColor = AppColors.primaryGold.withOpacity(.25);
      textColor = AppColors.primaryGold; // yellowish text
      break;
    case "Ready to Pick":
      statusColor = AppColors.greenCTA.withOpacity(.20);
      textColor = AppColors.greenCTA;
      break;
    default:
      statusColor = Colors.orange.withOpacity(.15);
      textColor = Colors.orange;
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Order ${order["id"]}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.appleBlack,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                order["status"]!,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

      
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Date: ${order["date"]}",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            Text(
              "Amount  ${order["amount"]}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.appleBlack,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

     
        if (order["status"] == "Ready to Pick")
          SizedBox(
            height: 36,
            width: 120,
            child: ElevatedButton.icon(
              onPressed: () => _showQrPopup(context, order["id"]!),
              icon: const Icon(Icons.qr_code, size: 18, color: Colors.white),
              label: const Text(
                "Show QR",
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenCTA,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}


  Widget _pastOrdersListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: pastOrders.length,
      itemBuilder: (context, index) => _pastOrderCard(pastOrders[index]),
    );
  }


  Widget _pastOrderCard(Map<String, String> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order ${order["id"]}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.appleBlack,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenCTA.withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order["status"]!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.greenCTA,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Date: ${order["date"]}",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              Text(
                "Amount  ${order["amount"]}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appleBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            width: 115,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderDetailScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenCTA,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "View Details",
                style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrPopup(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Scan this QR",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gradientTop,
                ),
              ),
              const SizedBox(height: 16),
              QrImageView(
                data: "Order ID: $orderId",
                version: QrVersions.auto,
                size: 160.0,
              ),
              const SizedBox(height: 20),
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appleBlack,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gradientTop,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton(String text, int index) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gradientTop : AppColors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color:
                  isSelected ? AppColors.white : AppColors.gradientTop,
            ),
          ),
        ),
      ),
    );
  }
}

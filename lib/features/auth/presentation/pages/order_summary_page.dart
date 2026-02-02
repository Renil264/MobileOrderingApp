import 'package:concession_tracker_ui/features/auth/presentation/pages/payment_options_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/store_menu_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  // Track if add-ons section is expanded (single section for all items)
  bool _addOnsExpanded = false;
  
  // Track main item quantities - starting with only one item
  final Map<int, int> _itemQuantities = {
    0: 1,
  };
  
  // Track add-on quantities (start at 0 - not selected)
  final Map<String, int> _addOnQuantities = {
    'Pepsi 330ml': 0,
    'Fanta 330ml': 0,
    'Fries (Small)': 0,
    'Ketch Up': 0,
  };

  // Item base price
  final double _itemBasePrice = 4.50;
  
  // Credits
  final int _totalCredits = 2;
  int _appliedCredits = 0;
  
  // Track if credits dropdown is expanded
  bool _creditsExpanded = false;

  // Calculate total price
  Map<String, double> _calculatePrices() {
    double itemSubtotal = 0;
    
    // Calculate main items total
    _itemQuantities.forEach((index, quantity) {
      itemSubtotal += _itemBasePrice * quantity;
    });
    
    // Calculate add-ons total (only if quantity > 0)
    _addOnQuantities.forEach((name, quantity) {
      if (quantity > 0) {
        double price = name == 'Ketch Up' ? 1.00 : 2.00;
        itemSubtotal += price * quantity;
      }
    });
    
    // Apply credits discount
    double total = itemSubtotal - _appliedCredits;
    if (total < 0) total = 0; // Ensure total doesn't go negative
    
    return {
      'subtotal': itemSubtotal,
      'total': total,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _orderItems(),
                  const SizedBox(height: 24),
                  _orderSummary(),
                  const SizedBox(height: 24),
                  _credits(),
                  const SizedBox(height: 90), // space for PAY button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _payButton(),
    );
  }

  // 🔶 HEADER
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientTop, AppColors.gradientTop],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Restaurant Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🧺 ORDER ITEMS
  Widget _orderItems() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gradientTop,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order items',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Divider(color: Colors.white54),
          // Display all order items
          ..._itemQuantities.keys.map((index) => Column(
            children: [
              _orderItem(index),
              if (index != _itemQuantities.keys.last)
                const Divider(color: Colors.white54),
            ],
          )).toList(),
          
          // Single Add-Ons section for all items
          if (_itemQuantities.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _addOnsExpanded = !_addOnsExpanded;
                });
              },
              child: Row(
                children: [
                  const Text(
                    'Add-Ons',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    _addOnsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
            if (_addOnsExpanded) ...[
              const SizedBox(height: 12),
              _addOnsDropdown(),
            ],
          ],
          
          const Divider(color: Colors.white54),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StoreMenuPage(storeImage: '', storeName: 'Restaurant Name',),
                      ),
                    );
                  },
                  child: _actionButton('Add Items', Icons.add),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Blueberry Muffin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '\$4.50',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _quantityButton(index),
        ],
      ),
    );
  }

  // 🍔 ADD-ONS DROPDOWN (Food mods style) - Single section for all items
  Widget _addOnsDropdown() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.fastfood, color: AppColors.gradientTop, size: 18),
              SizedBox(width: 8),
              Text(
                'Food mods',
                style: TextStyle(
                  color: AppColors.gradientTop,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _addOnItem('Pepsi 330ml', 2.00),
          _addOnItem('Fanta 330ml', 2.00),
          _addOnItem('Fries (Small)', 2.00),
          _addOnItem('Ketch Up', 1.00),
        ],
      ),
    );
  }

  Widget _addOnItem(String name, double price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.gradientTop,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          // Quantity controls
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (_addOnQuantities[name]! > 0) {
                        _addOnQuantities[name] = _addOnQuantities[name]! - 1;
                      }
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.remove, size: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${_addOnQuantities[name]}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _addOnQuantities[name] = _addOnQuantities[name]! + 1;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.add, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(int index) {
    return Row(
      children: [
        // DELETE BUTTON
        InkWell(
          onTap: () {
            setState(() {
              _itemQuantities.remove(index);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 18,
            ),
          ),
        ),

        // QUANTITY CONTAINER
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (_itemQuantities[index]! > 1) {
                      _itemQuantities[index] = _itemQuantities[index]! - 1;
                    }
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.remove, size: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${_itemQuantities[index]}'),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _itemQuantities[index] = _itemQuantities[index]! + 1;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.add, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String text, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(width: 6),
            Icon(icon, size: 16),
          ],
        ),
      ),
    );
  }

  // 📊 ORDER SUMMARY
  Widget _orderSummary() {
    final prices = _calculatePrices();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _summaryRow('Item subtotal', '\$${prices['subtotal']!.toStringAsFixed(2)}'),
        if (_appliedCredits > 0)
          _summaryRow('Credits applied', '-\$${_appliedCredits.toStringAsFixed(2)}',
              color: Colors.green),
        const Divider(),
        _summaryRow('Total', '\$${prices['total']!.toStringAsFixed(2)}', bold: true),
      ],
    );
  }

  Widget _summaryRow(String title, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 🎁 CREDITS WITH DROPDOWN
  Widget _credits() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _creditsExpanded = !_creditsExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientTop, AppColors.gradientBottom],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Available Credits: $_totalCredits',
                  style: const TextStyle(color: Colors.white),
                ),
                if (_appliedCredits > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_appliedCredits applied',
                      style: const TextStyle(
                        color: AppColors.gradientTop,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Icon(
                  _creditsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        // CREDITS DROPDOWN
        if (_creditsExpanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gradientTop, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars, color: AppColors.gradientTop),
                    const SizedBox(width: 8),
                    Text(
                      'You have $_totalCredits credits',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Apply all credits to get \$${_totalCredits.toStringAsFixed(2)} discount',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradientTop,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _appliedCredits == 0
                        ? () {
                            setState(() {
                              _appliedCredits = _totalCredits;
                              _creditsExpanded = false;
                            });
                          }
                        : null,
                    child: Text(
                      _appliedCredits == 0 ? 'Apply Credits' : 'Already Applied',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_appliedCredits > 0) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _appliedCredits = 0;
                        });
                      },
                      child: const Text(
                        'Remove Credits',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  // 💳 PAY BUTTON
  Widget _payButton() {
    final prices = _calculatePrices();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => PaymentOptionsDialog(
              onApplePay: () {},
              onGooglePay: () {},
              onCardPayment: () {},
            ),
          );
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: Text(
              'PAY  \$${prices['total']!.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
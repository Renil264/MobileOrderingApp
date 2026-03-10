import 'dart:convert';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/globalconcession.dart';
import 'package:concession_tracker_ui/core/globalmarketdata.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/payment_options_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/store_menu_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_colors.dart';

class _OrderItem {
  final String concessionName;
  final int itemId;
  final String itemName;
  final double itemPrice;
  int quantity;
  final double totalAmount;
  final DateTime orderDate;

  _OrderItem({
    required this.concessionName,
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    required this.quantity,
    required this.totalAmount,
    required this.orderDate,
  });

  factory _OrderItem.fromJson(Map<String, dynamic> json) => _OrderItem(
        concessionName: json['concessionName'] ?? '',
        itemId: json['itemId'] ?? 0,
        itemName: json['itemName'] ?? '',
        itemPrice: (json['itemPrice'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 1,
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        orderDate: DateTime.parse(json['orderDate']),
      );
}

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  List<_OrderItem> _items = [];
  bool _isProcessingPayment = false;

  // Per-item food-modifier expand state key = itemId_listIndex
  final Map<String, bool> _modExpanded = {};

  // Per-item modifier quantities key = "itemId_index_modName"
  final Map<String, int> _modQty = {};

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Map<String, double> _addOnPrices = {
    'Pepsi 330ml': 2.00,
    'Fanta 330ml': 2.00,
    'Fries (Small)': 2.00,
    'Ketch Up': 1.00,
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchOrders();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final marketId = GlobalMarketData.marketId;
      final userId = GlobalUser.id;
      final url =
          'http://192.168.10.144/ConcessionTracker/api/Users/active-orders/$marketId/$userId';

      print('═══════════════════════════════════════');
      print('[Cart] GET $url');
      print('═══════════════════════════════════════');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('[Cart] Status : ${response.statusCode}');
      print('[Cart] Body   : ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          
          print('[Cart] Response type: ${jsonResponse.runtimeType}');

          List<dynamic> items = [];

          // Handle Map response with "data" field
          if (jsonResponse is Map) {
            print('[Cart] Response is a Map');
            final data = jsonResponse['data'];
            print('[Cart] Data type: ${data.runtimeType}');
            
            if (data != null && data is List) {
              items = List<dynamic>.from(data);
            }
          } 
          // Handle direct List response
          else if (jsonResponse is List) {
            print('[Cart] Response is a List');
            items = List<dynamic>.from(jsonResponse);
          }

          print('[Cart] Items count: ${items.length}');

          // Empty cart check
          if (items.isEmpty) {
            setState(() {
              _items = [];
              _isLoading = false;
            });
            print('[Cart] Cart is empty');
            return;
          }

          // Parse items
          final orderItems = <_OrderItem>[];
          for (var item in items) {
            if (item is Map<String, dynamic>) {
              orderItems.add(_OrderItem.fromJson(item));
            }
          }

          print('[Cart] Parsed ${orderItems.length} items');

          // Initialize modifier state
          for (int i = 0; i < orderItems.length; i++) {
            final key = '${orderItems[i].itemId}_$i';
            _modExpanded[key] = false;
            for (final mod in _addOnPrices.keys) {
              _modQty['${key}_$mod'] = 0;
            }
          }

          setState(() {
            _items = orderItems;
            _isLoading = false;
          });
          print('[Cart] ✅ Orders loaded successfully');
        } catch (e) {
          print('[Cart] ❌ Parsing Error: $e');
          setState(() {
            _items = [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      print('[Cart] ❌ Error: $e');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEntireOrder() async {
    final marketId = GlobalMarketData.marketId;
    final userId = GlobalUser.id;

    try {
      final url =
          'http://192.168.10.144/ConcessionTracker/api/Users/active-orders/$marketId/$userId';

      print('═══════════════════════════════════════');
      print('[Cart] DELETE $url');
      print('═══════════════════════════════════════');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('[Cart] Delete Status: ${response.statusCode}');
      print('[Cart] Delete Body  : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        throw Exception('Failed to delete order: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting order: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text(
          'Are you sure you want to delete this entire order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteEntireOrder();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentOptionsDialog(
        paymentAmount: _grandTotal,
        onPaymentSuccess: _handlePaymentSuccess,
        onPaymentCancel: _handlePaymentCancel,
      ),
    );
  }

  void _handlePaymentSuccess() {
    setState(() => _isProcessingPayment = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.elasticOut,
          ),
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 12,
          icon: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 50,
              color: Colors.green,
            ),
          ),
          title: const Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          content: const Text(
            'Your payment has been processed successfully. Your order is being prepared.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.6,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gradientTop,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context); // Go back to main screen
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePaymentCancel() {
    setState(() => _isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment cancelled'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  double get _itemsSubtotal {
    double t = 0;
    for (int i = 0; i < _items.length; i++) {
      t += _items[i].itemPrice * _items[i].quantity;
      final key = '${_items[i].itemId}_$i';
      for (final e in _addOnPrices.entries) {
        t += e.value * (_modQty['${key}_${e.key}'] ?? 0);
      }
    }
    return t;
  }

  double get _modifierSubtotal {
    double t = 0;
    _modQty.forEach((key, qty) {
      if (qty > 0) {
        final parts = key.split('_');
        if (parts.length >= 3) {
          final modName = parts.sublist(2).join('_');
          t += (_addOnPrices[modName] ?? 0) * qty;
        }
      }
    });
    return t;
  }

  double get _grandTotal {
    final t = _itemsSubtotal;
    return t < 0 ? 0 : t;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _errorView()
                    : _items.isEmpty
                        ? _emptyView()
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _orderItemsCard(),
                                  const SizedBox(height: 24),
                                  _orderSummary(),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar:
          (!_isLoading && _error == null && _items.isNotEmpty)
              ? _payButton()
              : null,
    );
  }

  Widget _header(BuildContext context) {
    final concessionName =
        _items.isNotEmpty ? _items.first.concessionName : 'Cart';

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        20,
      ),
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
          Expanded(
            child: Text(
              concessionName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyView() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Your cart is empty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                )),
            const SizedBox(height: 8),
            Text('Add items to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                )),
          ],
        ),
      );

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(_error ?? 'Something went wrong',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.red.shade400, fontSize: 15)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gradientTop),
              ),
            ],
          ),
        ),
      );

  Widget _orderItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gradientTop,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientTop.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order items',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.3,
                  )),
              GestureDetector(
                onTap: _showDeleteConfirmation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_sweep,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white54),
          ...List.generate(_items.length, (i) {
            final item = _items[i];
            final modKey = '${item.itemId}_$i';
            final isLast = i == _items.length - 1;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _orderItemRow(item, i),
                const SizedBox(height: 6),
                _modifierToggleRow(modKey),
                if (_modExpanded[modKey] == true) ...[
                  const SizedBox(height: 8),
                  _addOnsDropdown(modKey),
                ],
                if (!isLast) const Divider(color: Colors.white54),
              ],
            );
          }),
          const Divider(color: Colors.white54),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoreMenuPage(
                  storeImage: '',
                  storeName: GlobalConcession.name,
                ),
              ),
            ),
            child: _actionButton('Add Items', Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _orderItemRow(_OrderItem item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 4),
                Text(
                  item.itemPrice == 0
                      ? 'Free'
                      : '\$${item.itemPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _quantityControls(item, index),
        ],
      ),
    );
  }

  Widget _quantityControls(_OrderItem item, int index) {
    return Row(
      children: [
        InkWell(
          onTap: () => setState(() => _items.removeAt(index)),
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  if (item.quantity > 1) {
                    setState(() => item.quantity--);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.remove, size: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              InkWell(
                onTap: () => setState(() => item.quantity++),
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

  Widget _modifierToggleRow(String modKey) {
    final expanded = _modExpanded[modKey] ?? false;
    return GestureDetector(
      onTap: () => setState(() => _modExpanded[modKey] = !expanded),
      child: Row(
        children: [
          const Icon(Icons.tune, color: Colors.white70, size: 15),
          const SizedBox(width: 5),
          const Text('Food Modifier',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            )),
          Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _addOnsDropdown(String modKey) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.fastfood, color: AppColors.gradientTop, size: 18),
            SizedBox(width: 8),
            Text('Food mods',
              style: TextStyle(
                color: AppColors.gradientTop,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              )),
          ]),
          const SizedBox(height: 12),
          ..._addOnPrices.entries
              .map((e) => _addOnItem(modKey, e.key, e.value))
              .toList(),
        ],
      ),
    );
  }

  Widget _addOnItem(String modKey, String name, double price) {
    final qtyKey = '${modKey}_$name';
    final qty = _modQty[qtyKey] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gradientTop,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    )),
                Text(
                  price == 0 ? 'Free' : '+\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
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
                    if (qty > 0) setState(() => _modQty[qtyKey] = qty - 1);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.remove, size: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('$qty',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                InkWell(
                  onTap: () => setState(() => _modQty[qtyKey] = qty + 1),
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

  Widget _orderSummary() {
    double itemsOnly = 0;
    for (int i = 0; i < _items.length; i++) {
      itemsOnly += _items[i].itemPrice * _items[i].quantity;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _summaryRow('Item subtotal', '\$${itemsOnly.toStringAsFixed(2)}'),
        if (_modifierSubtotal > 0)
          _summaryRow(
            'Food modifiers',
            '+\$${_modifierSubtotal.toStringAsFixed(2)}',
            color: Colors.orange.shade700,
          ),
        const Divider(),
        _summaryRow('Total', '\$${_grandTotal.toStringAsFixed(2)}',
            bold: true),
      ],
    );
  }

  Widget _summaryRow(String title, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color,
              )),
          const Spacer(),
          Text(value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color,
              )),
        ],
      ),
    );
  }

  Widget _actionButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Icon(icon, size: 16),
        ],
      ),
    );
  }

  Widget _payButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: GestureDetector(
          onTap: _isProcessingPayment ? null : _showPaymentDialog,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gradientTop,
                  AppColors.gradientTop.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gradientTop.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _isProcessingPayment
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'PAY  \$${_grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
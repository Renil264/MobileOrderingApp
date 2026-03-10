import 'dart:convert';
import 'package:concession_tracker_ui/core/global_ordno.dart';
import 'package:concession_tracker_ui/core/global_selected_item.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/globalconcession.dart';
import 'package:concession_tracker_ui/core/globalmarketdata.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/home_page.dart';
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
  int? orderNo;

  _OrderItem({
    required this.concessionName,
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    required this.quantity,
    required this.totalAmount,
    required this.orderDate,
    this.orderNo,
  });

  factory _OrderItem.fromJson(Map<String, dynamic> json) => _OrderItem(
        concessionName: json['concessionName'] ?? '',
        itemId: json['itemId'] ?? 0,
        itemName: json['itemName'] ?? '',
        itemPrice: (json['itemPrice'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 1,
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        orderDate: DateTime.parse(json['orderDate']),
        orderNo: json['orderNo'],
      );
}

class FoodModifier {
  final int foodModifierId;
  final String foodModifierName;

  FoodModifier({
    required this.foodModifierId,
    required this.foodModifierName,
  });

  factory FoodModifier.fromJson(Map<String, dynamic> json) => FoodModifier(
        foodModifierId: json['foodModifierId'] ?? 0,
        foodModifierName: json['foodModifierName'] ?? '',
      );

  @override
  String toString() => foodModifierName;
}

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  List<_OrderItem> _items = [];
  bool _isProcessingPayment = false;
  List<FoodModifier> _foodModifiers = [];
  bool _modsLoading = false;

  final Map<String, bool> _modExpanded = {};
  final Map<String, bool> _modifierSelected = {};
  final Map<String, bool> _modifierSubmitting = {};

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchOrders();
    _fetchFoodModifiers();
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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
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

  // ── Quick error alert (only for negative/failed results) ───
  void _showErrorAlert(String message) {
    if (!mounted) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (ctx, anim, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline_rounded,
                      color: Colors.red.shade400, size: 30),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Quick confirm alert for destructive actions ─────────────
  void _showConfirmAlert({
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    IconData icon = Icons.warning_amber_rounded,
    Color iconColor = const Color(0xFFF59E0B),
    Color iconBg = const Color(0xFFFFFBEB),
    Color confirmColor = Colors.red,
  }) {
    if (!mounted) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (ctx, anim, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onConfirm();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: confirmColor.withOpacity(0.1),
                          foregroundColor: confirmColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          confirmLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchFoodModifiers() async {
    try {
      setState(() => _modsLoading = true);

      final concessionId = GlobalSelectedItem.concessionId;
      final url =
          'http://192.168.10.144/ConcessionTracker/api/Users/food-modifiers/$concessionId';

      print('═══════════════════════════════════════');
      print('[OrderSummaryPage] GET Food Modifiers');
      print('[OrderSummaryPage] URL: $url');
      print('═══════════════════════════════════════');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('[OrderSummaryPage] Status: ${response.statusCode}');
      print('[OrderSummaryPage] Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final modifiers = jsonList
            .map((item) => FoodModifier.fromJson(item as Map<String, dynamic>))
            .toList();

        if (mounted) {
          setState(() {
            _foodModifiers = modifiers;
            _modsLoading = false;
          });
        }

        print('[OrderSummaryPage] ✅ Loaded ${modifiers.length} modifiers');
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      print('[OrderSummaryPage] ❌ Error: $e');
      if (mounted) {
        setState(() => _modsLoading = false);
        _showErrorAlert(
            'Failed to load food modifiers.\n${e.toString().replaceAll('Exception: ', '')}');
      }
    }
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
      print('[OrderSummaryPage] GET Orders');
      print('[OrderSummaryPage] URL: $url');
      print('═══════════════════════════════════════');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('[OrderSummaryPage] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          List<dynamic> items = [];

          if (jsonResponse is Map) {
            final data = jsonResponse['data'];
            if (data != null && data is List) {
              items = List<dynamic>.from(data);
            }
          } else if (jsonResponse is List) {
            items = List<dynamic>.from(jsonResponse);
          }

          if (items.isEmpty) {
            setState(() {
              _items = [];
              _isLoading = false;
            });
            return;
          }

          final orderItems = <_OrderItem>[];
          for (var item in items) {
            if (item is Map<String, dynamic>) {
              orderItems.add(_OrderItem.fromJson(item));
            }
          }

          for (int i = 0; i < orderItems.length; i++) {
            final key = '${orderItems[i].itemId}_$i';
            _modExpanded[key] = false;
          }

          setState(() {
            _items = orderItems;
            _isLoading = false;
          });
          print('[OrderSummaryPage] ✅ Orders loaded');
        } catch (e) {
          print('[OrderSummaryPage] ❌ Parse Error: $e');
          setState(() {
            _items = [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      print('[OrderSummaryPage] ❌ Error: $e');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── Add food modifier API ──────────────────────────────────
  Future<void> _addFoodModifier(
    int foodModifierId,
    String foodModifierName,
    int itemId,
    _OrderItem item,
  ) async {
    try {
      final concessionId = GlobalSelectedItem.concessionId;
      final customerId = GlobalUser.id;
      final orderNo = item.orderNo ?? GlobalOrderNo.orderNo;

      final url =
          'http://192.168.10.144/ConcessionTracker/api/Users/add-food-modifier';

      final requestBody = {
        'concessionId': concessionId,
        'orderNo': orderNo,
        'customerId': customerId,
        'itemId': itemId,
        'foodModifierId': foodModifierId,
        'foodModifierName': foodModifierName,
      };

      print('═══════════════════════════════════════');
      print('[OrderSummaryPage] POST Add Food Modifier');
      print('[OrderSummaryPage] URL: $url');
      print('[OrderSummaryPage] Body: ${jsonEncode(requestBody)}');
      print('═══════════════════════════════════════');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      print('[OrderSummaryPage] Status: ${response.statusCode}');
      print('[OrderSummaryPage] Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          final message = jsonResponse['message'] ?? 'Added successfully';
          final responseOrderNo = jsonResponse['orderNo'];
          final responseItemId = jsonResponse['itemId'];
          final responseModifierId = jsonResponse['modifierId'];

          print('[OrderSummaryPage] ✅ Response Message: $message');
          print('[OrderSummaryPage] ✅ OrderNo: $responseOrderNo');
          print('[OrderSummaryPage] ✅ ItemId: $responseItemId');
          print('[OrderSummaryPage] ✅ ModifierId: $responseModifierId');
          // No UI feedback for success
        } catch (parseError) {
          print('[OrderSummaryPage] ❌ Parse Error: $parseError');
        }
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      print('[OrderSummaryPage] ❌ Error: $e');
      _showErrorAlert(
          'Failed to add $foodModifierName.\n${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // ── Get food modifier status API ──────────────────────────
  Future<bool> _getFoodModifierStatus(
    int foodModifierId,
    int itemId,
    _OrderItem item,
  ) async {
    try {
      final concessionId = GlobalSelectedItem.concessionId;
      final customerId = GlobalUser.id;
      final orderNo = item.orderNo ?? GlobalOrderNo.orderNo;

      final url =
          'http://192.168.10.144/ConcessionTracker/api/Users/get-food-modifier-status'
          '?concessionId=$concessionId'
          '&orderNo=$orderNo'
          '&customerId=$customerId'
          '&itemId=$itemId'
          '&foodModifierId=$foodModifierId';

      print('═══════════════════════════════════════');
      print('[OrderSummaryPage] GET Food Modifier Status');
      print('[OrderSummaryPage] URL: $url');
      print('═══════════════════════════════════════');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('[OrderSummaryPage] Status: ${response.statusCode}');
      print('[OrderSummaryPage] Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          final isModifierSelected =
              jsonResponse['isModifierSelected'] ?? false;
          print('[OrderSummaryPage] ✅ Modifier Selected: $isModifierSelected');
          return isModifierSelected;
        } catch (parseError) {
          print('[OrderSummaryPage] ❌ Parse Error: $parseError');
          return false;
        }
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      print('[OrderSummaryPage] ❌ Error fetching modifier status: $e');
      // Silent failure for status fetch — just return false
      return false;
    }
  }

  // ── Remove food modifier API ───────────────────────────────
  Future<void> _removeFoodModifier(
    int foodModifierId,
    String foodModifierName,
    int itemId,
    _OrderItem item,
  ) async {
    try {
      final concessionId = GlobalSelectedItem.concessionId;
      final customerId = GlobalUser.id;
      final orderNo = item.orderNo ?? GlobalOrderNo.orderNo;

      final url =
          'http://192.168.10.144/ConcessionTracker/api/Users/remove-food-modifier'
          '?concessionId=$concessionId'
          '&orderNo=$orderNo'
          '&customerId=$customerId'
          '&itemId=$itemId'
          '&foodModifierId=$foodModifierId';

      print('═══════════════════════════════════════');
      print('[OrderSummaryPage] Remove Food Modifier');
      print('[OrderSummaryPage] URL: $url');
      print('═══════════════════════════════════════');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('[OrderSummaryPage] Status: ${response.statusCode}');
      print('[OrderSummaryPage] Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          final message = jsonResponse['message'] ?? 'Removed successfully';
          print('[OrderSummaryPage] ✅ Response Message: $message');
          // No UI feedback for success
        } catch (parseError) {
          print('[OrderSummaryPage] ❌ Parse Error: $parseError');
        }
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      print('[OrderSummaryPage] ❌ Error: $e');
      _showErrorAlert(
          'Failed to remove $foodModifierName.\n${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _deleteEntireOrder() async {
    final marketId = GlobalMarketData.marketId;
    final userId = GlobalUser.id;

    try {
      final url =
          'http://192.168.10.144/ConcessionTracker/api/Users/active-orders/$marketId/$userId';

      print('═══════════════════════════════════════');
      print('[OrderSummaryPage] DELETE Order');
      print('[OrderSummaryPage] URL: $url');
      print('═══════════════════════════════════════');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('[OrderSummaryPage] Delete Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success — navigate back silently
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      _showErrorAlert(
          'Failed to delete order.\n${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _deleteOrderItem(_OrderItem item, int index) async {
    try {
      final concessionId = GlobalSelectedItem.concessionId;
      final customerId = GlobalUser.id;
      var orderNo = GlobalOrderNo.orderNo;

      final url =
          'http://192.168.10.144/ConcessionTracker/api/Users/delete-order';

      final requestBody = {
        'concessionId': concessionId,
        'orderNo': orderNo,
        'itemId': item.itemId,
        'customerId': customerId,
      };

      print('═══════════════════════════════════════');
      print('[OrderSummaryPage] DELETE Item');
      print('[OrderSummaryPage] Body: ${jsonEncode(requestBody)}');
      print('═══════════════════════════════════════');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('[OrderSummaryPage] Delete Item Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Success — update state silently
        setState(() {
          _items.removeAt(index);
        });
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      _showErrorAlert(
          'Failed to delete item.\n${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // ── Confirm before deleting a single item ──────────────────
  void _confirmDeleteItem(_OrderItem item, int index) {
    _showConfirmAlert(
      title: 'Remove Item',
      message: 'Remove "${item.itemName}" from your order?',
      confirmLabel: 'Remove',
      onConfirm: () => _deleteOrderItem(item, index),
    );
  }

  // ── Confirm before deleting entire order ───────────────────
  void _showDeleteConfirmation() {
    _showConfirmAlert(
      title: 'Delete Order',
      message:
          'Are you sure you want to delete this entire order? This action cannot be undone.',
      confirmLabel: 'Delete',
      onConfirm: _deleteEntireOrder,
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
            'Your payment has been processed successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.6),
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
                  Navigator.of(ctx).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
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
    // No UI feedback for cancel — just reset state silently
  }

  double get _itemsSubtotal {
    double t = 0;
    for (int i = 0; i < _items.length; i++) {
      t += _items[i].itemPrice * _items[i].quantity;
    }
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
        _items.isNotEmpty ? _items.first.concessionName : 'Order Summary';

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
            Icon(Icons.receipt_long_outlined,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No active orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
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
                  _foodModifiersDropdown(modKey, item),
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
          // ── Triggers confirm alert before deleting ──
          onTap: () => _confirmDeleteItem(item, index),
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.delete_outline, color: Colors.red, size: 18),
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

  Widget _foodModifiersDropdown(String modKey, _OrderItem item) {
    if (_modsLoading) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_foodModifiers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No modifiers available',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.fastfood, color: AppColors.gradientTop, size: 18),
            SizedBox(width: 8),
            Text('Food modifiers',
                style: TextStyle(
                  color: AppColors.gradientTop,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                )),
          ]),
          const SizedBox(height: 12),
          ..._foodModifiers.map((modifier) {
            final checkboxKey = '${item.itemId}_${modifier.foodModifierId}';
            final isSelected = _modifierSelected[checkboxKey] ?? false;
            final isSubmitting = _modifierSubmitting[checkboxKey] ?? false;

            // Load modifier status on first render
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_modifierSubmitting.containsKey(checkboxKey) &&
                  !_modifierSelected.containsKey(checkboxKey)) {
                _getFoodModifierStatus(
                  modifier.foodModifierId,
                  item.itemId,
                  item,
                ).then((status) {
                  if (mounted) {
                    setState(() {
                      _modifierSelected[checkboxKey] = status;
                    });
                  }
                });
              }
            });

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gradientTop,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      modifier.foodModifierName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            if (value == true) {
                              setState(() {
                                _modifierSelected[checkboxKey] = true;
                                _modifierSubmitting[checkboxKey] = true;
                              });

                              print('[OrderSummaryPage] ✅ Checkbox Checked');
                              print(
                                  '[OrderSummaryPage]    Modifier: ${modifier.foodModifierName}');
                              print(
                                  '[OrderSummaryPage]    ItemId: ${item.itemId}');

                              _addFoodModifier(
                                modifier.foodModifierId,
                                modifier.foodModifierName,
                                item.itemId,
                                item,
                              ).then((_) {
                                setState(() {
                                  _modifierSubmitting[checkboxKey] = false;
                                });
                              }).catchError((_) {
                                setState(() {
                                  _modifierSubmitting[checkboxKey] = false;
                                  _modifierSelected[checkboxKey] = false;
                                });
                              });
                            } else {
                              setState(() {
                                _modifierSelected[checkboxKey] = false;
                                _modifierSubmitting[checkboxKey] = true;
                              });

                              print('[OrderSummaryPage] ❌ Checkbox Unchecked');
                              print(
                                  '[OrderSummaryPage]    Modifier: ${modifier.foodModifierName}');
                              print(
                                  '[OrderSummaryPage]    ItemId: ${item.itemId}');

                              _removeFoodModifier(
                                modifier.foodModifierId,
                                modifier.foodModifierName,
                                item.itemId,
                                item,
                              ).then((_) {
                                setState(() {
                                  _modifierSubmitting[checkboxKey] = false;
                                });
                              }).catchError((_) {
                                setState(() {
                                  _modifierSubmitting[checkboxKey] = false;
                                  _modifierSelected[checkboxKey] = true;
                                });
                              });
                            }
                          },
                          activeColor: Colors.white,
                          checkColor: AppColors.gradientTop,
                        ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _orderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _summaryRow('Item subtotal', '\$${_itemsSubtotal.toStringAsFixed(2)}'),
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
                  AppColors.greenCTA,
                  AppColors.greenCTA.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greenCTA.withOpacity(0.3),
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
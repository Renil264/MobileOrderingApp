import 'dart:convert';
import 'package:concession_tracker_ui/core/global_market.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/globalconcession.dart';
import 'package:concession_tracker_ui/core/globalmarketdata.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/payment_options_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/store_menu_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────
class _OrderItem {
  final String concessionName;
  final int itemId;
  final String itemName;
  final double itemPrice;
  int quantity; // mutable — user can edit
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

// ─────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────
class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  // ── API state ────────────────────────────────────────────────────
  bool _isLoading = true;
  String? _error;
  List<_OrderItem> _items = [];

  // ── Per-item food-modifier expand state  key = itemId_listIndex ──
  final Map<String, bool> _modExpanded = {};

  // ── Per-item modifier quantities  key = "itemId_index_modName" ──
  final Map<String, int> _modQty = {};

  static const Map<String, double> _addOnPrices = {
    'Pepsi 330ml': 2.00,
    'Fanta 330ml': 2.00,
    'Fries (Small)': 2.00,
    'Ketch Up': 1.00,
  };

  // Credits (always applied)
  final int _totalCredits = 2;

  // ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // ── FETCH ─────────────────────────────────────────────────────────
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final marketId = GlobalMarketData.marketId; // e.g. 12
      final userId   = GlobalUser.id;         // e.g. 1076
      final url =
          'http://192.168.10.144/ConcessionTracker/api/Users/active-orders/$marketId/$userId';

      print('══════════════════════════════════════');
      print('[OrderSummaryPage] GET $url');
      print('══════════════════════════════════════');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('[OrderSummaryPage] Status : ${response.statusCode}');
      print('[OrderSummaryPage] Body   : ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        final items = decoded.map((e) => _OrderItem.fromJson(e)).toList();

        // Initialise modifier state per item
        for (int i = 0; i < items.length; i++) {
          final key = '${items[i].itemId}_$i';
          _modExpanded[key] = false;
          for (final mod in _addOnPrices.keys) {
            _modQty['${key}_$mod'] = 0;
          }
        }

        setState(() {
          _items = items;
          _isLoading = false;
        });
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── TOTALS ────────────────────────────────────────────────────────
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
    final t = _itemsSubtotal - _totalCredits;
    return t < 0 ? 0 : t;
  }

  // ─────────────────────────────────────────────────────────────────
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
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _orderItemsCard(),
                                const SizedBox(height: 24),
                                _orderSummary(),
                                const SizedBox(height: 24),
                                _creditsWidget(),
                                const SizedBox(height: 90),
                              ],
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

  // ── HEADER ────────────────────────────────────────────────────────
  Widget _header(BuildContext context) {
    final concessionName =
        _items.isNotEmpty ? _items.first.concessionName : 'Order Summary';

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [AppColors.gradientTop, AppColors.gradientTop]),
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
                  fontWeight: FontWeight.bold),
            ),
          ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchOrders,
          ),
        ],
      ),
    );
  }

  // ── EMPTY / ERROR ─────────────────────────────────────────────────
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
                    color: Colors.grey.shade500)),
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

  // ── ORDER ITEMS CARD ──────────────────────────────────────────────
  Widget _orderItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gradientTop,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order items',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
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
                    storeImage: '', storeName: GlobalConcession.name),
              ),
            ),
            child: _actionButton('Add Items', Icons.add),
          ),
        ],
      ),
    );
  }

  // ── SINGLE ITEM ROW ───────────────────────────────────────────────
  Widget _orderItemRow(_OrderItem item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  item.itemPrice == 0
                      ? 'Free'
                      : '\$${item.itemPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Delete + quantity controls
          _quantityControls(item, index),
        ],
      ),
    );
  }

  // ── QUANTITY CONTROLS (editable) ──────────────────────────────────
  Widget _quantityControls(_OrderItem item, int index) {
    return Row(
      children: [
        // Delete button
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
        // − / count / + row
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
                    child: Icon(Icons.remove, size: 16)),
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
                    child: Icon(Icons.add, size: 16)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── MODIFIER TOGGLE ROW ───────────────────────────────────────────
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
                  fontWeight: FontWeight.w500)),
          Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }

  // ── ADD-ONS DROPDOWN ──────────────────────────────────────────────
  Widget _addOnsDropdown(String modKey) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
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
                    fontSize: 14)),
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
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500)),
                Text(
                  price == 0 ? 'Free' : '+\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    if (qty > 0) setState(() => _modQty[qtyKey] = qty - 1);
                  },
                  child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.remove, size: 16)),
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
                      child: Icon(Icons.add, size: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ORDER SUMMARY ─────────────────────────────────────────────────
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
          _summaryRow('Food modifiers',
              '+\$${_modifierSubtotal.toStringAsFixed(2)}',
              color: Colors.orange.shade700),
        _summaryRow('Credits applied', '-\$$_totalCredits',
            color: Colors.green),
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
                  color: color)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }

  // ── CREDITS SLAB ─────────────────────────────────────────────────
  Widget _creditsWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.gradientTop, AppColors.gradientBottom]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.white),
          const SizedBox(width: 8),
          Text('Credits Applied: $_totalCredits',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '-\$$_totalCredits',
              style: const TextStyle(
                  color: AppColors.gradientTop,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── ACTION BUTTON ─────────────────────────────────────────────────
  Widget _actionButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
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

  // ── PAY BUTTON ────────────────────────────────────────────────────
  Widget _payButton() {
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
              'PAY  \$${_grandTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
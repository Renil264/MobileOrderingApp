import 'package:concession_tracker_ui/core/api/active_order_service.dart';
import 'package:concession_tracker_ui/core/global_market.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/globalconcession.dart';
import 'package:concession_tracker_ui/core/globalmarketdata.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/payment_options_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/store_menu_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _Cart();
}

class _Cart extends State<Cart> {
  // ── Services ────────────────────────────────────────────────────
  final ActiveOrdersService _ordersService = ActiveOrdersService();

  // ── State ────────────────────────────────────────────────────────
  bool _isLoading = true;
  String? _errorMessage;
  List<ActiveOrderItem> _orderItems = [];

  // Per-item food modifier expand state  key = itemId_index
  final Map<String, bool> _modifierExpanded = {};

  // Per-item food modifier quantities  key = "itemIndex_modName"
  final Map<String, int> _modifierQuantities = {};

  // Add-on options with prices
  static const Map<String, double> _addOnPrices = {
    'Pepsi 330ml': 2.00,
    'Fanta 330ml': 2.00,
    'Fries (Small)': 2.00,
    'Ketch Up': 1.00,
  };

  // Credits
  final int _totalCredits = 2;
  int _appliedCredits = 0;
  bool _creditsExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // ── FETCH ─────────────────────────────────────────────────────────
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _ordersService.fetchActiveOrders(
        marketId: GlobalMarketData.marketId,   // e.g. 12
        userId: GlobalUser.id,             // e.g. 1076
      );

      // Initialise modifier state for every item
      for (int i = 0; i < items.length; i++) {
        final key = '${items[i].itemId}_$i';
        _modifierExpanded[key] = false;
        for (final mod in _addOnPrices.keys) {
          _modifierQuantities['${key}_$mod'] = 0;
        }
      }

      setState(() {
        _orderItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── PRICE CALCULATIONS ────────────────────────────────────────────
  double get _itemsSubtotal {
    double total = 0;
    for (int i = 0; i < _orderItems.length; i++) {
      final item = _orderItems[i];
      total += item.itemPrice * item.quantity;

      // Add modifier costs
      final key = '${item.itemId}_$i';
      for (final entry in _addOnPrices.entries) {
        final qty = _modifierQuantities['${key}_${entry.key}'] ?? 0;
        total += entry.value * qty;
      }
    }
    return total;
  }

  double get _grandTotal {
    final t = _itemsSubtotal - _appliedCredits;
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
                : _errorMessage != null
                    ? _errorView()
                    : _orderItems.isEmpty
                        ? _emptyView()
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _orderItemsSection(),
                                const SizedBox(height: 24),
                                _orderSummary(),
                                const SizedBox(height: 24),
                                _creditsSection(),
                                const SizedBox(height: 90),
                              ],
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar:
          (!_isLoading && _errorMessage == null && _orderItems.isNotEmpty)
              ? _payButton()
              : null,
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────
  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 24,
        16,
        24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          const Text(
            'Cart',
            style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.gradientTop),
            onPressed: _fetchOrders,
          ),
        ],
      ),
    );
  }

  // ── EMPTY / ERROR STATES ─────────────────────────────────────────
  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No active orders',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('Browse the menu to add items',
              style:
                  TextStyle(fontSize: 14, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade400, fontSize: 15)),
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
  }

  // ── ORDER ITEMS SECTION ──────────────────────────────────────────
  Widget _orderItemsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gradientTop,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Concession name badge
          if (_orderItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storefront, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _orderItems.first.concessionName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
            ),

          const Text(
            'Order items',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const Divider(color: Colors.white54),

          // List of order items from API
          ...List.generate(_orderItems.length, (i) {
            final item = _orderItems[i];
            final modKey = '${item.itemId}_$i';
            final isLastItem = i == _orderItems.length - 1;

            return Column(
              children: [
                _orderItemRow(item, i, modKey),
                // Food Modifier per item
                _foodModifierRow(modKey),
                if (_modifierExpanded[modKey] == true)
                  _addOnsDropdown(modKey),
                if (!isLastItem) const Divider(color: Colors.white54),
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

  // ── SINGLE ORDER ITEM ROW ─────────────────────────────────────────
  Widget _orderItemRow(ActiveOrderItem item, int index, String modKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
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
          // Quantity badge (read-only from API)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'x${item.quantity}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gradientTop),
            ),
          ),
        ],
      ),
    );
  }

  // ── FOOD MODIFIER TOGGLE ROW ──────────────────────────────────────
  Widget _foodModifierRow(String modKey) {
    return GestureDetector(
      onTap: () => setState(
          () => _modifierExpanded[modKey] = !(_modifierExpanded[modKey] ?? false)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            const Icon(Icons.tune, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            const Text(
              'Food Modifier',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
            Icon(
              (_modifierExpanded[modKey] ?? false)
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ── ADD-ONS DROPDOWN ──────────────────────────────────────────────
  Widget _addOnsDropdown(String modKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                    fontSize: 14),
              ),
            ],
          ),
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
    final qty = _modifierQuantities[qtyKey] ?? 0;

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
                        color: Colors.white, fontWeight: FontWeight.w500)),
                Text(
                  price == 0 ? 'Free' : '+\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
                      if (qty > 0) _modifierQuantities[qtyKey] = qty - 1;
                    });
                  },
                  child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.remove, size: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('$qty',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                ),
                InkWell(
                  onTap: () =>
                      setState(() => _modifierQuantities[qtyKey] = qty + 1),
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
    // Modifier total
    double modifierTotal = 0;
    _modifierQuantities.forEach((key, qty) {
      if (qty > 0) {
        // Extract mod name from key: itemId_index_modName
        final parts = key.split('_');
        if (parts.length >= 3) {
          final modName = parts.sublist(2).join('_');
          modifierTotal += (_addOnPrices[modName] ?? 0) * qty;
        }
      }
    });

    double itemsTotal = 0;
    for (int i = 0; i < _orderItems.length; i++) {
      itemsTotal +=
          _orderItems[i].itemPrice * _orderItems[i].quantity;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order summary',
            style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _summaryRow('Item subtotal',
            '\$${itemsTotal.toStringAsFixed(2)}'),
        if (modifierTotal > 0)
          _summaryRow(
              'Food modifiers', '+\$${modifierTotal.toStringAsFixed(2)}',
              color: Colors.orange.shade700),
        if (_appliedCredits > 0)
          _summaryRow('Credits applied',
              '-\$${_appliedCredits.toStringAsFixed(2)}',
              color: Colors.green),
        const Divider(),
        _summaryRow(
            'Total', '\$${_grandTotal.toStringAsFixed(2)}',
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
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }

  // ── CREDITS ───────────────────────────────────────────────────────
  Widget _creditsSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () =>
              setState(() => _creditsExpanded = !_creditsExpanded),
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
                Text('Available Credits: $_totalCredits',
                    style: const TextStyle(color: Colors.white)),
                if (_appliedCredits > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_appliedCredits applied',
                      style: const TextStyle(
                          color: AppColors.gradientTop,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
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
        if (_creditsExpanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.gradientTop, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.stars, color: AppColors.gradientTop),
                  const SizedBox(width: 8),
                  Text('You have $_totalCredits credits',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
                const SizedBox(height: 12),
                Text(
                    'Apply all credits to get \$${_totalCredits.toStringAsFixed(2)} discount',
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 14)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradientTop,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _appliedCredits == 0
                        ? () => setState(() {
                              _appliedCredits = _totalCredits;
                              _creditsExpanded = false;
                            })
                        : null,
                    child: Text(
                      _appliedCredits == 0
                          ? 'Apply Credits'
                          : 'Already Applied',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (_appliedCredits > 0) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () =>
                          setState(() => _appliedCredits = 0),
                      child: const Text('Remove Credits',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
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
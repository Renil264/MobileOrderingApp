import 'package:concession_tracker_ui/core/api/saved_item.dart';
import 'package:concession_tracker_ui/core/global_market.dart';
import 'package:concession_tracker_ui/core/global_selected_item.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/globalconcession.dart';
import 'package:concession_tracker_ui/core/models/saved_item_model.dart';
import 'package:concession_tracker_ui/features/auth/domain/entities/items_by_category.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itembycategory/item_by_category_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itembycategory/item_by_category_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itembycategory/item_by_category_state.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itemcategory/item_by_category_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itemcategory/item_by_category_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itemcategory/item_by_category_state.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/main_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/order_summary_page.dart';
import 'package:concession_tracker_ui/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

// ── Import the order service ───────────────────────────────────────
import 'package:concession_tracker_ui/core/api/create_order_service.dart';


class StoreMenuPage extends StatefulWidget {
  final String storeName;
  final String storeImage;

  const StoreMenuPage( {
    super.key,
    required this.storeName, required this.storeImage,
   
  });

  @override
  State<StoreMenuPage> createState() => _StoreMenuPageState();
}

class _StoreMenuPageState extends State<StoreMenuPage> {
  int _selectedCategoryId = -1;
  final Map<String, bool> _likedItems = {};
  final SaveItemService _saveItemService = SaveItemService();

  // ── Order service ─────────────────────────────────────────────────
  final CreateOrderService _orderService = CreateOrderService();

  // ── Track which item is currently being added (to show loader) ───
  final Set<int> _addingItems = {};

  late TextEditingController _searchController;
  String _searchQuery = '';
  List<ItemByCategory> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    GlobalConcession.setName(widget.storeName);

    print('══════════════════════════════════════');
    print('[StoreMenuPage] storeName : "${widget.storeName}"');
    print('[StoreMenuPage] userId    : ${GlobalUser.id}');
    print('[StoreMenuPage] userName  : "${GlobalUser.name}"');
    print('[StoreMenuPage] userEmail : "${GlobalUser.email}"');
    print('══════════════════════════════════════');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() =>
      setState(() => _searchQuery = _searchController.text.toLowerCase());

  List<ItemByCategory> _getFilteredItems(List<ItemByCategory> items) {
    if (_searchQuery.isEmpty) return items;
    return items
        .where((item) =>
            item.itemName.toLowerCase().contains(_searchQuery) ||
            item.itemPrice.toString().contains(_searchQuery))
        .toList();
  }

  LoadAllItems _loadAllEvent() => LoadAllItems(
        concessionName: widget.storeName,
        userId: GlobalUser.id,
        userName: GlobalUser.name,
        userEmail: GlobalUser.email,
      );

  // ─────────────────────────────────────────────────────────────────
  // CREATE ORDER — called when ADD is tapped
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onAddItem(ItemByCategory item) async {
    // Prevent double-tap
    if (_addingItems.contains(item.itemId)) return;

    setState(() => _addingItems.add(item.itemId));

    try {
      final request = CreateOrderRequest(
        concessionId: GlobalSelectedItem.concessionId,
        customerId: GlobalUser.id,
        customerName: GlobalUser.name,
        items: [
          OrderItem(
            itemId: item.itemId,
            itemName: item.itemName,
            quantity: 1,
            itemPrice: item.itemPrice,
          ),
        ],
      );

      print('══════════════════════════════════════');
      print('[ADD] Placing order...');
      print('concessionId : ${request.concessionId}');
      print('customerId   : ${request.customerId}');
      print('customerName : ${request.customerName}');
      print('itemId       : ${item.itemId}');
      print('itemName     : ${item.itemName}');
      print('itemPrice    : ${item.itemPrice}');
      print('══════════════════════════════════════');

      final response = await _orderService.createOrder(request);

      print('[ADD] Order created. orderNo: ${response.orderNo}');

      if (!mounted) return;

      // ── Success snackbar ─────────────────────────────────────────
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${response.message} (Order #${response.orderNo})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );

      // ── Navigate to OrderSummaryPage ─────────────────────────────
      await GlobalSelectedItem.set(
        itemId: item.itemId,
        categoryId: item.categoryId,
        concessionId: GlobalSelectedItem.concessionId,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderSummaryPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().replaceAll('Exception: ', '');
      print('[ADD] Error: $errorMessage');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Failed to place order: $errorMessage',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _addingItems.remove(item.itemId));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // SAVE / UNSAVE ITEM (heart icon)
  // ─────────────────────────────────────────────────────────────────
  Future<void> _toggleSaveItem(ItemByCategory item) async {
    final isCurrentlyLiked = _likedItems[item.itemName] ?? false;

    setState(() {
      _likedItems[item.itemName] = !isCurrentlyLiked;
    });

    try {
      if (!isCurrentlyLiked) {
        final request = SaveItemRequest(
          concessionId: GlobalSelectedItem.concessionId,
          itemId: item.itemId,
          customerId: GlobalUser.id,
          categoryId: item.categoryId,
          itemName: item.itemName,
          itemPrice: item.itemPrice,
        );

        final response = await _saveItemService.saveItem(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(response.message,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
              ]),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                    child: Text('Item removed from favorites',
                        style: TextStyle(fontWeight: FontWeight.w500))),
              ]),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _likedItems[item.itemName] = isCurrentlyLiked);
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(errorMessage,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
            ]),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ItemCategoryBloc>()
            ..add(FetchItemCategories(GlobalMarket.marketName)),
        ),
        BlocProvider(
          create: (_) => sl<ItemByCategoryBloc>()
            ..add(_loadAllEvent()),
        ),
      ],
      child: Builder(
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              _header(ctx),
              _search(),
              _categorySection(ctx),
              Expanded(child: _menuGrid(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categorySection(BuildContext context) {
    return BlocBuilder<ItemCategoryBloc, ItemCategoryState>(
      builder: (context, state) {
        if (state is ItemCategoryLoading || state is ItemCategoryInitial) {
          return _categoryRow(context, []);
        }
        if (state is ItemCategoryLoaded) {
          return _categoryRow(
            context,
            state.categories
                .map((c) =>
                    _CategoryMeta(id: c.categoryId, name: c.categoryName))
                .toList(),
          );
        }
        return _categoryRow(context, []);
      },
    );
  }

  Widget _categoryRow(BuildContext context, List<_CategoryMeta> cats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text('Categories',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cats.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _chip(
                  context,
                  id: -1,
                  label: 'All',
                  icon: Icons.grid_view_rounded,
                  isSelected: _selectedCategoryId == -1,
                  onTap: () {
                    setState(() => _selectedCategoryId = -1);
                    context.read<ItemByCategoryBloc>().add(_loadAllEvent());
                  },
                );
              }

              final cat = cats[index - 1];
              return _chip(
                context,
                id: cat.id,
                label: cat.name,
                isSelected: _selectedCategoryId == cat.id,
                onTap: () async {
                  setState(() => _selectedCategoryId = cat.id);
                  await GlobalConcession.set(
                    concessionName: widget.storeName,
                    categoryId: cat.id,
                  );
                  if (context.mounted) {
                    context.read<ItemByCategoryBloc>().add(FetchItemsByCategory(
                          concessionName: widget.storeName,
                          categoryId: cat.id,
                        ));
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _chip(
    BuildContext context, {
    required int id,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData icon = Icons.restaurant,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.gradientBottom, AppColors.gradientTop])
                    : LinearGradient(colors: [
                        Colors.grey.shade400,
                        Colors.grey.shade500,
                      ]),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: AppColors.gradientTop.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]
                    : [],
              ),
              child: Icon(icon, color: Colors.white, size: 25),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 72,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.7,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.gradientTop : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuGrid(BuildContext context) {
    return BlocBuilder<ItemByCategoryBloc, ItemByCategoryState>(
      builder: (context, state) {
        if (state is ItemByCategoryLoading || state is ItemByCategoryInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ItemByCategoryError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                  const SizedBox(height: 12),
                  Text('Could not load menu.\n${state.message}',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.red[400], fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_selectedCategoryId == -1) {
                        context
                            .read<ItemByCategoryBloc>()
                            .add(_loadAllEvent());
                      } else {
                        context.read<ItemByCategoryBloc>().add(
                            FetchItemsByCategory(
                              concessionName: widget.storeName,
                              categoryId: _selectedCategoryId,
                            ));
                      }
                    },
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

        if (state is ItemByCategoryLoaded) {
          _filteredItems = _getFilteredItems(state.items);

          if (state.items.isEmpty) {
            return const Center(
              child: Text('No items available.',
                  style: TextStyle(color: Colors.grey, fontSize: 15)),
            );
          }

          if (_filteredItems.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, color: Colors.grey.shade400, size: 64),
                  const SizedBox(height: 16),
                  Text('No items found for "$_searchQuery"',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('Try searching with different keywords',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 14)),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final sw = MediaQuery.of(context).size.width;
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredItems.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: sw > 600 ? 3 : 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: sw > 600 ? 0.70 : 0.68,
                      ),
                      itemBuilder: (context, index) =>
                          _menuItemCard(context, _filteredItems[index]),
                    );
                  },
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // MENU ITEM CARD
  // ─────────────────────────────────────────────────────────────────
  Widget _menuItemCard(BuildContext context, ItemByCategory item) {
    final isLiked = _likedItems[item.itemName] ?? false;
    final isAdding = _addingItems.contains(item.itemId);

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = constraints.maxHeight * 0.52;
        final isTablet = MediaQuery.of(context).size.width >= 600;
        final buttonFont = isTablet ? 15.0 : 14.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              // ── IMAGE + LIKE ──────────────────────────────────────
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: SvgPicture.asset(
                          'assets/food_icon.svg',
                          fit: BoxFit.cover,
                          placeholderBuilder: (BuildContext context) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: Icon(Icons.fastfood,
                                  size: isTablet ? 60 : 48,
                                  color: Colors.grey.shade500),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleSaveItem(item),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isLiked ? Colors.redAccent : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── NAME + PRICE + ADD ────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 14 : 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.itemName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.itemPrice == 0
                                ? 'Free'
                                : '\$${item.itemPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: item.itemPrice == 0
                                  ? Colors.green
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      // ── ADD BUTTON ────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: isAdding ? null : () => _onAddItem(item),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: isAdding
                                  ? AppColors.gradientTop.withOpacity(0.6)
                                  : AppColors.gradientTop,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: isAdding
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'ADD',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: buttonFont),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────
  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientTop, AppColors.gradientTop],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainShellPage()),
              (route) => false,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.storeName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────────────────────────
  Widget _search() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: 'Search items...',
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            prefixIcon:
                Icon(Icons.search, color: Colors.grey.shade700, size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      FocusScope.of(context).unfocus();
                    },
                    child: Icon(Icons.close,
                        color: Colors.grey.shade700, size: 20),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryMeta {
  final int id;
  final String name;
  _CategoryMeta({required this.id, required this.name});
}
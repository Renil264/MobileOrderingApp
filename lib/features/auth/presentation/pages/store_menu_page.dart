import 'package:concession_tracker_ui/core/global_market.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/globalconcession.dart';
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
import '../../../../core/constants/app_colors.dart';

class StoreMenuPage extends StatefulWidget {
  final String storeName;
  final String storeImage;

  const StoreMenuPage({
    super.key,
    required this.storeName,
    required this.storeImage,
  });

  @override
  State<StoreMenuPage> createState() => _StoreMenuPageState();
}

class _StoreMenuPageState extends State<StoreMenuPage> {
  // -1 = "All" selected
  int _selectedCategoryId = -1;
  final Map<String, bool> _likedItems = {};
  
  // ─── SEARCH FUNCTIONALITY ───────────────────────────
  late TextEditingController _searchController;
  String _searchQuery = '';
  List<ItemByCategory> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    // Persist concession name immediately when page opens
    GlobalConcession.setName(widget.storeName);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── SEARCH HANDLER ─────────────────────────────────
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // ─── FILTER ITEMS BASED ON SEARCH QUERY ────────────
  List<ItemByCategory> _getFilteredItems(List<ItemByCategory> items) {
    if (_searchQuery.isEmpty) {
      return items;
    }
    return items
        .where((item) =>
            item.itemName.toLowerCase().contains(_searchQuery) ||
            item.itemPrice.toString().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Loads the category list for the market
        BlocProvider(
          create: (_) => sl<ItemCategoryBloc>()
            ..add(FetchItemCategories(GlobalMarket.marketName)),
        ),
        // Handles both "All items" and "Items by category"
        BlocProvider(
          create: (_) => sl<ItemByCategoryBloc>()
            // Start with all items
            ..add(LoadAllItems(
              concessionName: widget.storeName,
              userId: GlobalUser.id,
              userName: GlobalUser.name,
              userEmail: GlobalUser.email,
            )),
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

  // ─────────────────────────────────────────────────────────────────
  // CATEGORY SECTION — API driven with "All" prepended
  // ─────────────────────────────────────────────────────────────────
  Widget _categorySection(BuildContext context) {
    return BlocBuilder<ItemCategoryBloc, ItemCategoryState>(
      builder: (context, state) {
        // While loading just show the "All" chip
        if (state is ItemCategoryLoading || state is ItemCategoryInitial) {
          return _staticCategoryRow(context, []);
        }
        if (state is ItemCategoryLoaded) {
          return _staticCategoryRow(context, state.categories
              .map((c) => _CategoryMeta(
                    id: c.categoryId,
                    name: c.categoryName,
                  ))
              .toList());
        }
        return _staticCategoryRow(context, []);
      },
    );
  }

  Widget _staticCategoryRow(
      BuildContext context, List<_CategoryMeta> cats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text(
            'Categories',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            // +1 for the "All" chip at index 0
            itemCount: cats.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // ── "All" chip ──────────────────────────────────
                return _categoryChip(
                  context,
                  id: -1,
                  label: 'All',
                  icon: Icons.grid_view_rounded,
                  isSelected: _selectedCategoryId == -1,
                  onTap: () {
                    setState(() => _selectedCategoryId = -1);
                    context.read<ItemByCategoryBloc>().add(LoadAllItems(
                          concessionName: widget.storeName,
                          userId: GlobalUser.id,
                          userName: GlobalUser.name,
                          userEmail: GlobalUser.email,
                        ));
                  },
                );
              }

              final cat = cats[index - 1];
              return _categoryChip(
                context,
                id: cat.id,
                label: cat.name,
                isSelected: _selectedCategoryId == cat.id,
                onTap: () async {
                  setState(() => _selectedCategoryId = cat.id);

                  // Persist both concessionName + categoryId
                  await GlobalConcession.set(
                    concessionName: widget.storeName,
                    categoryId: cat.id,
                  );

                  if (context.mounted) {
                    context
                        .read<ItemByCategoryBloc>()
                        .add(FetchItemsByCategory(
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

  Widget _categoryChip(
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
                    ? const LinearGradient(colors: [
                        AppColors.gradientBottom,
                        AppColors.gradientTop,
                      ])
                    : LinearGradient(colors: [
                        Colors.grey.shade400,
                        Colors.grey.shade500,
                      ]),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.gradientTop.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
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
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.bold,
                  color: isSelected
                      ? AppColors.gradientTop
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // MENU GRID — driven by ItemByCategoryBloc with search filtering
  // ─────────────────────────────────────────────────────────────────
  Widget _menuGrid(BuildContext context) {
    return BlocBuilder<ItemByCategoryBloc, ItemByCategoryState>(
      builder: (context, state) {
        // ── Loading ─────────────────────────────────────────────
        if (state is ItemByCategoryLoading ||
            state is ItemByCategoryInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        // ── Error ───────────────────────────────────────────────
        if (state is ItemByCategoryError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red[300], size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Could not load menu.\n${state.message}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.red[400], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_selectedCategoryId == -1) {
                        context
                            .read<ItemByCategoryBloc>()
                            .add(LoadAllItems(
                              concessionName: widget.storeName,
                              userId: GlobalUser.id,
                              userName: GlobalUser.name,
                              userEmail: GlobalUser.email,
                            ));
                      } else {
                        context
                            .read<ItemByCategoryBloc>()
                            .add(FetchItemsByCategory(
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

        // ── Loaded ──────────────────────────────────────────────
        if (state is ItemByCategoryLoaded) {
          // Apply search filter to items
          _filteredItems = _getFilteredItems(state.items);

          if (state.items.isEmpty) {
            return const Center(
              child: Text(
                'No items available.',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            );
          }

          // Show "no results" message if search returns nothing
          if (_filteredItems.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off,
                      color: Colors.grey.shade400, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No items found for "$_searchQuery"',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try searching with different keywords',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
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
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final sw = MediaQuery.of(context).size.width;
                    final crossAxisCount = sw > 600 ? 3 : 2;
                    final aspectRatio = sw > 600 ? 0.70 : 0.68;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredItems.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: aspectRatio,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxHeight;
        final imageHeight = cardHeight * 0.52;
        final isTablet = MediaQuery.of(context).size.width >= 600;
        final titleFont = isTablet ? 16.0 : 14.0;
        final priceFont = isTablet ? 16.0 : 14.0;
        final buttonFont = isTablet ? 15.0 : 14.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── IMAGE + LIKE ─────────────────────────────────
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
                        child: Image.asset(
                          'assets/burger.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: Icon(Icons.fastfood,
                                size: isTablet ? 60 : 48,
                                color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() =>
                            _likedItems[item.itemName] = !isLiked),
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
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: isLiked
                                ? Colors.redAccent
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── NAME + PRICE + ADD ───────────────────────────
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
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
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
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const OrderSummaryPage()),
                          ),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 11),
                            decoration: BoxDecoration(
                              color: AppColors.gradientTop,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'ADD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: buttonFont,
                                ),
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
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
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
              MaterialPageRoute(
                  builder: (_) => const MainShellPage()),
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SEARCH — NOW WITH FULL FUNCTIONALITY
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: 'Search items...',
            hintStyle:
                TextStyle(color: Colors.grey.shade600, fontSize: 15),
            prefixIcon: Icon(Icons.search,
                color: Colors.grey.shade700, size: 22),
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

// ── Small helper data class ──────────────────────────────────────────
class _CategoryMeta {
  final int id;
  final String name;
  _CategoryMeta({required this.id, required this.name});
}
import 'dart:async';
import 'package:concession_tracker_ui/core/global_item_category.dart';
import 'package:concession_tracker_ui/core/global_market.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/globalmarketdata.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionbyitem/concession_by_item_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionbyitem/concession_by_item_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionbyitem/concession_by_item_state.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_list_state.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itemcategory/item_by_category_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itemcategory/item_by_category_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itemcategory/item_by_category_state.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/hamburger_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/notifications.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/store_menu_page.dart';
import 'package:concession_tracker_ui/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

class HomePageWrapper extends StatelessWidget {
  const HomePageWrapper({super.key});
  @override
  Widget build(BuildContext context) => const HomePage();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _offerPageController;
  Timer? _autoScrollTimer;
  int _currentOfferPage = 0;
  bool _showAllStores = false;

  // -1 = "All" selected
  int _selectedCategoryId = -1;

  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _offerPageController = PageController();
    _startAutoScroll();

    _searchController = TextEditingController();
    _searchController.addListener(
      () => setState(() => _searchQuery = _searchController.text.toLowerCase()),
    );

    // ✅ Blocs will be triggered in build() via MultiBlocProvider
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_offerPageController.hasClients) {
        _currentOfferPage = (_currentOfferPage + 1) % 2;
        _offerPageController.animateToPage(
          _currentOfferPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _offerPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> _filtered(List<String> names) {
    if (_searchQuery.isEmpty) return names;
    return names.where((n) => n.toLowerCase().contains(_searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // All concessions for market — also saves marketId to GlobalMarketData
        BlocProvider(
          create: (_) => sl<ConcessionBloc>()
            ..add(FetchConcessions(GlobalMarket.marketName)),
        ),
        // Category chips
        BlocProvider(
          create: (_) => sl<ItemCategoryBloc>()
            ..add(FetchItemCategories(GlobalMarket.marketName)),
        ),
        // Concessions filtered by category (new endpoint)
        BlocProvider(
          create: (_) => sl<ConcessionByItemBloc>(),
        ),
      ],
      child: Builder(
        builder: (ctx) {
          final sw = MediaQuery.of(ctx).size.width;
          final sh = MediaQuery.of(ctx).size.height;
          return Scaffold(
            backgroundColor: Colors.grey[50],
            drawer: const HamburgerPage(),
            body: Column(
              children: [
                _header(ctx, sw),
                _search(sw),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: sw < 360 ? 80 : 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_searchQuery.isEmpty) ...[
                          _title("Today's Offer!", sw),
                          _offers(sw, sh),
                          _title("Categories", sw),
                          _categoriesSection(ctx, sw),
                        ],
                        _title(
                          _searchQuery.isEmpty
                              ? 'Restaurant Near you'
                              : 'Search Results',
                          sw,
                          showSeeAll: _searchQuery.isEmpty,
                          onSeeAllTap: () =>
                              setState(() => _showAllStores = !_showAllStores),
                        ),
                        _concessionsSection(ctx, sw, sh),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────────────────────────────
  Widget _categoriesSection(BuildContext context, double sw) {
    return BlocBuilder<ItemCategoryBloc, ItemCategoryState>(
      builder: (context, state) {
        if (state is ItemCategoryLoading || state is ItemCategoryInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04, vertical: 12),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ItemCategoryError) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
            child: Text('Could not load categories.',
                style: TextStyle(
                    color: Colors.red[400], fontSize: sw * 0.035)),
          );
        }
        if (state is ItemCategoryLoaded) {
          return SizedBox(
            height: sw * 0.30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              itemCount: state.categories.length + 1,
              itemBuilder: (context, index) {
                // ── "All" chip ──────────────────────────────────
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(right: sw * 0.04),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryId = -1);
                        context
                            .read<ConcessionBloc>()
                            .add(FetchConcessions(GlobalMarket.marketName));
                      },
                      child: _categoryCard(
                        'All',
                        sw,
                        isSelected: _selectedCategoryId == -1,
                        icon: Icons.grid_view_rounded,
                      ),
                    ),
                  );
                }

                final cat = state.categories[index - 1];
                return Padding(
                  padding: EdgeInsets.only(right: sw * 0.04),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() => _selectedCategoryId = cat.categoryId);

                      // Persist selected category
                      await GlobalItemCategory.setCategory(
                        id: cat.categoryId,
                        name: cat.categoryName,
                      );

                      if (context.mounted) {
                        // ── NEW API: pass marketId + categoryId ──
                        context.read<ConcessionByItemBloc>().add(
                          FetchConcessionsByItem(
                            marketId: GlobalMarketData.marketId,
                            categoryId: cat.categoryId,
                          ),
                        );
                      }
                    },
                    child: _categoryCard(
                      cat.categoryName,
                      sw,
                      isSelected: _selectedCategoryId == cat.categoryId,
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _categoryCard(
    String label,
    double sw, {
    bool isSelected = false,
    IconData icon = Icons.restaurant,
  }) {
    final size = sw * 0.17;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.gradientBottom, AppColors.gradientTop])
                : const LinearGradient(
                    colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)]),
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
          child: Icon(icon, color: Colors.white, size: sw * 0.08),
        ),
        SizedBox(height: sw * 0.02),
        SizedBox(
          width: size,
          child: Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.027,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.gradientTop : Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CONCESSIONS SECTION
  // ─────────────────────────────────────────────────────────────────
  Widget _concessionsSection(BuildContext context, double sw, double sh) {
    return _selectedCategoryId == -1
        ? _allConcessionsView(context, sw, sh)
        : _concessionsByItemView(context, sw, sh);
  }

  Widget _allConcessionsView(BuildContext context, double sw, double sh) {
    return BlocBuilder<ConcessionBloc, ConcessionState>(
      builder: (context, state) {
        if (state is ConcessionLoading || state is ConcessionInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ConcessionError) {
          return _errorWidget(
            sw,
            message: 'Could not load concessions.',
            onRetry: () => context
                .read<ConcessionBloc>()
                .add(FetchConcessions(GlobalMarket.marketName)),
          );
        }
        if (state is ConcessionLoaded) {
          print('[HomePage] marketId=${GlobalMarketData.marketId} '
              'concessions=${state.concessions.length}');

          if (state.concessions.isEmpty) {
            return _emptyWidget(sw, 'No concessions for this market.');
          }

          final names = _filtered(state.concessions);
          if (names.isEmpty && _searchQuery.isNotEmpty) {
            return _noResultsWidget(sw);
          }
          return _storeList(context, sw, sh, names: names);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _concessionsByItemView(BuildContext context, double sw, double sh) {
    return BlocBuilder<ConcessionByItemBloc, ConcessionByItemState>(
      builder: (context, state) {
        if (state is ConcessionByItemInitial ||
            state is ConcessionByItemLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ConcessionByItemError) {
          return _errorWidget(
            sw,
            message: 'Could not load concessions.\n${state.message}',
            onRetry: () => context.read<ConcessionByItemBloc>().add(
                  FetchConcessionsByItem(
                    marketId: GlobalMarketData.marketId,
                    categoryId: _selectedCategoryId,
                  ),
                ),
          );
        }
        if (state is ConcessionByItemLoaded) {
          if (state.concessions.isEmpty) {
            return _emptyWidget(sw, 'No concessions for this category.');
          }

          final names =
              _filtered(state.concessions.map((c) => c.concessionName).toList());

          if (names.isEmpty && _searchQuery.isNotEmpty) {
            return _noResultsWidget(sw);
          }

          return _storeList(context, sw, sh, names: names);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _storeList(BuildContext context, double sw, double sh,
      {required List<String> names}) {
    if (_showAllStores) {
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          children: names
              .map((name) => Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.04, vertical: sw * 0.02),
                    child: _storeCardVertical(context, name: name, sw: sw),
                  ))
              .toList(),
        ),
      );
    }

    final storeH = sh * 0.18;
    final storeW = sw * 0.75;
    return SizedBox(
      height: storeH,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: sw * 0.04),
        itemCount: names.length,
        itemBuilder: (context, i) => Padding(
          padding: EdgeInsets.only(right: sw * 0.04),
          child: _storeCard(context,
              name: names[i], width: storeW, height: storeH, sw: sw),
        ),
      ),
    );
  }

  Widget _errorWidget(double sw,
      {required String message, required VoidCallback onRetry}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: 16),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 36),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[400], fontSize: sw * 0.035)),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _emptyWidget(double sw, String message) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: 16),
      child: Text(message,
          style: TextStyle(color: Colors.grey[500], fontSize: sw * 0.038)),
    );
  }

  Widget _noResultsWidget(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sw * 0.1),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                color: Colors.grey.shade400, size: sw * 0.2),
            SizedBox(height: sw * 0.04),
            Text(
              'No stores found for "$_searchQuery"',
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: sw * 0.045,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sw * 0.02),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: sw * 0.035),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, double sw) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          sw * 0.04, sw * 0.12, sw * 0.04, sw * 0.05),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientTop, AppColors.gradientTop],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Icon(Icons.menu, color: Colors.white, size: sw * 0.07),
            ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GlobalUser.name.isNotEmpty ? GlobalUser.name : 'Welcome',
                  style: TextStyle(
                      color: Colors.white70, fontSize: sw * 0.032),
                ),
                SizedBox(height: sw * 0.005),
                Text(
                  GlobalMarket.marketName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: sw * 0.045,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationPage())),
            child: _headerIconButton(Icons.notifications_outlined,
                badge: '2', sw: sw),
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton(IconData icon,
      {String? badge, required double sw}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: sw * 0.055,
          backgroundColor: Colors.white,
          child: Icon(icon, color: AppColors.gradientTop, size: sw * 0.06),
        ),
        if (badge != null)
          Positioned(
            right: -4,
            top: -4,
            child: CircleAvatar(
              radius: sw * 0.022,
              backgroundColor: Colors.green,
              child: Text(badge,
                  style: TextStyle(
                      fontSize: sw * 0.022,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _search(double sw) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.04, sw * 0.04, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: TextField(
          controller: _searchController,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: 'Search restaurants...',
            hintStyle:
                TextStyle(color: Colors.grey[400], fontSize: sw * 0.04),
            prefixIcon:
                Icon(Icons.search, color: Colors.grey[600], size: sw * 0.06),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      FocusScope.of(context).unfocus();
                    },
                    child: Icon(Icons.close,
                        color: Colors.grey[600], size: sw * 0.05),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(vertical: sw * 0.04),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // TITLE
  // ─────────────────────────────────────────────────────────────────
  Widget _title(String text, double sw,
      {bool showSeeAll = false, VoidCallback? onSeeAllTap}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          sw * 0.04, sw * 0.06, sw * 0.04, sw * 0.03),
      child: Row(
        children: [
          Text(text,
              style: TextStyle(
                  fontSize: sw * 0.05, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (showSeeAll && onSeeAllTap != null)
            GestureDetector(
              onTap: onSeeAllTap,
              child: Text(
                _showAllStores ? 'Show less' : 'See all',
                style: TextStyle(
                    color: Colors.grey[600], fontSize: sw * 0.035),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // OFFERS
  // ─────────────────────────────────────────────────────────────────
  Widget _offers(double sw, double sh) {
    final oh = sh * 0.25;
    final ow = sw * 0.9;
    return SizedBox(
      height: oh,
      child: PageView(
        controller: _offerPageController,
        onPageChanged: (i) => setState(() => _currentOfferPage = i),
        children: [
          Padding(
              padding: EdgeInsets.only(left: sw * 0.04),
              child: _offerCard('30% OFF', 'assets/burger.png', ow, oh, sw)),
          Padding(
              padding: EdgeInsets.only(left: sw * 0.04),
              child: _offerCard('25% OFF', 'assets/pizza.png', ow, oh, sw)),
        ],
      ),
    );
  }

  Widget _offerCard(
      String discount, String image, double w, double h, double sw) {
    return Container(
      width: w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [AppColors.gradientTop, AppColors.gradientBottom]),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(sw * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(discount,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: sw * 0.08,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: sw * 0.02),
                Text(
                  'Discover discounts in your\nfavorite local restaurants',
                  style:
                      TextStyle(color: Colors.white, fontSize: sw * 0.035),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.06, vertical: sw * 0.025),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25)),
                  child: Text('Order Now',
                      style: TextStyle(
                          color: AppColors.gradientTop,
                          fontWeight: FontWeight.bold,
                          fontSize: sw * 0.0233)),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(image,
                width: w * 0.4, height: h * 0.7, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // STORE CARD — HORIZONTAL
  // ─────────────────────────────────────────────────────────────────
  Widget _storeCard(BuildContext context,
      {required String name,
      required double width,
      required double height,
      required double sw}) {
    final cp = sw * 0.03;
    final nf = (sw * 0.04).clamp(12.0, 18.0);
    final bf = (sw * 0.03).clamp(11.0, 15.0);
    final bp = (sw * 0.02).clamp(6.0, 12.0);

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => StoreMenuPage(
                  storeName: name, storeImage: 'assets/restaurant.svg'))),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
                child: SvgPicture.asset('assets/restaurant.svg',
                    fit: BoxFit.cover, height: double.infinity),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(cp),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.gradientTop, AppColors.gradientBottom]),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(name,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: nf,
                              height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: bp),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: Text('View Menu',
                          style: TextStyle(
                              color: AppColors.gradientTop,
                              fontWeight: FontWeight.bold,
                              fontSize: bf)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // STORE CARD — VERTICAL (See All mode)
  // ─────────────────────────────────────────────────────────────────
  Widget _storeCardVertical(BuildContext context,
      {required String name, required double sw}) {
    final cp = sw * 0.035;
    final nf = (sw * 0.045).clamp(14.0, 20.0);
    final bf = (sw * 0.032).clamp(12.0, 16.0);
    final bp = (sw * 0.025).clamp(8.0, 14.0);

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => StoreMenuPage(
                  storeName: name, storeImage: 'assets/restaurant.svg'))),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20)),
              child: SvgPicture.asset('assets/restaurant.svg',
                  width: sw * 0.35, height: sw * 0.35, fit: BoxFit.cover),
            ),
            Expanded(
              child: Container(
                height: sw * 0.35,
                padding: EdgeInsets.all(cp),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.gradientTop, AppColors.gradientBottom]),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(name,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: nf,
                              height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: bp),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: Text('View Menu',
                          style: TextStyle(
                              color: AppColors.gradientTop,
                              fontWeight: FontWeight.bold,
                              fontSize: bf)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
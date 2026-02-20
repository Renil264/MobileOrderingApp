import 'dart:async';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/user_storage.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_list_state.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/hamburger_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/mainpage2.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/notifications.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/store_menu_page.dart';
import 'package:concession_tracker_ui/injection_container.dart';
import 'package:concession_tracker_ui/core/global_market.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';

/// HomePageWrapper is kept for backward compatibility but now simply
/// delegates to HomePage, which is self-providing its own BlocProvider.
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

  @override
  void initState() {
    super.initState();
    _offerPageController = PageController();
    _startAutoScroll();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BlocProvider is created here so HomePage is fully self-contained,
    // regardless of how it is navigated to. The builder gives us a fresh
    // BuildContext that is a descendant of the BlocProvider, which is what
    // BlocBuilder requires.
    return BlocProvider(
      create: (_) => sl<ConcessionBloc>()
        ..add(FetchConcessions(GlobalMarket.marketName)),
      child: Builder(
        builder: (innerContext) {
          final screenWidth = MediaQuery.of(innerContext).size.width;
          final screenHeight = MediaQuery.of(innerContext).size.height;

          return Scaffold(
            backgroundColor: Colors.grey[50],
            drawer: const HamburgerPage(),
            body: Column(
              children: [
                _header(innerContext, screenWidth),
                _search(screenWidth),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.only(bottom: screenWidth < 360 ? 80 : 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title("Today's Offer!", screenWidth),
                        _offers(screenWidth, screenHeight),
                        _title("Categories", screenWidth),
                        _categories(screenWidth),
                        _title(
                          "Restaurant Near you",
                          screenWidth,
                          showSeeAll: true,
                          onSeeAllTap: () =>
                              setState(() => _showAllStores = !_showAllStores),
                        ),
                        // API-driven concession list using same store card UI
                        _concessionStores(innerContext, screenWidth, screenHeight),
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
  // CONCESSION STORES - BLoC powered, same store card UI
  // ─────────────────────────────────────────────────────────────────
  Widget _concessionStores(
      BuildContext context, double screenWidth, double screenHeight) {
    return BlocBuilder<ConcessionBloc, ConcessionState>(
      builder: (context, state) {
        if (state is ConcessionLoading || state is ConcessionInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ConcessionError) {
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, vertical: 16),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[300], size: 36),
                const SizedBox(height: 8),
                Text(
                  'Could not load concessions.\nPlease check your connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.red[400], fontSize: screenWidth * 0.035),
                ),
                TextButton.icon(
                  onPressed: () => context
                      .read<ConcessionBloc>()
                      .add(FetchConcessions(GlobalMarket.marketName)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ConcessionLoaded) {
          if (state.concessions.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, vertical: 16),
              child: Text(
                'No concessions available for this market.',
                style: TextStyle(
                    color: Colors.grey[500], fontSize: screenWidth * 0.038),
              ),
            );
          }

          if (_showAllStores) {
            // Vertical list
            return AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                children: state.concessions.map((c) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.02,
                    ),
                    child: _storeCardVertical(context,
                        name: c.name, screenWidth: screenWidth),
                  );
                }).toList(),
              ),
            );
          } else {
            // Horizontal scroll
            final storeHeight = screenHeight * 0.18;
            final storeWidth = screenWidth * 0.75;
            return SizedBox(
              height: storeHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: screenWidth * 0.04),
                itemCount: state.concessions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.04),
                    child: _storeCard(
                      context,
                      name: state.concessions[index].name,
                      width: storeWidth,
                      height: storeHeight,
                      screenWidth: screenWidth,
                    ),
                  );
                },
              ),
            );
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────
  Widget _header(BuildContext context, double screenWidth) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.04,
        screenWidth * 0.12,
        screenWidth * 0.04,
        screenWidth * 0.05,
      ),
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
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Icon(Icons.menu,
                  color: Colors.white, size: screenWidth * 0.07),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(GlobalUser.name,
                  style: TextStyle(
                      color: Colors.white70, fontSize: screenWidth * 0.032)),
              SizedBox(height: screenWidth * 0.005),
              Text(GlobalMarket.marketName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          const Spacer(),
          SizedBox(width: screenWidth * 0.03),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationPage())),
            child: _headerIconButton(Icons.notifications_outlined,
                badge: '2', screenWidth: screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton(IconData icon,
      {String? badge, required double screenWidth}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: screenWidth * 0.055,
          backgroundColor: Colors.white,
          child: Icon(icon,
              color: AppColors.gradientTop, size: screenWidth * 0.06),
        ),
        if (badge != null)
          Positioned(
            right: -4,
            top: -4,
            child: CircleAvatar(
              radius: screenWidth * 0.022,
              backgroundColor: Colors.green,
              child: Text(badge,
                  style: TextStyle(
                    fontSize: screenWidth * 0.022,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────────────────────────
  Widget _search(double screenWidth) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04, 0),
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
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(
                color: Colors.grey[400], fontSize: screenWidth * 0.04),
            prefixIcon: Icon(Icons.search,
                color: Colors.grey[600], size: screenWidth * 0.06),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                EdgeInsets.symmetric(vertical: screenWidth * 0.04),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // TITLE
  // ─────────────────────────────────────────────────────────────────
  Widget _title(String text, double screenWidth,
      {bool showSeeAll = false, VoidCallback? onSeeAllTap}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.04,
        screenWidth * 0.06,
        screenWidth * 0.04,
        screenWidth * 0.03,
      ),
      child: Row(
        children: [
          Text(text,
              style: TextStyle(
                  fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (showSeeAll)
            GestureDetector(
              onTap: onSeeAllTap,
              child: Text(_showAllStores ? 'Show less' : 'See all',
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: screenWidth * 0.035)),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // OFFERS
  // ─────────────────────────────────────────────────────────────────
  Widget _offers(double screenWidth, double screenHeight) {
    final offerHeight = screenHeight * 0.25;
    final offerWidth = screenWidth * 0.9;
    return SizedBox(
      height: offerHeight,
      child: PageView(
        controller: _offerPageController,
        onPageChanged: (index) => setState(() => _currentOfferPage = index),
        children: [
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.04),
            child: _offerCard(
                '30% OFF', 'assets/burger.png', offerWidth, offerHeight, screenWidth),
          ),
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.04),
            child: _offerCard(
                '25% OFF', 'assets/pizza.png', offerWidth, offerHeight, screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _offerCard(String discount, String image, double width, double height,
      double screenWidth) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [AppColors.gradientTop, AppColors.gradientBottom]),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(discount,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: screenWidth * 0.02),
                Text('Discover discounts in your\nfavorite local restaurants',
                    style: TextStyle(
                        color: Colors.white, fontSize: screenWidth * 0.035)),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenWidth * 0.025),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25)),
                  child: Text('Order Now',
                      style: TextStyle(
                          color: AppColors.gradientTop,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.0233)),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(image,
                width: width * 0.4, height: height * 0.7, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────────────────────────────
  Widget _categories(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Category('Breakfast', screenWidth),
          _Category('Beverages', screenWidth),
          _Category('Lunch', screenWidth),
          _Category('Desserts', screenWidth),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // STORE CARD HORIZONTAL
  // ─────────────────────────────────────────────────────────────────
  Widget _storeCard(
    BuildContext context, {
    required String name,
    required double width,
    required double height,
    required double screenWidth,
  }) {
    final cardPadding = screenWidth * 0.03;
    final nameFontSize = (screenWidth * 0.04).clamp(12.0, 18.0);
    final ratingFontSize = (screenWidth * 0.028).clamp(10.0, 14.0);
    final buttonFontSize = (screenWidth * 0.03).clamp(11.0, 15.0);
    final iconSize = (screenWidth * 0.035).clamp(14.0, 18.0);
    final buttonVerticalPadding = (screenWidth * 0.02).clamp(6.0, 12.0);

    return GestureDetector(
      onTap: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) =>
                StoreMenuPage(storeName: name, storeImage: 'assets/store_1.png')),
        (route) => false,
      ),
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
                child: Image.asset('assets/store_1.png',
                    fit: BoxFit.cover, height: double.infinity),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(cardPadding),
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
                              fontSize: nameFontSize,
                              height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),

                    Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: Text('View Menu',
                          style: TextStyle(
                              color: AppColors.gradientTop,
                              fontWeight: FontWeight.bold,
                              fontSize: buttonFontSize)),
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
  // STORE CARD VERTICAL
  // ─────────────────────────────────────────────────────────────────
  Widget _storeCardVertical(
    BuildContext context, {
    required String name,
    required double screenWidth,
  }) {
    final cardPadding = screenWidth * 0.035;
    final nameFontSize = (screenWidth * 0.045).clamp(14.0, 20.0);
    final ratingFontSize = (screenWidth * 0.03).clamp(11.0, 15.0);
    final buttonFontSize = (screenWidth * 0.032).clamp(12.0, 16.0);
    final iconSize = (screenWidth * 0.04).clamp(16.0, 20.0);
    final buttonVerticalPadding = (screenWidth * 0.025).clamp(8.0, 14.0);

    return GestureDetector(
      onTap: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShellPage1()),
        (route) => false,
      ),
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
              child: Image.asset('assets/store_1.png',
                  width: screenWidth * 0.35,
                  height: screenWidth * 0.35,
                  fit: BoxFit.cover),
            ),
            Expanded(
              child: Container(
                height: screenWidth * 0.35,
                padding: EdgeInsets.all(cardPadding),
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
                              fontSize: nameFontSize,
                              height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),

                    Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: Text('View Menu',
                          style: TextStyle(
                              color: AppColors.gradientTop,
                              fontWeight: FontWeight.bold,
                              fontSize: buttonFontSize)),
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

// ─────────────────────────────────────────────────────────────────
// CATEGORY WIDGET
// ─────────────────────────────────────────────────────────────────
class _Category extends StatelessWidget {
  final String label;
  final double screenWidth;
  const _Category(this.label, this.screenWidth);

  @override
  Widget build(BuildContext context) {
    final categorySize = screenWidth * 0.17;
    return Column(
      children: [
        Container(
          width: categorySize,
          height: categorySize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
                colors: [AppColors.gradientTop, AppColors.gradientTop]),
          ),
          child: Icon(Icons.restaurant,
              color: Colors.white, size: screenWidth * 0.08),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(label, style: TextStyle(fontSize: screenWidth * 0.03)),
      ],
    );
  }
}
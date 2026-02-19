import 'dart:async';
import 'package:concession_tracker_ui/features/auth/presentation/pages/hamburger_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/main_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/mainpage2.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/notifications.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/store_menu_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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

  // List of stores data
  final List<Map<String, String>> _storesData = [
    {
      'image': 'assets/store_1.png',
      'name': 'Corner Street',
      'rating': '(4.5)',
    },
    {
      'image': 'assets/freddys.png',
      'name': 'Freddys Pizza',
      'rating': '(4.8)',
    },
  ];

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const HamburgerPage(),
      body: Column(
        children: [
          _header(context, screenWidth),
          _search(screenWidth),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: screenWidth < 360 ? 80 : 100,
              ),
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
                    onSeeAllTap: () {
                      setState(() {
                        _showAllStores = !_showAllStores;
                      });
                    },
                  ),
                  if (_showAllStores)
                    _storesVerticalList(context, screenWidth)
                  else
                    _stores(context, screenWidth, screenHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HEADER
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
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Icon(
                Icons.menu,
                color: Colors.white,
                size: screenWidth * 0.07,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'John Doe',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.032,
                ),
              ),
              SizedBox(height: screenWidth * 0.005),
              Text(
                'Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(width: screenWidth * 0.03),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
            child: _headerIconButton(
              Icons.notifications_outlined,
              badge: '2',
              screenWidth: screenWidth,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton(
    IconData icon, {
    String? badge,
    required double screenWidth,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: screenWidth * 0.055,
          backgroundColor: Colors.white,
          child: Icon(
            icon,
            color: AppColors.gradientTop,
            size: screenWidth * 0.06,
          ),
        ),
        if (badge != null)
          Positioned(
            right: -4,
            top: -4,
            child: CircleAvatar(
              radius: screenWidth * 0.022,
              backgroundColor: Colors.green,
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: screenWidth * 0.022,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // SEARCH
  Widget _search(double screenWidth) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.04,
        screenWidth * 0.04,
        screenWidth * 0.04,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: screenWidth * 0.04,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[600],
              size: screenWidth * 0.06,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: screenWidth * 0.04,
            ),
          ),
        ),
      ),
    );
  }

  // TITLE
  Widget _title(
    String text,
    double screenWidth, {
    bool showSeeAll = false,
    VoidCallback? onSeeAllTap,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.04,
        screenWidth * 0.06,
        screenWidth * 0.04,
        screenWidth * 0.03,
      ),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (showSeeAll)
            GestureDetector(
              onTap: onSeeAllTap,
              child: Text(
                _showAllStores ? 'Show less' : 'See all',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // OFFERS WITH AUTO SCROLL
  Widget _offers(double screenWidth, double screenHeight) {
    final offerHeight = screenHeight * 0.25;
    final offerWidth = screenWidth * 0.9;

    return SizedBox(
      height: offerHeight,
      child: PageView(
        controller: _offerPageController,
        onPageChanged: (index) {
          setState(() {
            _currentOfferPage = index;
          });
        },
        children: [
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.04),
            child: _offerCard('30% OFF', 'assets/burger.png', offerWidth, offerHeight, screenWidth),
          ),
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.04),
            child: _offerCard('25% OFF', 'assets/pizza.png', offerWidth, offerHeight, screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _offerCard(
    String discount,
    String image,
    double width,
    double height,
    double screenWidth,
  ) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.gradientTop, AppColors.gradientBottom],
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discount,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  'Discover discounts in your\nfavorite local restaurants',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenWidth * 0.025,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    'Order Now',
                    style: TextStyle(
                      color: AppColors.gradientTop,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.0233,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              image,
              width: width * 0.4,
              height: height * 0.7,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // CATEGORIES
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

  // STORES HORIZONTAL SCROLL - FIXED VERSION
  Widget _stores(BuildContext context, double screenWidth, double screenHeight) {
    // Responsive store card dimensions
    final storeHeight = screenHeight * 0.18;
    final storeWidth = screenWidth * 0.75;

    return SizedBox(
      height: storeHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: screenWidth * 0.04),
        itemCount: _storesData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.04),
            child: _storeCard(
              context,
              image: _storesData[index]['image']!,
              name: _storesData[index]['name']!,
              rating: _storesData[index]['rating']!,
              width: storeWidth,
              height: storeHeight,
              screenWidth: screenWidth,
            ),
          );
        },
      ),
    );
  }

  // STORES VERTICAL LIST
  Widget _storesVerticalList(BuildContext context, double screenWidth) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: _storesData.map((store) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            child: _storeCardVertical(
              context,
              image: store['image']!,
              name: store['name']!,
              rating: store['rating']!,
              screenWidth: screenWidth,
            ),
          );
        }).toList(),
      ),
    );
  }

  // STORE CARD HORIZONTAL - FIXED WITH RESPONSIVE SPACING
  Widget _storeCard(
    BuildContext context, {
    required String image,
    required String name,
    required String rating,
    required double width,
    required double height,
    required double screenWidth,
  }) {
    // Calculate responsive padding based on screen width
    final cardPadding = screenWidth * 0.03;
    
    // Calculate font sizes that scale properly
    final nameFontSize = (screenWidth * 0.04).clamp(12.0, 18.0);
    final ratingFontSize = (screenWidth * 0.028).clamp(10.0, 14.0);
    final buttonFontSize = (screenWidth * 0.03).clamp(11.0, 15.0);
    final iconSize = (screenWidth * 0.035).clamp(14.0, 18.0);
    
    // Calculate button padding
    final buttonVerticalPadding = (screenWidth * 0.02).clamp(6.0, 12.0);

    return GestureDetector(
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const StoreMenuPage(storeName: 'RestuarantName', storeImage: 'StoreImage'),
          ),
          (route) => false,
        );

      },
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
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // LEFT - Store Image
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
            ),
            // RIGHT - Gradient Info Section
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(cardPadding),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientTop,
                      AppColors.gradientBottom
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Store Name - Flexible to prevent overflow
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: nameFontSize,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Star Rating - Compact spacing
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.green, size: iconSize),
                            Icon(Icons.star, color: Colors.green, size: iconSize),
                            Icon(Icons.star, color: Colors.green, size: iconSize),
                            Icon(Icons.star, color: Colors.green, size: iconSize),
                            Icon(Icons.star_half, color: Colors.green, size: iconSize),
                          ],
                        ),
                        SizedBox(height: cardPadding * 0.3),
                        Text(
                          rating,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: ratingFontSize,
                          ),
                        ),
                      ],
                    ),
                    // View Menu Button - Responsive padding
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        vertical: buttonVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'View Menu',
                        style: TextStyle(
                          color: AppColors.gradientTop,
                          fontWeight: FontWeight.bold,
                          fontSize: buttonFontSize,
                        ),
                      ),
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

  // STORE CARD VERTICAL - ALSO FIXED FOR CONSISTENCY
  Widget _storeCardVertical(
    BuildContext context, {
    required String image,
    required String name,
    required String rating,
    required double screenWidth,
  }) {
    final cardPadding = screenWidth * 0.035;
    final nameFontSize = (screenWidth * 0.045).clamp(14.0, 20.0);
    final ratingFontSize = (screenWidth * 0.03).clamp(11.0, 15.0);
    final buttonFontSize = (screenWidth * 0.032).clamp(12.0, 16.0);
    final iconSize = (screenWidth * 0.04).clamp(16.0, 20.0);
    final buttonVerticalPadding = (screenWidth * 0.025).clamp(8.0, 14.0);

    return GestureDetector(
      onTap: () {
       Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainShellPage1(),
        ),
        (route) => false,
      );

      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // LEFT - Store Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Image.asset(
                image,
                width: screenWidth * 0.35,
                height: screenWidth * 0.35,
                fit: BoxFit.cover,
              ),
            ),
            // RIGHT - Gradient Info Section
            Expanded(
              child: Container(
                height: screenWidth * 0.35,
                padding: EdgeInsets.all(cardPadding),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientTop,
                      AppColors.gradientBottom
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Store Name
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: nameFontSize,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Star Rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.green, size: iconSize),
                            Icon(Icons.star, color: Colors.green, size: iconSize),
                            Icon(Icons.star, color: Colors.green, size: iconSize),
                            Icon(Icons.star, color: Colors.green, size: iconSize),
                            Icon(Icons.star_half, color: Colors.green, size: iconSize),
                          ],
                        ),
                        SizedBox(height: cardPadding * 0.3),
                        Text(
                          rating,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: ratingFontSize,
                          ),
                        ),
                      ],
                    ),
                    // View Menu Button
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        vertical: buttonVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'View Menu',
                        style: TextStyle(
                          color: AppColors.gradientTop,
                          fontWeight: FontWeight.bold,
                          fontSize: buttonFontSize,
                        ),
                      ),
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

// CATEGORY
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
              colors: [AppColors.gradientTop, AppColors.gradientTop],
            ),
          ),
          child: Icon(
            Icons.restaurant,
            color: Colors.white,
            size: screenWidth * 0.08,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          label,
          style: TextStyle(fontSize: screenWidth * 0.03),
        ),
      ],
    );
  }
}
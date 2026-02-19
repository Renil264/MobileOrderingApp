import 'package:concession_tracker_ui/features/auth/presentation/pages/home_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/main_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/order_summary_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/widgets/main_bottom_nav.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MenuItem {
  final String name;
  final String image;
  final double price;

  MenuItem({
    required this.name,
    required this.image,
    required this.price,
  });
}

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
  int currentIndex = 0;
  int selectedCategory = 0;

  final List<String> categories = [
    'Breakfast',
    'Beverages',
    'Lunch',
    'Desserts',
  ];

  final Map<String, bool> _likedItems = {};

  final List<MenuItem> menuItems = [
    MenuItem(
      name: 'Choclate Muffins',
      image: 'assets/muffins.png',
      price: 20.0,
    ),
    MenuItem(
      name: 'Choclate Cake',
      image: 'assets/choclate_cake.png',
      price: 20.0,
    ),
    MenuItem(
      name: 'Breakfast Sandwich',
      image: 'assets/sandwich.png',
      price: 20.0,
    ),
    MenuItem(
      name: 'Coffee Latte',
      image: 'assets/coffee.png',
      price: 20.0,
    ),
    MenuItem(
      name: 'Waffle',
      image: 'assets/waffle.png',
      price: 20.0,
    ),
    MenuItem(
      name: 'Donut',
      image: 'assets/donut.png',
      price: 20.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          _search(),
          _categorySection(),

          // ── All grid cards wrapped in one rounded container ──
          Expanded(
            child: Padding(
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
                      final screenWidth = MediaQuery.of(context).size.width;
                      final crossAxisCount = screenWidth > 600 ? 3 : 2;
                      final aspectRatio = screenWidth > 600 ? 0.70 : 0.68;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: menuItems.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: aspectRatio,
                        ),
                        itemBuilder: (context, index) =>
                            _menuItemCard(menuItems[index]),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      

      /// 🔥 ATTACHED BOTTOM NAV HERE
    );
  }

Widget _header(BuildContext context) {
  return Container(
    padding: EdgeInsets.fromLTRB(
      20,
      MediaQuery.of(context).padding.top + 16, // ✅ Safe area top spacing
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
        colors: [
          AppColors.gradientTop,
          AppColors.gradientTop,
        ],
      ),
    ),
    child: Row(
      children: [
        // 🔙 Back Button
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainShellPage(),
              ),
              (route) => false,
            );
          },
        ),

        const SizedBox(width: 8),

        // Store Name
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


  // 🔍 SEARCH
  Widget _search() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            prefixIcon:
                Icon(Icons.search, color: Colors.grey.shade700, size: 22),
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

  Widget _categorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) => _categoryItem(index),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _categoryItem(int index) {
    final isSelected = selectedCategory == index;
    return GestureDetector(
      onTap: () {
        setState(() => selectedCategory = index);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gradientTop,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.white,
                          blurRadius: 0,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              categories[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItemCard(MenuItem item) {
    final isLiked = _likedItems[item.name] ?? false;

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
              // ── IMAGE + LIKE OVERLAY ──
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Food image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.asset(
                          item.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.fastfood,
                                size: isTablet ? 60 : 48,
                                color: Colors.grey.shade500,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Like button — top right circular badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _likedItems[item.name] = !isLiked;
                          });
                        },
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
                            color: isLiked ? Colors.redAccent : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── CONTENT: name, price, add button ──
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 14 : 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // NAME + PRICE row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: titleFont,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${item.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: priceFont,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // ADD BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrderSummaryPage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 11 : 11,
                            ),
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
}
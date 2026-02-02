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

  // 🍔 Sample menu items
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
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid configuration
                final screenWidth = MediaQuery.of(context).size.width;
                final crossAxisCount = screenWidth > 600 ? 3 : 2;
                
                // Dynamic aspect ratio calculation for consistent card appearance
                final aspectRatio = screenWidth > 600 ? 0.70 : 0.68;
                
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  itemCount: menuItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: aspectRatio,
                  ),
                  itemBuilder: (context, index) => _menuItemCard(menuItems[index]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }

  // 🟧 HEADER
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
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
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, 
              color: Colors.white, 
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          
          // Store Icon
          
          const SizedBox(width: 12),
          
          // Store Name and Address
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.storeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade700, size: 22),
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

  // 🎯 CATEGORIES SECTION
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

  // 🍽️ CATEGORY ITEM
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
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🍔 MENU ITEM CARD - FULLY RESPONSIVE
  Widget _menuItemCard(MenuItem item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions based on card width
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        
        // Image should take approximately 55% of card height
        final imageHeight = cardHeight * 0.55;
        
        // Content section takes the remaining 45%
        final contentHeight = cardHeight * 0.45;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with Favorite Icon
              SizedBox(
                height: imageHeight,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.asset(
                        item.image,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: imageHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Icon(
                              Icons.fastfood,
                              size: 50,
                              color: Colors.grey.shade500,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.gradientTop,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Product Details - Fixed height for consistent alignment
              SizedBox(
                height: contentHeight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Product Name and Price Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                height: 1.2,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            
                            // Price
                            Text(
                              '\$${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Buttons Row - Always at bottom with consistent spacing
                      Row(
                        children: [
                          // Shopping Bag Button
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C1D95),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          
                          // ADD Button
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OrderSummaryPage(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.gradientTop,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'ADD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
import 'package:concession_tracker_ui/features/auth/presentation/pages/order_summary_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SavedFoodItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;

  const SavedFoodItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });
}

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  // TODO: Replace with your real data source / state management
  final List<SavedFoodItem> _savedItems = const [
    SavedFoodItem(
      id: '1',
      name: 'Margherita Pizza',
      imageUrl:
          'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=400',
      price: 12.99,
    ),
    SavedFoodItem(
      id: '2',
      name: 'Classic Burger',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      price: 9.49,
    ),
    SavedFoodItem(
      id: '3',
      name: 'Chicken Tacos',
      imageUrl:
          'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400',
      price: 8.99,
    ),
    SavedFoodItem(
      id: '4',
      name: 'Sushi Platter',
      imageUrl:
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
      price: 22.50,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Saved',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.appleBlack,
          ),
        ),
      ),
      body: SafeArea(
        child: _savedItems.isEmpty
            ? const _EmptyState()
            : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _savedItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        return _SavedFoodCard(item: _savedItems[index]);
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SavedFoodCard extends StatelessWidget {
  final SavedFoodItem item;

  const _SavedFoodCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: const Color(0xFFEEEEEE),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFEEEEEE),
                    child: const Icon(Icons.fastfood,
                        size: 36, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

          // Name + price row
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.appleBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.appleBlack,
                  ),
                ),
              ],
            ),
          ),

          // ADD button
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderSummaryPage(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.gradientTop,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradientTop.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'ADD',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/book_icon.png',
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            const Text(
              'Nothing saved just yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.appleBlack,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Save your favorite items to see them here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
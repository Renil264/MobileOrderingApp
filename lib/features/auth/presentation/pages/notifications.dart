import 'package:concession_tracker_ui/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [
    {
      'orderId': '#12345',
      'message': 'Thank you for your order',
      'status': 'Preparing',
      'statusColor': const Color(0xFFFDFFC4),
      'textColor': const Color(0xFFF98601),
      'icon': Icons.restaurant_menu,
      'iconBg': const Color(0xFFFFF8E1),
      'time': '12:42 PM',
      'date': '2025-11-10', // Today
    },
    {
      'orderId': '#71345',
      'message': 'Thank you for your order',
      'status': 'Payment Failed',
      'statusColor': const Color.fromARGB(255, 255, 200, 196),
      'textColor': const Color.fromARGB(255, 249, 9, 1),
      'icon': Icons.error_outline,
      'iconBg': const Color(0xFFFFEBEE),
      'time': '10:13 AM',
      'date': '2025-11-06', // Yesterday
    },
    {
      'orderId': '#77345',
      'message': 'Thank you for your order',
      'status': 'Ready to Pick',
      'statusColor': const Color.fromARGB(255, 196, 227, 255),
      'textColor': const Color.fromARGB(255, 0, 44, 127),
      'icon': Icons.check_circle_outline,
      'iconBg': const Color(0xFFE3F2FD),
      'time': '11:22 AM',
      'date': '2025-11-05', // Older
    },
    {
      'orderId': '#87345',
      'message': 'Thank you for your order',
      'status': 'Completed',
      'statusColor': const Color(0xFFC4FFE1),
      'textColor': const Color(0xFF007F5F),
      'icon': Icons.done_all,
      'iconBg': const Color(0xFFE8F5E9),
      'time': '01:02 PM',
      'date': '2025-11-01', // Older
    },
  ];

  List<Map<String, dynamic>> filterByDate(DateTime date) {
    return notifications.where((n) {
      final notifDate = DateTime.parse(n['date']);
      return notifDate.year == date.year &&
          notifDate.month == date.month &&
          notifDate.day == date.day;
    }).toList();
  }

  void _removeNotification(Map<String, dynamic> notification) {
    setState(() {
      notifications.remove(notification);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification for order ${notification['orderId']} dismissed'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              notifications.add(notification);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todayNotifications = filterByDate(today);
    final yesterdayNotifications = filterByDate(yesterday);

    final olderNotifications = notifications.where((n) {
      final notifDate = DateTime.parse(n['date']);
      return !(notifDate.year == today.year &&
              notifDate.month == today.month &&
              notifDate.day == today.day) &&
          !(notifDate.year == yesterday.year &&
              notifDate.month == yesterday.month &&
              notifDate.day == yesterday.day);
    }).toList();

    // Sort older notifications by date descending
    olderNotifications.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gradientTop.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.gradientTop, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text('Clear All'),
                    content:
                        const Text('Are you sure you want to clear all notifications?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            notifications.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Clear',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                if (todayNotifications.isNotEmpty) ...[
                  _buildHeader("Today", todayNotifications.length),
                  ...todayNotifications.map((item) =>
                      _buildNotificationCard(item, isToday: true)),
                  const SizedBox(height: 12),
                ],
                if (yesterdayNotifications.isNotEmpty) ...[
                  _buildHeader("Yesterday", yesterdayNotifications.length),
                  ...yesterdayNotifications.map((item) =>
                      _buildNotificationCard(item)),
                  const SizedBox(height: 12),
                ],
                if (olderNotifications.isNotEmpty) ...[
                  _buildHeader("Earlier", olderNotifications.length),
                  ...olderNotifications.map((item) {
                    final formattedDate = DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(item['date']));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        _buildNotificationCard(item),
                      ],
                    );
                  }),
                ],
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.gradientTop.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.gradientTop.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String text, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.gradientTop.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.gradientTop,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item,
      {bool isToday = false}) {
    return Dismissible(
      key: Key(item['orderId']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        _removeNotification(item);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Handle notification tap
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening order ${item['orderId']}'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item['iconBg'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'],
                      color: item['textColor'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Order ${item['orderId']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gradientTop.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['time'],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gradientTop,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['message'],
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: item['statusColor'],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: item['textColor'].withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: item['textColor'],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['status'],
                                style: TextStyle(
                                  color: item['textColor'],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
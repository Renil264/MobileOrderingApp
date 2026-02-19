import 'package:concession_tracker_ui/features/auth/presentation/pages/changepassword.dart';
import 'package:concession_tracker_ui/features/auth/presentation/widgets/login_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/myorders.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/personaldetails.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/switch_market_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/termsandconditions.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HamburgerPage extends StatelessWidget {
  const HamburgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      width: screenWidth * 0.7,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.gradientTop, AppColors.gradientBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.06),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.07,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: screenWidth * 0.08,
                        color: AppColors.gradientTop,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'John Doe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          Text(
                            'johndoe@gmail.com',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: screenWidth * 0.032,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: screenWidth * 0.05),
                    child: Column(
                      children: [
                        SizedBox(height: screenWidth * 0.06),

                        _drawerMenuItem(
                          context,
                          icon: Icons.store,
                          title: 'Switch Market',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SwitchMarketPage(),
                              ),
                            );
                          },
                        ),

                        _drawerMenuItem(
                          context,
                          icon: Icons.person_outline,
                          title: 'Personal Details',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PersonalDetailsScreen(),
                              ),
                            );
                          },
                        ),

                        _drawerMenuItem(
                          context,
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),

                        _drawerMenuItem(
                          context,
                          icon: Icons.credit_card,
                          title: 'Credits',
                          onTap: () {
                          
                          },
                        ),

                        _drawerMenuItem(
                          context,
                          icon: Icons.description_outlined,
                          title: 'Terms and Conditions',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PrivacyPolicyPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.06),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final rootContext = Navigator.of(context).context;

                                Navigator.of(context).pop(); // close drawer

                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _showLogoutDialog(rootContext);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.04,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout,
                                    size: screenWidth * 0.05,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenWidth * 0.015,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.035,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.gradientTop,
                  size: screenWidth * 0.055,
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.037,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: screenWidth * 0.055,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= LOGOUT DIALOG =================
  void _showLogoutDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: screenWidth * 0.04),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

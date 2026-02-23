import 'package:concession_tracker_ui/core/global_fcm.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/changepassword.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/login_form.dart';
import 'package:concession_tracker_ui/features/auth/presentation/widgets/login_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/personaldetails.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/switch_market_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/termsandconditions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
                                Navigator.of(context).pop(); // close drawer

                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _showLogoutDialog(context);
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

  // ================= AWESOME LOGOUT DIALOG =================
  void _showLogoutDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 12,
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: screenWidth * 0.08,
                      bottom: screenWidth * 0.06,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red.shade600,
                          Colors.red.shade400,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: screenWidth * 0.12,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.06),
                    child: Column(
                      children: [
                        Text(
                          'Are you sure?',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        Text(
                          'You will be logged out of your account. You can log back in anytime.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.06),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.04,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: _LogoutButton(
                                screenWidth: screenWidth,
                                dialogContext: dialogContext,
                              ),
                            ),
                          ],
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

// ================= LOGOUT BUTTON WITH API INTEGRATION =================
class _LogoutButton extends StatefulWidget {
  final double screenWidth;
  final BuildContext dialogContext;

  const _LogoutButton({
    required this.screenWidth,
    required this.dialogContext,
  });

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isLoading = false;

  Future<void> _performLogout() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      const String apiUrl = 'http://192.168.10.144/ConcessionTracker/api/Users/logout';
      
      // Get email and FCM token from global variables
      String userEmail = GlobalUser.email;
      String fcmToken = GlobalFCM.token;
      
      print('📤 Logging out user: $userEmail');
      print('🔑 FCM Token: $fcmToken');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': userEmail,
          'fcmToken': fcmToken,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Server did not respond');
        },
      );

      if (!mounted) return;

      print('📡 API Response Status: ${response.statusCode}');
      print('📋 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        print('✅ Logout API successful!');
        print('✅ Response: ${responseData['message']}');
        
        // Step 1: Close the dialog
        if (mounted && Navigator.canPop(widget.dialogContext)) {
          Navigator.pop(widget.dialogContext);
          print('📍 Step 1: Dialog closed');
        }
        
        // Step 2: Wait for dialog animation to complete
        await Future.delayed(const Duration(milliseconds: 500));
        print('⏳ Step 2: Waited 500ms for UI update');
        
        // Step 3: Show success snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Logout successful'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          print('📱 Step 3: SnackBar displayed');
        }

        // Step 4: Navigate to LoginPage - CLEAR ALL ROUTES FROM STACK
        if (mounted) {
          print('🔄 Step 4: Navigating to LoginPage...');
          
          // This clears the entire navigation stack and navigates to LoginPage
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (newContext) => const LoginForm(),
            ),
            (route) => false, // Remove ALL previous routes
          );
          
          print('✅ Step 4: Navigation to LoginPage complete');
        }
      } else {
        // Handle error response from API
        print('❌ API Error Status: ${response.statusCode}');
        
        try {
          final errorData = jsonDecode(response.body);
          if (mounted) {
            _showErrorDialog(errorData['message'] ?? 'Logout failed');
          }
        } catch (e) {
          if (mounted) {
            _showErrorDialog('Logout failed with status ${response.statusCode}');
          }
        }
      }
    } catch (e) {
      print('❌ Exception during logout: $e');
      if (mounted) {
        _showErrorDialog('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (errorContext) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(errorContext)) {
                Navigator.pop(errorContext);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _performLogout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.red.shade300,
        padding: EdgeInsets.symmetric(
          vertical: widget.screenWidth * 0.04,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: _isLoading
          ? SizedBox(
              height: widget.screenWidth * 0.05,
              width: widget.screenWidth * 0.05,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                strokeWidth: 2,
              ),
            )
          : Text(
              'Logout',
              style: TextStyle(
                fontSize: widget.screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
    );
  }
}
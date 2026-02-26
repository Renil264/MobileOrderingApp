import 'package:quickalert/quickalert.dart';
import 'package:concession_tracker_ui/core/global_fcm.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/changepassword.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/login_form.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/personaldetails.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/switch_market_page.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/termsandconditions.dart';
import 'package:concession_tracker_ui/features/auth/presentation/widgets/login_page.dart';
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
              // ── HEADER ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.06),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.07,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: screenWidth * 0.08,
                          color: AppColors.gradientTop),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            GlobalUser.name.isNotEmpty
                                ? GlobalUser.name
                                : 'User',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          Text(
                            GlobalUser.email.isNotEmpty
                                ? GlobalUser.email
                                : '',
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
                        _drawerMenuItem(context,
                            icon: Icons.store,
                            title: 'Switch Market',
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SwitchMarketPage()))),
                        _drawerMenuItem(context,
                            icon: Icons.person_outline,
                            title: 'Personal Details',
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const PersonalDetailsScreen()))),
                        _drawerMenuItem(context,
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ChangePasswordScreen()))),
                        _drawerMenuItem(context,
                            icon: Icons.credit_card,
                            title: 'Credits',
                            onTap: () {}),
                        _drawerMenuItem(context,
                            icon: Icons.description_outlined,
                            title: 'Terms and Conditions',
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const PrivacyPolicyPage()))),
                        const SizedBox(height: 30),
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.06),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // ── KEY FIX: capture root navigator BEFORE
                                //    drawer is closed — this context remains
                                //    valid after all overlays are dismissed ──
                                final rootNav = Navigator.of(context,
                                    rootNavigator: true);

                                Navigator.of(context).pop(); // close drawer

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _showLogoutDialog(context, rootNav);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.04),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout,
                                      size: screenWidth * 0.05,
                                      color: Colors.white),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text('Logout',
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold)),
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
          vertical: screenWidth * 0.015),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.035),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: AppColors.gradientTop,
                    size: screenWidth * 0.055),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: screenWidth * 0.037,
                          fontWeight: FontWeight.w500)),
                ),
                Icon(Icons.chevron_right,
                    color: Colors.grey, size: screenWidth * 0.055),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, NavigatorState rootNav) {
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
              borderRadius: BorderRadius.circular(25)),
          elevation: 12,
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        top: screenWidth * 0.08,
                        bottom: screenWidth * 0.06),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red.shade600,
                          Colors.red.shade400
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
                          child: Icon(Icons.logout,
                              color: Colors.white,
                              size: screenWidth * 0.12),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        Text('Logout',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.055,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.06),
                    child: Column(
                      children: [
                        Text('Are you sure?',
                            style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800)),
                        SizedBox(height: screenWidth * 0.03),
                        Text(
                          'You will be logged out of your account. You can log back in anytime.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey.shade600,
                              height: 1.5),
                        ),
                        SizedBox(height: screenWidth * 0.06),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenWidth * 0.04),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5),
                                  ),
                                ),
                                child: Text('Cancel',
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700)),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: _LogoutButton(
                                screenWidth: screenWidth,
                                dialogContext: dialogContext,
                                rootNav: rootNav,
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

// ── LOGOUT BUTTON ─────────────────────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  final double screenWidth;
  final BuildContext dialogContext;
  final NavigatorState rootNav;

  const _LogoutButton({
    required this.screenWidth,
    required this.dialogContext,
    required this.rootNav,
  });

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isLoading = false;

  Future<void> _performLogout() async {
  if (!mounted) return;
  setState(() => _isLoading = true);

  try {
    final response = await http
        .post(
          Uri.parse(
              'http://192.168.10.144/ConcessionTracker/api/Users/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': GlobalUser.email,
            'fcmToken': GlobalFCM.token,
          }),
        )
        .timeout(const Duration(seconds: 10));

    print('[Logout] Status: ${response.statusCode}');
    print('[Logout] Body  : ${response.body}');

    if (response.statusCode == 200) {
      // 1. Clear user state
      GlobalUser.clear();

      // 2. Close dialog
      if (Navigator.canPop(widget.dialogContext)) {
        Navigator.pop(widget.dialogContext);
      }

      await Future.delayed(const Duration(milliseconds: 90));

      // 3. Navigate to Login
      widget.rootNav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } else {
      if (Navigator.canPop(widget.dialogContext)) {
        Navigator.pop(widget.dialogContext);
      }

      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        QuickAlert.show(
          context: widget.rootNav.context,
          type: QuickAlertType.error,
          title: 'Logout Failed',
          text: 'Something went wrong. Please try again.',
          confirmBtnColor: Colors.red,
        );
      }
    }
  } catch (e) {
    print('[Logout] Exception: $e');

    if (Navigator.canPop(widget.dialogContext)) {
      Navigator.pop(widget.dialogContext);
    }

    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      QuickAlert.show(
        context: widget.rootNav.context,
        type: QuickAlertType.error,
        title: 'Connection Error',
        text: 'Could not reach the server. Please check your connection.',
        confirmBtnColor: Colors.red,
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _performLogout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.red.shade300,
        padding:
            EdgeInsets.symmetric(vertical: widget.screenWidth * 0.04),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: _isLoading
          ? SizedBox(
              height: widget.screenWidth * 0.05,
              width: widget.screenWidth * 0.05,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8)),
                strokeWidth: 2,
              ),
            )
          : Text(
              'Logout',
              style: TextStyle(
                  fontSize: widget.screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3),
            ),
    );
  }
}
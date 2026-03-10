// lib/features/auth/presentation/pages/splash_screen.dart

import 'dart:async';
import 'package:concession_tracker_ui/core/global_market.dart';
import 'package:concession_tracker_ui/core/global_selected_item.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/globalconcession.dart';
import 'package:concession_tracker_ui/core/globalmarketdata.dart';
import 'package:concession_tracker_ui/core/user_storage.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/main_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:concession_tracker_ui/features/auth/presentation/widgets/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // ── Logo fade + scale in ─────────────────────────────────────
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    _initializeApp();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Run the minimum splash duration and data loading in parallel
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _loadPersistedState(),
    ]);

    if (mounted) _route();
  }

  /// Restores all global singletons from SharedPreferences.
  /// Mirrors the load sequence in main.dart so the splash works
  /// even if main.dart's loads haven't been called yet.
  Future<void> _loadPersistedState() async {
    try {
      await UserStorage.loadUser();
      await GlobalUser.loadFromStorage();
      await GlobalMarket.loadFromStorage();
      await GlobalMarketData.loadFromStorage();
      await GlobalConcession.loadFromStorage();
      await GlobalSelectedItem.loadFromStorage();
    } catch (e) {
      debugPrint('[SplashScreen] Error loading persisted state: $e');
    }
  }

  /// Decide which screen to show:
  ///  - isLoggedIn=true  AND hasUser AND hasMarket → MainShellPage
  ///  - anything else                              → LoginPage
  Future<void> _route() async {
    try {
      final loggedInA = await UserStorage.isLoggedIn();
      final loggedInB = await GlobalUser.isLoggedIn();
      final isLoggedIn = loggedInA || loggedInB;

      final hasUser   = GlobalUser.id != 0 && GlobalUser.name.isNotEmpty;
      final hasMarket = GlobalMarket.marketName.isNotEmpty;

      debugPrint('══════════════════════════════════════');
      debugPrint('[Splash] isLoggedIn : $isLoggedIn');
      debugPrint('[Splash] hasUser    : $hasUser  (id=${GlobalUser.id})');
      debugPrint('[Splash] hasMarket  : $hasMarket ("${GlobalMarket.marketName}")');
      debugPrint('[Splash] marketId   : ${GlobalMarketData.marketId}');
      debugPrint('══════════════════════════════════════');

      if (isLoggedIn && hasUser && hasMarket) {
        _goToHome();
      } else {
        _goToLogin();
      }
    } catch (e) {
      debugPrint('[Splash] Routing error: $e');
      _goToLogin();
    }
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainShellPage(),
      ),
    );
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientTop,
              AppColors.gradientBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Logo + app name centred in remaining space ───────
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App icon / logo placeholder
                          Container(
                            width: sw * 0.28,
                            height: sw * 0.28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(sw * 0.07),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(sw * 0.07),
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                                // Fallback if logo.png is missing
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.storefront_rounded,
                                  size: sw * 0.15,
                                  color: AppColors.gradientTop,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: sh * 0.035),

                          // App title
                          Text(
                            'Concession',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.075,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'Tracker',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: sw * 0.055,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Spinner + tagline pinned to bottom ───────────────
              Padding(
                padding: EdgeInsets.only(bottom: sh * 0.06),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      SizedBox(height: sh * 0.02),
                      Text(
                        'Mobile Ordering',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: sw * 0.032,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
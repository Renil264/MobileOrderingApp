import 'package:concession_tracker_ui/core/global_device.dart';
import 'package:concession_tracker_ui/core/global_fcm.dart';
import 'package:concession_tracker_ui/core/global_market.dart';
import 'package:concession_tracker_ui/core/global_ordno.dart';
import 'package:concession_tracker_ui/core/global_selected_item.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/globalconcession.dart';
import 'package:concession_tracker_ui/core/globalmarketdata.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/splash_screen.dart';
import 'package:concession_tracker_ui/core/user_storage.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/pages/main_page.dart';
import 'package:concession_tracker_ui/injection_container.dart';
import 'package:concession_tracker_ui/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'firebase_options.dart';

String? globalFcmToken;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService().showNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await GlobalDevice.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final notificationService = NotificationService();
  await notificationService.init();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final token = await FirebaseMessaging.instance.getToken();
  GlobalFCM.token = token;
  debugPrint('FCM Token: ${GlobalFCM.token}');
  debugPrint('Device ID: ${GlobalDevice.deviceId}');


  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    globalFcmToken = newToken;
    debugPrint('FCM Token Refreshed: $globalFcmToken');
  });

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Restore all persisted state before DI wires up
  await UserStorage.loadUser();
  await GlobalUser.loadFromStorage();
  await GlobalMarket.loadFromStorage();
  await GlobalMarketData.loadFromStorage();
  await GlobalConcession.loadFromStorage();
  await GlobalSelectedItem.loadFromStorage();
  await setupLocator();

  // Decide which screen to open
  final loggedInA = await UserStorage.isLoggedIn();
  final loggedInB = await GlobalUser.isLoggedIn();
  final isLoggedIn = loggedInA || loggedInB;
  final hasUser    = GlobalUser.id != 0 && GlobalUser.name.isNotEmpty;
  final hasMarket  = GlobalMarket.marketName.isNotEmpty;

  debugPrint('══════════════════════════════');
  debugPrint('[Startup] isLoggedIn : $isLoggedIn');
  debugPrint('[Startup] hasUser    : $hasUser  (id=${GlobalUser.id})');
  debugPrint('[Startup] hasMarket  : $hasMarket ("${GlobalMarket.marketName}")');
  debugPrint('[Startup] marketId   : ${GlobalMarketData.marketId}');
  debugPrint('══════════════════════════════');

  runApp(MyApp(skipToHome: isLoggedIn && hasUser && hasMarket));
}

class MyApp extends StatelessWidget {
  final bool skipToHome;
  const MyApp({super.key, required this.skipToHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Ordering Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF172B4D),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'DM Sans'),
          bodyMedium: TextStyle(fontFamily: 'DM Sans'),
        ),
      ),
      // skipToHome=true  -> user was logged in + market selected -> go straight to app
      // skipToHome=false -> fresh install or logged out         -> show login
      home: SplashScreen()
    );
  }

  Widget _homeWithBloc() {
    return BlocProvider(
      create: (_) => sl<ConcessionBloc>()
        ..add(FetchConcessions(GlobalMarket.marketName)),
      child: const MainShellPage(),
    );
  }
}
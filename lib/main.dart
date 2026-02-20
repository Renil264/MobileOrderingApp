import 'package:concession_tracker_ui/core/global_fcm.dart';
import 'package:concession_tracker_ui/core/user_storage.dart';
import 'package:concession_tracker_ui/injection_container.dart';
import 'package:concession_tracker_ui/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/auth/presentation/widgets/login_page.dart';
import 'firebase_options.dart';

/// 🌍 Global FCM Token
String? globalFcmToken;

/// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationService().showNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  final notificationService = NotificationService();
  await notificationService.init();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  /// 🔥 Fetch FCM Token
final token = await FirebaseMessaging.instance.getToken();

GlobalFCM.token = token;

debugPrint('FCM Token Saved Globally: ${GlobalFCM.token}');

  /// 🔄 Auto update if token changes
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    globalFcmToken = newToken;
    debugPrint('🔄 FCM Token Refreshed: $globalFcmToken');
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

  await UserStorage.loadUser();
  await setupLocator();
  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const LoginPage(),
    );
  }
}

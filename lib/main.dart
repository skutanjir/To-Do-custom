import 'package:flutter/services.dart';
import 'package:pdbl_testing_custom_mobile/core/storage/local_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/pages/welcome_page.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/background_service.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/navigator_service.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/notification_helper.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/widget_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pdbl_testing_custom_mobile/firebase_options.dart';
import 'package:pdbl_testing_custom_mobile/core/services/firebase_api.dart';
import 'dart:developer';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Make status bar transparent for a more responsive and flush look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Load env and database first — many services depend on these
  await Future.wait([
    dotenv.load(fileName: ".env"),
    LocalDatabase.init(),
  ]);

  // Initialize notification system so channels exist
  await NotificationHelper.initialize();

  // Initialize Firebase securely with the auto-generated options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseApi().initNotifications();
  } catch (e) {
    log('Firebase Initialization Error: $e');
  }
  
  // Configure (but don't auto-start) the background service
  await BackgroundService.initializeService();

  // Sync widget data after database is ready
  WidgetService.init();
  WidgetService.fullSync();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXUZE',
      navigatorKey: NavigatorService.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomePage(),
    );
  }
}


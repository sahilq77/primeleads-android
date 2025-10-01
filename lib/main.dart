import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:prime_leads/controller/bottomnavigation/bottom_navigation_controller.dart';
import 'package:prime_leads/controller/global_controller.dart/state_controller.dart';
import 'package:prime_leads/controller/lead_list_controller.dart';
import 'package:prime_leads/controller/leads/get_leads_controller.dart';
import 'package:prime_leads/firebase_options.dart';
import 'package:prime_leads/notification_services%20.dart';

import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_routes.dart';
import 'package:prime_leads/utility/customdesign/connctivityservice.dart';
import 'package:prime_leads/view/bill/view_payment_pdf.dart';
import 'package:prime_leads/view/calender/calender_screen.dart';
import 'dart:developer' as lg;

import 'package:prime_leads/view/reminder_notification.dart';

@pragma('vm:entry-point')
Future<void> firebasebackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    lg.log('Background message title: ${message.data['title']}');
    lg.log('Background message data: ${message.data}');
    final notificationServices = NotificationServices();
    await notificationServices.initLocalNotifications();
    await notificationServices.showNotification(message);
  } catch (e) {
    lg.log('Error in background handler: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize NotificationServices
  final reminderNotification = ReminderNotification();
  await reminderNotification.init();

  final NotificationServices notificationServices = NotificationServices();

  notificationServices.isTokenRefresh();

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebasebackgroundHandler);

  Get.lazyPut<BottomNavigationController>(
    () => BottomNavigationController(),
    fenix: true,
  );
  Get.put(ConnectivityService(), permanent: true);
  Get.lazyPut<StateController>(() => StateController(), fenix: true);
  Get.lazyPut<GetLeadsController>(() => GetLeadsController(), fenix: true);

  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]).then((_) {
  //   runApp(const MyApp());
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize foreground notification handling
    final NotificationServices notificationServices = Get.put(
      NotificationServices(),
    );
    notificationServices.firebaseInit(context);
    notificationServices.setInteractMessage(context);

    return GetMaterialApp(
      title: 'Prime Leads',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.background,
          primary: AppColors.primary,
        ),
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0.0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.defaultblack,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          bodyMedium: const TextStyle(
            fontSize: 16,
            color: AppColors.defaultblack,
          ),
          headlineSmall: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.defaultblack,
          ),
          bodyLarge: const TextStyle(color: AppColors.defaultblack),
          bodySmall: const TextStyle(color: AppColors.defaultblack),
          headlineLarge: const TextStyle(color: AppColors.defaultblack),
          headlineMedium: const TextStyle(color: AppColors.defaultblack),
          titleLarge: const TextStyle(color: AppColors.defaultblack),
          titleMedium: const TextStyle(color: AppColors.defaultblack),
          titleSmall: const TextStyle(color: AppColors.defaultblack),
          labelLarge: const TextStyle(color: AppColors.defaultblack),
          labelMedium: const TextStyle(color: AppColors.defaultblack),
          labelSmall: const TextStyle(color: AppColors.defaultblack),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.textfieldBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.error),
          ),
          prefixIconColor: AppColors.primary,
          labelStyle: TextStyle(color: AppColors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.borderColor),
          ),
          margin: const EdgeInsets.all(8),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      builder: (context, child) {
        return ColorfulSafeArea(
          color: AppColors.background,
          top: true,
          bottom: true,
          left: false,
          right: false,
          child: child ?? Container(),
        );
      },
    );
  }
}

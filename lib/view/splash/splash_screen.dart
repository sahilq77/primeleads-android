import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_images.dart';
import '../../controller/splash/splash_controller.dart';
import '../../notification_services .dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? pushtoken;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    notificationServices.firebaseInit(context);
    notificationServices.setInteractMessage(context);
    notificationServices.getDevicetoken().then((value) {
      log('Device Token $value');
      pushtoken = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              height: screenHeight * 0.40,
              width: screenHeight * 0.40,
              child: Image.asset(AppImages.splashlogo),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                "© 2025 Prime Leads. All rights reserved.",
                style: TextStyle(color: AppColors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

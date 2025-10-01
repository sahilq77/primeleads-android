import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_leads/controller/subscription/set_payment_controller.dart';
import 'package:prime_leads/model/subscription/submit_subscription_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';

import '../../model/subscription/set_cities_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';
import '../profile/profile_controller.dart';

class BuySubscriptionController extends GetxController {
  final ProfileController profileController = Get.put(ProfileController());
  final SetPaymentController _setPaymentController = Get.put(
    SetPaymentController(),
  );
  RxBool isLoading = true.obs;

  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchUserProfile(context: Get.context!);
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    // Split the topic string by comma and subscribe to each topic
    List<String> topics = topic.split(',');
    for (String singleTopic in topics) {
      await FirebaseMessaging.instance.subscribeToTopic(singleTopic.trim());
      print('Subscribed to topic: ${singleTopic.trim()}');
    }
  }

  Future<void> submitSubscription({
    BuildContext? context,
    required String? subscriptionid,
    required String? subscriptionUserId,
    required String? stateID,
    required dynamic cityID,
    required String? transactionID,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSubUId = prefs.getString('subUId') ?? '';
      print('Retrieved subUId from prefs in submit: $savedSubUId');
      final jsonBody = {
        "subscribtion_id":
            subscriptionid!.isNotEmpty
                ? subscriptionid
                : profileController.userProfileList.first.subscriptionId,
        "user_id": AppUtility.userID,
        "subscribed_user_id":
            savedSubUId.isNotEmpty
                ? savedSubUId
                : profileController.userProfileList.first.subscribedUserId,
        "sector_id": AppUtility.sectorID,
        "state_id": stateID,
        "city_id": cityID,
        "transaction_no":
            transactionID!.isNotEmpty
                ? transactionID
                : profileController.userProfileList.first.transactioId,
        "payment": 1.toString(), // 1=success, 0=pending
      };

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.submitsubscritionApi,
        Networkutility.submitsubscrition,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetSetCitiesResponse> response = List.from(list);
        if (response[0].status == "true") {
          final user = response[0].data;
          await prefs.remove('subUId');
          print('subUId cleared from prefs after success');
          // AppUtility.setUserInfo(
          //   "",
          //   AppUtility.userID.toString(),
          //   AppUtility.sectorID.toString(),
          //   user.subscribtionId,
          // );
          // subscribeToTopic(user.topicName);

          // Show Thank You Dialog
          // _showThankYouDialog(context ?? Get.context!);
          Get.offAllNamed(AppRoutes.leads);
          print("set city success");
        } else {
          Get.snackbar(
            'Error',
            response[0].message,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      } else {
        Get.back();
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Function to show the Thank You dialog
  void _showThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop();
          Get.offNamed(AppRoutes.home);
        });

        return WillPopScope(
          onWillPop: () async => false, // Prevents dismissing by back button
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 105,
                      width: 95,
                      child: SvgPicture.asset(AppImages.thankyou),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Thank You',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Your account is ready to use. You will be redirected to the Home page in a few seconds.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                    // SizedBox(height: 16.0),
                    // Center(
                    //   child: TextButton(
                    //     onPressed: () {
                    //       Navigator.of(context).pop();
                    //     },
                    //     child: Text(
                    //       'Close',
                    //       style: GoogleFonts.inter(
                    //         color: AppColors.primaryTeal,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

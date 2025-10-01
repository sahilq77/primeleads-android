import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_leads/model/subscription/set_payments_response.dart';
import 'package:prime_leads/model/subscription/submit_subscription_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';

import '../../utility/app_colors.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class SetPaymentController extends GetxController {
  RxBool isLoading = true.obs;
  RxString subUId = "".obs;
  Future<void> subscribeToTopic(String topic) async {
    // Split the topic string by comma and subscribe to each topic
    List<String> topics = topic.split(',');
    for (String singleTopic in topics) {
      await FirebaseMessaging.instance.subscribeToTopic(singleTopic.trim());
      print('Subscribed to topic: ${singleTopic.trim()}');
    }
  }

  Future<void> setPayment({
    BuildContext? context,
    required String? subsUserid,
    required String? subscriptionid,
    required String? paymentStaus,

    required String? transactionID,
    required String? refNo,
  }) async {
    try {
      final jsonBody = {
        "subscribed_user_id": subsUserid,
        "subscribtion_id": subscriptionid,
        "user_id": AppUtility.userID,
        "sector_id": AppUtility.sectorID,
        "transaction_no": transactionID,
        "ref_no": refNo,
        "payment": paymentStaus, // 1=success, 0=failed/cancel
      };

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.setPaymentApi,
        Networkutility.setPayment,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetSetPaymentResponse> response = List.from(list);
        if (response[0].status == "true") {
          final user = response[0].data;

          subUId = user.id.obs;
          log("*****SubUID ${subUId}******");
          // Persist to SharedPrefs
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('subUId', user.id);
          print("Sub id saved to prefs: ${user.id}");
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
}

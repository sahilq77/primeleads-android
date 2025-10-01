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

import '../../model/subscription/set_order_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class SetOrderController extends GetxController {
  RxBool isLoading = true.obs;
  var setOrderList = <SetOrderData>[].obs;

  Future<void> setOrder({
    BuildContext? context,
    required String? subscriptionid,
  }) async {
    try {
      final jsonBody = {
        "subscribtion_id": subscriptionid,
        "user_id": AppUtility.userID,
        "sector_id": AppUtility.sectorID,
      };

      isLoading.value = true;

      List<GetSetOrderResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.setOrderApi,
                Networkutility.setOrder,
                jsonEncode(jsonBody),
                context!,
              ))
              as List<GetSetOrderResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final user = response[0].data;
          setOrderList.add(
            SetOrderData(
              id: user!.id,
              subscribtionId: user!.subscribtionId,
              refNo: user!.refNo,
            ),
          );
        } else {
          Get.snackbar(
            'Error',
            response[0].message.toString(),
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      } else {
        // Get.back();
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

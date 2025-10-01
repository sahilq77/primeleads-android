import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/profile/get_delete_user_response.dart';
import 'package:prime_leads/model/subscription_status/get_subscription_status_response.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';
import '../profile/profile_controller.dart';

class SubscriptionStatusController extends GetxController {
  final ProfileController profileController = Get.put(ProfileController());
  var errorMessager = ''.obs;
  RxBool isLoadingr = true.obs;
  RxString subStatus = "".obs;
  RxBool firstBy = true.obs;

  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchUserProfile(context: Get.context!);
    });
  }

  Future<void> getSubStatus({BuildContext? context}) async {
    try {
      final jsonBody = {
        "user_id": AppUtility.userID,
        "sector_id": AppUtility.sectorID,
        "subscribed_user_id":
            profileController.userProfileList.first.subscribedUserId,
      };

      isLoadingr.value = true;
      errorMessager.value = '';

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.checkSubscriptionStatusApi,
        Networkutility.checkSubscriptionStatus,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetSubscriptionStatusResponse> response = List.from(list);
        if (response[0].status == "true") {
          final sub = response[0].data;
          subStatus.value = sub!.hasExpired;
          // Get.snackbar(
          //   'Success',
          //   'User deleted successfully',
          //   backgroundColor: AppColors.success,
          //   colorText: Colors.white,
          // );
        } else if (response[0].status == "false") {
          firstBy.value = false;
          print("status ${firstBy.value}");
          // errorMessager.value = response[0].message;
          // Get.snackbar(
          //   'Error',
          //   response[0].message,
          //   backgroundColor: AppColors.error,
          //   colorText: Colors.white,
          // );
        }
      } else {
        firstBy.value = false;
        print("status ${firstBy.value}");
        // errorMessager.value = 'No response from server';
        // Get.snackbar(
        //   'Error',
        //   'No response from server',
        //   backgroundColor: AppColors.error,
        //   colorText: Colors.white,
        // );
      }
    } on NoInternetException catch (e) {
      errorMessager.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessager.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessager.value = '${e.message} (Code: ${e.statusCode})';
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessager.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessager.value = 'Unexpected error: $e';
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoadingr.value = false;
    }
  }
}

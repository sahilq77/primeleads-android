import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/otp/get_send_otp_response.dart';

import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_routes.dart';

class RegisterSendOtpController extends GetxController {
  RxBool isLoading = true.obs;
  Future<void> sendOTP({
    required BuildContext? context,
    required String? mobileNumber,

    argu,
    isalready,
  }) async {
    try {
      final jsonBody = {"mobile_number": "$mobileNumber"};

      isLoading.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.sendOtpApi,
        Networkutility.sendOtp,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetSendOtpResponse> response = List.from(list);
        if (response[0].status == "true") {
          final otp = response[0].data;
          Get.snackbar(
            'Success',
            'OTP sent successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          Get.toNamed(AppRoutes.registerotp, arguments: argu);
        }
        // else {
        //   if (isalready == true) {
        //     Get.toNamed(AppRoutes.registerotp, arguments: argu);
        //   } else {
        //     _registerDialog(Get.context!, mobileNumber!);
        //   }
      } else {
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
        'Unexpected errorColor: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

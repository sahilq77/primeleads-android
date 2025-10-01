import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/otp/get_send_otp_response.dart';
import 'package:prime_leads/model/otp/get_verify_otp_response.dart';

import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_routes.dart';

class RegisterVerifyOtpController extends GetxController {
  RxBool isLoading = true.obs;
  Future<void> verifyOTP({
    required BuildContext? context,
    required String? mobileNumber,
    required String? otp,
    argu,
    isalready,
  }) async {
    try {
      final jsonBody = {"mobile_number": "$mobileNumber", "otp": otp};

      isLoading.value = true;
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.verifyOtpApi,
        Networkutility.verifyOtp,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetVerifyOtpResponse> response = List.from(list);
        if (response[0].status == "true") {
          final data = response[0].data;
          Get.snackbar(
            'Success',
            'OTP verified successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          print("Arguments ===> ${argu}");
          Get.toNamed(
            AppRoutes.category,
            arguments: {
              "name": data.userName,
              "state": data.stateId,
              "city": data.cityId,
              "mobile": data.mobileNumber,
            },
          );
        } else if (response[0].status == "false") {
          // Get.back();
          if (response[0].message.contains('Invalid OTP')) {
            Get.snackbar(
              "Failed",
              "Invalid OTP. Please try again.",
              backgroundColor: AppColors.error,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              "Failed",
              response[0].message,
              backgroundColor: AppColors.error,
              colorText: Colors.white,
            );
          }
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
        'Unexpected errorColor: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

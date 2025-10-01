import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/otp/get_send_otp_response.dart';

import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_routes.dart';

class LoginSendOtpController extends GetxController {
  RxBool isLoading = true.obs;
  Future<void> sendOTP({
    required BuildContext? context,
    required String? mobileNumber,
    Map<String, dynamic>? argu,
    bool? isalready,
  }) async {
    try {
      final bool fromRegistration = argu?['fromRegistration'] ?? false;
      final jsonBody =
          fromRegistration
              ? {
                "mobile_number": mobileNumber,
                "user_name": argu?['name'],
                "state_id": argu?['state'],
                "city_id": argu?['city'],
              }
              : {"mobile_number": mobileNumber};

      isLoading.value = true;
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.sendOtpApi,
        Networkutility.sendOtp,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetSendOtpResponse> response = List.from(list);
        if (response[0].status == "true") {
          Get.snackbar(
            'Success',
            'OTP sent successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          Get.toNamed(
            fromRegistration ? AppRoutes.registerotp : AppRoutes.otp,
            arguments: fromRegistration ? argu : mobileNumber,
          );
        } else if (response[0].status == "false") {
          if (response[0].message.contains("Invalid mobile number format")) {
            Get.snackbar(
              'Error',
              'The mobile number format is incorrect,\nPlease try again.',
              backgroundColor: AppColors.error,
              colorText: Colors.white,
            );
          }
        }
      } else {
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
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

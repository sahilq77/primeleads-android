import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/controller/login/login_controller.dart';
import 'package:prime_leads/model/otp/get_send_otp_response.dart';
import 'package:prime_leads/model/otp/get_verify_otp_response.dart';

import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_routes.dart';

class VerifyLoginOtpController extends GetxController {
  RxBool isLoading = true.obs;
  RxString token = ''.obs;
  final loginControlller = Get.put(LoginController());
  Future<void> verifyOTP({
    required BuildContext? context,
    required String? mobileNumber,
    required String? otp,
    required String? token,
    argu,
    isalready,
  }) async {
    try {
      final jsonBody = {"mobile_number": "$mobileNumber", "otp": otp};

      isLoading.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.verifyOtpApi,
        Networkutility.verifyOtp,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetVerifyOtpResponse> response = List.from(list);
        if (response[0].status == "true") {
          final otp = response[0].data;
          Get.snackbar(
            'Success',
            'OTP verified successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          print("Arguments ===> ${argu}");
          loginControlller.login(
            mobileNumber: mobileNumber.toString(),
            otp: otp.toString(),
            token: token,
          );
          // Get.toNamed(
          //   AppRoutes.category,
          //   arguments: {
          //     "name": name,

          //     "state": state,
          //     "city": city,
          //     "mobile": mobile,
          //   },
          // );
        } else if (response[0].status == "false") {
          Get.snackbar(
            'Error',
            'Verify OTP failed',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      } else {
        // Get.back();
        Get.snackbar(
          'Error',
          'Verify OTP failed',
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

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/controller/login/login_send_otp_controller.dart';
import 'package:prime_leads/model/check_mobile/check_mobile_response.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/login/get_login_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';
import '../register/register_otp/register_send_otp_controller.dart';

class CheckMobileController extends GetxController {
  RxBool isLoading = true.obs;
  final loginSendOtpControlller = Get.put(LoginSendOtpController());
  Future<void> checkMobile({
    required BuildContext? context,
    required String? mobileNumber,
    Map<String, dynamic>? argu,
    bool? isalready,
  }) async {
    try {
      final jsonBody = {"mobile_number": mobileNumber};
      isLoading.value = true;
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.checkmobileApi,
        Networkutility.checkmobile,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<CheckMobileResponse> response = List.from(list);
        bool fromRegistration = argu?['fromRegistration'] ?? false;

        if (response[0].status == "true") {
          if (fromRegistration) {
            Get.snackbar(
              'Failed',
              'The mobile number you entered is already registered.',
              backgroundColor: AppColors.error,
              colorText: Colors.white,
            );
          } else {
            await loginSendOtpControlller.sendOTP(
              context: context,
              mobileNumber: mobileNumber,
              argu: argu,
            );
          }
        } else {
          if (fromRegistration) {
            await loginSendOtpControlller.sendOTP(
              context: context,
              mobileNumber: mobileNumber,
              argu: argu,
            );
          } else {
            _registerDialog(Get.context!, mobileNumber!);
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

  Future<void> checkRegisterMobile({
    required BuildContext? context,
    required String? mobileNumber,
    argu,
    isalready,
  }) async {
    try {
      final jsonBody = {"mobile_number": mobileNumber};

      isLoading.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.checkmobileApi,
        Networkutility.checkmobile,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<CheckMobileResponse> response = List.from(list);
        if (response[0].status == "true") {
          // final user = response[0].data;
          // log("userid${user.userid}");
          Get.snackbar(
            'Failed',
            'The mobile number you entered is already registered.',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        } else if (response[0].status == "false") {
          await loginSendOtpControlller.sendOTP(
            context: context,
            mobileNumber: mobileNumber,
            argu: argu,
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
        'Unexpected errorColor: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  _registerDialog(context, String mobile) {
    return showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  backgroundColor: Color(0xFFF8F8F8),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 20,
                        bottom: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryTeal,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.white,
                                ),
                                // child: SvgPicture.asset(
                                //   AppImages.logoutIcon,
                                //   color: Colors.white,
                                //   height: 40,
                                //   width: 40,
                                // ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'You are not register!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Go to registration page and register.',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          // Text(
                          //   'Do you wish to proceed?',
                          //   style: TextStyle(fontSize: 15),
                          //   textAlign: TextAlign.center,
                          // ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ), // Mimics button padding
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Background color
                                      border: Border.all(
                                        color: Colors.grey,
                                      ), // Border
                                      borderRadius: BorderRadius.circular(
                                        5,
                                      ), // Rounded corners
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(
                                            0xFF7A7773,
                                          ), // Text color
                                          fontSize:
                                              16, // Default text size for buttons in Flutter
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Get.toNamed(
                                      AppRoutes.register,
                                      arguments: mobile,
                                    );
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryTeal,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Register',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }
}

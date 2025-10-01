import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/login/get_login_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class RegisterController extends GetxController {
  RxBool isLoading = true.obs;
  Future<void> subscribeToTopic(String topic) async {
    // Split the topic string by comma and subscribe to each topic
    List<String> topics = topic.split(',');
    for (String singleTopic in topics) {
      await FirebaseMessaging.instance.subscribeToTopic(singleTopic.trim());
      print('Subscribed to topic: ${singleTopic.trim()}');
    }
  }

  Future<void> register({
    BuildContext? context,
    required String? mobileNumber,
    required String? name,
    required String? state,
    required String? city,
    required String? sectorid,
    required String? token,
  }) async {
    try {
      final jsonBody = {
        "mobile_number": int.parse(mobileNumber.toString()),
        "user_name": name,
        "state_id": int.parse(state.toString()),
        "city_id": int.parse(city.toString()),
        "sector_id": int.parse(sectorid.toString()),
        "device_token": token,
      };

      isLoading.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.registerApi,
        Networkutility.register,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetLoginResponse> response = List.from(list);
        if (response[0].status == "true") {
          final user = response[0].data;
          // log("userid${user.userid}");
          await AppUtility.setUserInfo(
            user.sectorName,
            user.id,
            user.sectorID,
            "",
          );
          subscribeToTopic(user.topicName);
          Get.snackbar(
            'Success',
            'Login Success',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          Get.offNamed(AppRoutes.home);
          // Get.offNamed('/dashboard');
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
        'Unexpected errorColor: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

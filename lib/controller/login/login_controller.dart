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

class LoginController extends GetxController {
  RxBool isLoading = false.obs;

  Future<void> subscribeToTopic(String topic) async {
    // Split the topic string by comma and subscribe to each topic
    List<String> topics = topic.split(',');
    for (String singleTopic in topics) {
      await FirebaseMessaging.instance.subscribeToTopic(singleTopic.trim());
      print('Subscribed to topic: ${singleTopic.trim()}');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    // Split the topic string by comma and unsubscribe from each topic
    List<String> topics = topic.split(',');
    for (String singleTopic in topics) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(singleTopic.trim());
      print('Unsubscribed from topic: ${singleTopic.trim()}');
    }
  }

  Future<void> manageTopicSubscriptions({
    String? topicsToSubscribe,
    String? topicsToUnsubscribe,
  }) async {
    try {
      // First unsubscribe from old topics
      if (topicsToUnsubscribe != null && topicsToUnsubscribe.isNotEmpty) {
        await unsubscribeFromTopic(topicsToUnsubscribe);
      }

      // Then subscribe to new topics
      if (topicsToSubscribe != null && topicsToSubscribe.isNotEmpty) {
        await subscribeToTopic(topicsToSubscribe);
      }
    } catch (e) {
      log('Error managing topic subscriptions: $e');
    }
  }

  Future<void> login({
    BuildContext? context,
    required String? mobileNumber,
    required String? otp,
    required String? token,
  }) async {
    try {
      final jsonBody = {
        "mobile_number": mobileNumber,
        "otp": otp,
        "is_login": 1, //1=login, 0=logout
        "device_token": token,
      };

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.loginApi,
        Networkutility.login,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetLoginResponse> response = List.from(list);
        if (response[0].status == "true") {
          final user = response[0].data;
          await AppUtility.setUserInfo(
            user.sectorName,
            user.id,
            user.sectorID,
            user.subscriptionId,
          );

          // Manage topic subscriptions (unsubscribe from old, subscribe to new)
          await manageTopicSubscriptions(
            topicsToUnsubscribe: user.topicUnsubscribed,
            topicsToSubscribe: user.topicName,
          );

          Get.snackbar(
            'Success',
            'Login Success',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          Get.offNamed(AppRoutes.home);
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

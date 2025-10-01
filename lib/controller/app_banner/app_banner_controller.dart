import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/utility/app_utility.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/app_banner/get_banner_reponse.dart';

class AppBannerController extends GetxController {
  var bannerImagesList = <BannerImages>[].obs;
  var errorMessage = ''.obs;
  var errorMessagel = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingl = true.obs;
  RxBool isLoadingNoti = true.obs;
  RxString imageLink = "".obs;

  Future<void> subscribeToTopic(String topic) async {
    // Sanitize the topic name to ensure it meets Firebase requirements
    String sanitizedTopic = topic.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    if (sanitizedTopic.isNotEmpty &&
        RegExp(r'^[0-9]').hasMatch(sanitizedTopic)) {
      sanitizedTopic = 'topic_$sanitizedTopic';
    }
    sanitizedTopic =
        sanitizedTopic.length > 250
            ? sanitizedTopic.substring(0, 250)
            : sanitizedTopic;

    try {
      await FirebaseMessaging.instance.subscribeToTopic(sanitizedTopic);
      print('Subscribed to topic: $sanitizedTopic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  Future<void> fetchBannerImages({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    required String? token,
  }) async {
    try {
      print('Fetching banner images with token: $token');
      if (reset) {
        bannerImagesList.clear();
      }
      isLoading.value = true;
      errorMessage.value = '';

      final jsonBody = {
        "sector_id": AppUtility.sectorID,
        "user_id": AppUtility.userID,
        "device_token": token,
      };

      List<GetBannerImagesResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.bannerImagesApi,
                Networkutility.bannerImages,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetBannerImagesResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final images = response[0].data;
          // Subscribe to a topic (use token if available, or a default topic)
          if (token != null && token.isNotEmpty) {
            await subscribeToTopic(token);
          } else {
            await subscribeToTopic('banner_updates');
          }
          bannerImagesList.clear();
          for (var img in images) {
            bannerImagesList.add(
              BannerImages(
                id: img.id,
                sectorId: img.sectorId,
                bannerImage: img.bannerImage,
                sectorName: img.sectorName,
              ),
            );
          }
        }
      } else {
        errorMessage.value = 'No response from server';
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
    } on ParseException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

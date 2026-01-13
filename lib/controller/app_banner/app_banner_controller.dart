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
        if (response[0].topicToUnsubscribed.isNotEmpty) {
          await unsubscribeFromTopic(response[0].topicToUnsubscribed);
        }
        if (response[0].topic.isNotEmpty) {
          await subscribeToTopic(response[0].topic);
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

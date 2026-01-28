import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/app_banner/get_banner_viedo_response.dart';
import 'package:prime_leads/utility/app_utility.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/app_banner/get_banner_reponse.dart';

class AppBannerVideoController extends GetxController {
  var bannerVideoList = <BannerVideo>[].obs;
  var errorMessage = ''.obs;
  var errorMessagel = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingl = true.obs;
  RxBool isLoadingNoti = true.obs;
  RxString imageLink = "".obs;

  Future<void> fetchBannerVideos({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        bannerVideoList.clear();
      }
      isLoading.value = true;
      errorMessage.value = '';

      final jsonBody = {"sector_id": AppUtility.sectorID};

      List<GetBannerVideoResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getBannerVideoApi,
                Networkutility.getBannerVideo,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetBannerVideoResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final videos = response[0].data;
          // Subscribe to a topic (use token if available, or a default topic)

          bannerVideoList.clear();
          for (var vid in videos) {
            bannerVideoList.add(
              BannerVideo(
                id: vid.id,
                sectorId: vid.sectorId,
                thumbnail: vid.thumbnail,
                bannerVideo: vid.bannerVideo,
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

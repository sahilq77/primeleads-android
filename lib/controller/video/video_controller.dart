import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prime_leads/core/network/exceptions.dart';
import 'package:prime_leads/core/network/networkcall.dart';
import 'package:prime_leads/model/video/get_training_video_response.dart';
import 'package:prime_leads/utility/app_utility.dart';

import '../../core/network/createjson/creatjson.dart';
import '../../core/urls.dart';
import '../../utility/app_colors.dart';

class VideoController extends GetxController {
  var videoList = <VideoData>[].obs;
  var isLoading = false.obs;
  var isFetchingMore = false.obs;
  var hasMore = true.obs;
  var offset = '0'.obs;
  var errorMessage = ''.obs;

  static VideoController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    fetchVideos(context: Get.context!, reset: true);
  }

  Future<void> fetchVideos({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    if (!forceFetch &&
        ((isLoading.value && !isPagination) ||
            (isFetchingMore.value && isPagination) ||
            (!hasMore.value && !reset))) {
      log('Fetch aborted: isLoading=${isLoading.value}, isFetchingMore=${isFetchingMore.value}, hasMore=${hasMore.value}, reset=$reset');
      return;
    }

    try {
      if (isPagination) {
        isFetchingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';
      if (reset) {
        offset.value = '0';
        videoList.clear();
        hasMore.value = true;
        log('Resetting video list and offset to 0');
      }

      log('Fetching videos with offset: ${offset.value}, limit: 10, sectorId: ${AppUtility.sectorID}');

      final jsonBody = Createjson().createJsonForGetTrainingVideo(
        AppUtility.sectorID ?? '',
        '10',
        offset.value,
        AppUtility.userID ?? '',
      );

      List<GetTrainingVideoResponse>? response =
          (await Networkcall().postMethod(
        Networkutility.getTrainingVideoApi,
        Networkutility.getTrainingVideo,
        jsonBody,
        context,
      )) as List<GetTrainingVideoResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final videos = response[0].data;
          log('Received ${videos.length} videos');
          if (videos.isEmpty) {
            hasMore.value = false;
            log('No more videos available');
          } else {
            if (isPagination) {
              // Check for duplicates by comparing IDs
              final existingIds = videoList.map((v) => v.id).toSet();
              final newVideos =
                  videos.where((v) => !existingIds.contains(v.id)).toList();
              if (newVideos.isNotEmpty) {
                videoList.addAll(newVideos);
                log('Added ${newVideos.length} new videos, total: ${videoList.length}');
              } else {
                log('No new videos after filtering duplicates');
              }
            } else {
              videoList.assignAll(videos);
              log('Refreshed video list with ${videos.length} videos');
            }
            hasMore.value = videos.length == 10;
            if (isPagination && hasMore.value) {
              offset.value =
                  (int.parse(offset.value.isEmpty ? "0" : offset.value) + 10)
                      .toString();
              log('Incremented offset to: ${offset.value}');
            }
          }
        } else {
          hasMore.value = false;
          errorMessage.value = response[0].message;
          log('API error: ${response[0].message}');
          Get.snackbar('Error', response[0].message,
              backgroundColor: AppColors.error, colorText: Colors.white);
        }
      } else {
        errorMessage.value = 'No response from server';
        log('No response from server');
        Get.snackbar('Error', 'No response from server',
            backgroundColor: AppColors.error, colorText: Colors.white);
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      log('NoInternetException: ${e.message}');
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.error, colorText: Colors.white);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      log('TimeoutException: ${e.message}');
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.error, colorText: Colors.white);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      Get.snackbar('Error', '${e.message} (Code: ${e.statusCode})',
          backgroundColor: AppColors.error, colorText: Colors.white);
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      log('ParseException: ${e.message}');
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.error, colorText: Colors.white);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      log('Unexpected error: $e');
      Get.snackbar('Error', 'Unexpected error: $e',
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      if (isPagination) {
        isFetchingMore.value = false;
      } else {
        isLoading.value = false;
      }
      log('Fetch completed: isLoading=${isLoading.value}, isFetchingMore=${isFetchingMore.value}');
    }
  }

  Future<void> refreshVideos(BuildContext context) async {
    log('Refreshing videos');
    await fetchVideos(context: context, reset: true, forceFetch: true);
  }
}

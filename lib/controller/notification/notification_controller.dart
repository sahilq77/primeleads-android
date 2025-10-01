import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/notification/get_notification_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';

class NotificationController extends GetxController {
  var notiList = <NotificationData>[].obs;
  var errorMessage = ''.obs;

  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs; // For pagination loading
  RxBool hasMoreData = true.obs; // To track if more data is available
  RxInt offset = 0.obs; // Pagination offset
  final int limit = 10; // Number of items per page

  @override
  void onInit() {
    super.onInit();
    fetchleadsList(context: Get.context!);
  }

  Future<void> fetchleadsList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    String? date,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        notiList.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) {
        log('No more data to fetch');
        return; // Exit if no more data is available
      }

      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "user_id": AppUtility.userID,
        "sector_id": AppUtility.sectorID,
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      List<GetNotificationResoponse>? response =
          (await Networkcall().postMethod(
                Networkutility.notificationListApi,
                Networkutility.notificationList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetNotificationResoponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final leads = response[0].data;
          if (leads.isEmpty || leads.length < limit) {
            hasMoreData.value = false; // No more data if fewer leads than limit
            log('No more data or fewer items received: ${leads.length}');
          } else {
            hasMoreData.value = true; // More data might be available
          }
          // Add only new items to avoid duplicates
          for (var lead in leads) {
            if (!notiList.any(
              (existing) => existing.notificationId == lead.notificationId,
            )) {
              notiList.add(
                NotificationData(
                  pushId: lead.pushId,
                  sectorList: lead.sectorList,
                  customerDetails: lead.customerDetails,
                  notificationId: lead.notificationId,
                  pushCreatedOn: lead.pushCreatedOn,
                  id: lead.id,
                  title: lead.title,
                  description: lead.description,
                  notificationImage: lead.notificationImage,
                  createdOn: lead.createdOn,
                  updatedOn: lead.updatedOn,
                ),
              );
            }
          }
          // Increment offset only if new data was added
          if (leads.isNotEmpty) {
            offset.value += leads.length; // Use actual number of items received
            log('Offset updated to: ${offset.value}');
          }
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No leads found';
          log('API returned status false: No leads found');
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
        log('No response from server');
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      log('NoInternetException: ${e.message}');
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      log('TimeoutException: ${e.message}');
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      log('ParseException: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      log('Unexpected error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreResults({required BuildContext context}) async {
    if (!isLoadingMore.value && hasMoreData.value && !isLoading.value) {
      log('Loading more results with offset: ${offset.value}');
      await fetchleadsList(context: context, isPagination: true);
    }
  }

  Future<void> refreshleadsList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      // Reset the result list
      notiList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      // Set loading state
      if (showLoading) {
        isLoading.value = true;
      }

      // Fetch the result list
      await fetchleadsList(context: context, reset: true, forceFetch: true);

      // Show success message if no errors
      if (errorMessage.value.isEmpty) {
        // Get.snackbar(
        //   'Success',
        //   'Results refreshed successfully',
        //   backgroundColor: AppColors.success ?? Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh leads: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }
}

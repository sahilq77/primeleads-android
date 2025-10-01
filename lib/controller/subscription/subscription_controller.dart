import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/subscription/get_subscription_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';

class SubscriptionController extends GetxController {
  var subcriptionsList = <Subscription>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchSubcriptions(context: Get.context!);
    });
  }

  Future<void> fetchSubcriptions({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset || !isPagination) {
        subcriptionsList.clear();
      }
      isLoading.value = true;
      errorMessage.value = '';

      final jsonBody = {
        "sector_id": AppUtility.sectorID,
        "user_id": AppUtility.userID,
      };

      List<GetSubscriptionResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getSubscriptionApi,
                Networkutility.getSubscription,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetSubscriptionResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final subscrption = response[0].data;

          // Defer Observable updates to after the build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            for (var sub in subscrption) {
              if (!subcriptionsList.any((existing) => existing.id == sub.id)) {
                subcriptionsList.add(
                  Subscription(
                    id: sub.id,
                    sectorId: sub.sectorId,
                    packageName: sub.packageName,
                    noOfLeads: sub.noOfLeads,
                    amount: sub.amount,
                    discountAmount: sub.discountAmount,
                    image: sub.image,
                    validityDays: sub.validityDays,
                    tags: sub.tags,
                    sectorName: sub.sectorName,
                    bulletPoints: sub.bulletPoints,
                  ),
                );
              }
            }
          });
        } else {
          errorMessage.value = 'No subscriptions found';
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

  Future<void> refreshAllData({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      subcriptionsList.clear();
      errorMessage.value = '';

      if (showLoading) {
        isLoading.value = true;
      }

      final fetchOperations = <Future<void>>[
        fetchSubcriptions(context: context, reset: true, forceFetch: true),
      ];

      await Future.wait(fetchOperations);

      if (errorMessage.value.isEmpty) {
        // Get.snackbar(
        //   'Success',
        //   'Data refreshed successfully',
        //   backgroundColor: AppColors.successColor ?? Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh data: $e';
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

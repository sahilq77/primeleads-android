import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/controller/app_banner/app_banner_controller.dart';
import 'package:prime_leads/controller/smarter_lead/smarter_lead_controller.dart';
import 'package:prime_leads/controller/whyprimeleads/whyprimeleads_controller.dart';

import '../../notification_services .dart';
import '../../utility/app_colors.dart';
import '../lead_list_controller.dart';
import '../leads/get_leads_controller.dart';
import '../testimonial/testimonial_controller.dart';

class HomeController extends GetxController {
  final appbanner = Get.put(AppBannerController());
  final whyprimeleads = Get.put(WhyprimeleadsController());
  final smartlead = Get.put(SmarterLeadController());
  final testimonial = Get.put(TestimonialController());
  final leadListController = Get.put(GetLeadsController());

  var errorMessage = ''.obs;
  // RxString? pushtoken;
  // NotificationServices notificationServices = NotificationServices();
  @override
  Future<void> refreshAllData({
    required BuildContext context,
    bool showLoading = true,
    String? token,
  }) async {
    try {
      // Reset all lists
      appbanner.bannerImagesList.clear();
      whyprimeleads.whyprimeList.clear();
      smartlead.smarterList.clear();
      testimonial.testimonialList.clear();
      leadListController.leadsList.clear();
      // examListController.examDetailList.clear();
      // notificationsList.clear();
      errorMessage.value = '';

      // Set loading states
      if (showLoading) {
        appbanner.isLoading.value = true;
        whyprimeleads.isLoading.value = true;
        smartlead.isLoading.value = true;
        testimonial.isLoading.value = true;
        leadListController.isLoading.value = true;
      }

      // Create a list of all fetch operations
      final fetchOperations = <Future<void>>[
        appbanner.fetchBannerImages(
          context: context,
          reset: true,
          forceFetch: true,
          token: token,
        ),
        whyprimeleads.fetchwhyprimeleads(
          context: context,
          reset: true,
          forceFetch: true,
        ),
        smartlead.fetchSmartLead(
          context: context,
          reset: true,
          forceFetch: true,
        ),
        testimonial.fetchtestimonial(
          context: context,
          reset: true,
          forceFetch: true,
        ),
        leadListController.fetchleadsList(
          context: context,
          reset: true,
          forceFetch: true,
        ),
        // fetchNotification(context: context, reset: true, forceFetch: true),
      ];

      // Execute all fetch operations concurrently
      await Future.wait(fetchOperations);

      // Optional: Show success message
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
        appbanner.isLoading.value = false;
        // isLoadingNoti.value = false;
      }
    }
  }
}

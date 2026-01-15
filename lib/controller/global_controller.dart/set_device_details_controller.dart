import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prime_leads/core/network/exceptions.dart';
import 'package:prime_leads/core/network/networkcall.dart';
import 'package:prime_leads/core/urls.dart';
import 'package:prime_leads/model/set_device_details/get_set_device_detail_response.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_utility.dart';

class SetDeviceDetailsController extends GetxController {
  var isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    setDeviceDetail();
  }

  // -----------------------------------------------------------------
  // LOGIN METHOD
  // -----------------------------------------------------------------
  // -----------------------------------------------------------------
  // LOGIN METHOD
  // -----------------------------------------------------------------
  Future<void> setDeviceDetail({
    BuildContext? context,

    // required String? deviceToken,
  }) async {
    try {
      final deviceDetails = await _getDeviceInfo();
      final permissionDetails = await _getPermissionStatus();

      final jsonBody = {
        "device_id": deviceDetails["device_id"] ?? "unknown",
        "device_details": deviceDetails,
        "permission_details": permissionDetails,
        "user_id": AppUtility.userID ?? "",
        "sector_id": AppUtility.sectorID ?? "",
      };

      log(jsonEncode(jsonBody));

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.setDeviceDetailsApi,
        Networkutility.setDeviceDetails,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        // Properly parse the list using your helper function
        List<SetDeviceDetailResponse> response =
            setDeviceDetailResponseFromJson(jsonEncode(list));

        if (response[0].status == true) {
          // await AppUtility.setDeviceId(deviceDetails["device_id"] ?? "unknown");
        } else if (response[0].status == false) {
          // Use actual error or message from API
        }
      } else {
        Get.snackbar(
          'Server error',
          'No response from server',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );

        // AppSnackbarStyles.showError(
        //   title: 'Server Error',
        //   message: 'No response from server',
        // );
      }
    } on NoInternetException catch (e) {
      Get.back();
      Get.snackbar(
        'No Internet',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      Get.back();
      Get.snackbar(
        'Timeout',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      Get.back();
      Get.snackbar(
        'HTTP Error',
        e.message,
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

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        "platform": "Android",
        "device_id": androidInfo.id,
        "model": androidInfo.model,
        "brand": androidInfo.brand,
        "version": androidInfo.version.release,
        "sdk_int": androidInfo.version.sdkInt,
        "app_version": packageInfo.version,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        "platform": "iOS",
        "device_id": iosInfo.identifierForVendor ?? "unknown",
        "model": iosInfo.model,
        "name": iosInfo.name,
        "version": iosInfo.systemVersion,
        "app_version": packageInfo.version,
      };
    }
    return {
      "platform": "Unknown",
      "device_id": "unknown",
      "app_version": packageInfo.version,
    };
  }

  Future<Map<String, bool>> _getPermissionStatus() async {
    try {
      return {
        "camera": await Permission.camera.isGranted,
        "photos": await Permission.photos.isGranted,
        "storage": await Permission.storage.isGranted,
        "notification": await Permission.notification.isGranted,
        "manageExternalStorage":
            Platform.isAndroid
                ? await Permission.manageExternalStorage.isGranted
                : false,
      };
    } catch (e) {
      return {
        "camera": false,
        "photos": false,
        "storage": false,
        "notification": false,
        "manageExternalStorage": false,
      };
    }
  }

  // @override
  // void onClose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   emailFocusNode.dispose();
  //   passwordFocusNode.dispose();
  //   super.onClose();
  // }
}

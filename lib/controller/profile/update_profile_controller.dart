import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prime_leads/controller/profile/profile_controller.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/profile/get_update_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class UpadteProfileController extends GetxController {
  final profileController = Get.put(ProfileController());
  var imagePath = ''.obs; // non-nullable RxString
  RxBool isLoading = false.obs;
  var base64Image = ''.obs; // Store base64 image

  final ImagePicker _picker = ImagePicker();
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
      final bytes = await File(pickedFile.path).readAsBytes();
      base64Image.value = '${base64Encode(bytes)}';
      print('Bs64====>$base64Image');
    }
  }

  RxBool isLoadingu = true.obs;
  Future<void> updateProfile({
    BuildContext? context,

    ///  required String? image,
    required String? fullName,
    required String? state,
    required String? city,
  }) async {
    try {
      final jsonBody = {
        "sector_id": AppUtility.sectorID,
        "user_id": AppUtility.userID,
        "user_name": fullName,
        "profile_image": base64Image.value,
        "state_id": state,
        "city_id": city,
      };

      isLoadingu.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.updateProfileApi,
        Networkutility.updateProfile,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetUpdateResponse> response = List.from(list);
        if (response[0].status == "true") {
          // final user = response[0].data;
          // await AppUtility.setUserInfo(
          //  user.
          // );

          Get.snackbar(
            'Success',
            'Profile updated successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          await profileController.fetchUserProfile(
            context: Get.context!,
            isRefresh: true,
          );
          Get.offNamed(AppRoutes.profile);
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
      isLoadingu.value = false;
    }
  }
}

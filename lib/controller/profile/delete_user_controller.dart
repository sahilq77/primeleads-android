import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/profile/get_delete_user_response.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';

class DeleteUserController extends GetxController {
  var errorMessager = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingr = true.obs;
  Future<void> delteUser({
    BuildContext? context,
  
  }) async {
    try {
      final jsonBody = {
        "user_id": AppUtility.userID,

        "sector_id": AppUtility.sectorID,
      };

      isLoadingr.value = true;
      errorMessager.value = '';

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.deleteUserApi,
        Networkutility.deleteUser,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetDeleteUserResponse> response = List.from(list);
        if (response[0].status == "true") {
          Get.snackbar(
            'Success',
            'User deleted successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
        } else {
          errorMessager.value = response[0].message;
          Get.snackbar(
            'Error',
            response[0].message,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessager.value = 'No response from server';
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      errorMessager.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessager.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessager.value = '${e.message} (Code: ${e.statusCode})';
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessager.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessager.value = 'Unexpected error: $e';
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoadingr.value = false;
    }
  }
}

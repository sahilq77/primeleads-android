import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prime_leads/model/logout/get_logout_response.dart';
import 'package:prime_leads/model/profile/get_profile_response.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/login/get_login_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class ProfileController extends GetxController {
  var selectedUser = Rxn<ProfileData>();
  var userProfileList = <ProfileData>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxString imageLink = "".obs;
  RxString packageName = "".obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserProfile(
        context: Get.context!,
      ); // Fetch user profile on initialization
    });
  }

  // Method to set the selected user
  void setSelectedUser(ProfileData user) {
    selectedUser.value = user;
  }

  // Method to clear the selected user
  void clearSelectedUser() {
    selectedUser.value = null;
  }

  // Method to fetch user profile
  Future<void> fetchUserProfile({
    required BuildContext context,
    bool isRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (isRefresh) {
        userProfileList.clear(); // Clear existing data on refresh
      }

      final jsonBody = {
        "user_id": AppUtility.userID,
        "sector_id": AppUtility.sectorID,
      };

      List<GetProfileResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getProfileApi,
                Networkutility.getProfile,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetProfileResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final users = response[0].data;
          packageName.value = users!.subscriptionDetail!.packageName ?? "";
          userProfileList.add(
            ProfileData(
              id: users.id,
              fullName: users.fullName,
              profileImage: users.profileImage,
              mobileNumber: users.mobileNumber,
              state: users.state,
              city: users.city,
              sectorId: users.sectorId,
              sectorName: users.sectorName,
              subscriptionDetail: users.subscriptionDetail,
              subscriptionId: users.subscriptionId,
              transactioId: users.transactioId,
              isSelectedCities: users.isSelectedCities,
              hasReceivedLeads: users.hasReceivedLeads,
              subscribedUserId: users.subscribedUserId,
              refNo: users.refNo,
            ),
          );
          // if (users.isSelectedCities!.isNotEmpty &&
          //     users.isSelectedCities == "0") {
          //   Get.snackbar(
          //     onTap: (snack) => Get.toNamed(AppRoutes.profile),
          //     'Hello, ${users.fullName}',
          //     'Go to subscription detail and please select cities to get leads',
          //     backgroundColor: AppColors.primary,
          //     colorText: Colors.white,
          //   );
          // }
        } else {
          errorMessage.value =
              'Failed to load profile: ${response[0].message ?? 'Unknown error'}';
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

  // Method to handle pull-to-refresh
  Future<void> onRefresh(BuildContext context) async {
    userProfileList.clear();
    await fetchUserProfile(context: context, isRefresh: true);
  }

  RxBool isLoadingout = true.obs;
  Future<void> logout({BuildContext? context}) async {
    try {
      final jsonBody = {
        "user_id": AppUtility.userID,
        "sector_id": AppUtility.sectorID,
        "is_login": 0, //1=login, 0=logout
      };

      isLoadingout.value = true;
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.logoutApi,
        Networkutility.logout,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetLogoutResponse> response = List.from(list);
        if (response[0].status == "true") {
          final logout = response[0].data;
          subscribeToTopic(logout.topicName);
          Get.snackbar(
            'Success',
            'Logout Successful',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          AppUtility.clearUserInfo().then((_) {
            Get.offAllNamed(
              AppRoutes.login,
            ); // Navigate to login screen after logout
          });
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
      isLoadingout.value = false;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    // Split the topic string by comma and subscribe to each topic
    List<String> topics = topic.split(',');
    for (String singleTopic in topics) {
      await FirebaseMessaging.instance.subscribeToTopic(singleTopic.trim());
      print('Subscribed to topic: ${singleTopic.trim()}');
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/leads/get_lead_detail_response.dart';
import '../../model/leads/get_note_update_response.dart';

import '../../model/leads/set_reminder_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';
import '../profile/profile_controller.dart';

class GetLeadDetailController extends GetxController {
  final profileController = Get.put(ProfileController());
  var leadsDetailList = <LeadDetail>[].obs;
  var errorMessage = ''.obs;
  var errorMessageUp = ''.obs;
  var errorMessager = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingr = true.obs;
  RxBool isLoadingup = true.obs;
  RxString totalLeads = "".obs;
  RxString recivedLeads = "".obs;
  RxString remainingLeads = "".obs;

  @override
  // void onInit() {
  //   super.onInit();
  //   fecthLeadDtail(context: Get.context!);
  // }
  Future<void> fecthLeadDtail({
    required BuildContext context,
    bool reset = false,
    String? date,
    required String leadId,
  }) async {
    try {
      if (reset) {
        leadsDetailList.clear();
      }
      isLoading.value = true;
      errorMessage.value = '';

      final jsonBody = {
        "user_id": AppUtility.userID,
        "sector_id": AppUtility.sectorID,
        "subscribtion_id":
            profileController.userProfileList.first.subscriptionId,
        "lead_id": leadId,
      };

      List<GetLeadDetailResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getLeadDetailsApi,
                Networkutility.getLeadDetails,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetLeadDetailResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final leads = response[0].data;
          leadsDetailList.add(
            LeadDetail(
              userId: leads.userId,
              leadId: leads.leadId,
              sectorId: leads.sectorId,
              userName: leads.userName,
              leadsId: leads.leadsId,
              name: leads.name,
              mobileNo: leads.mobileNo,
              whatsappNo: leads.whatsappNo,
              state: leads.state,
              city: leads.city,
              location: leads.location,
              note: leads.note,
              reminderDate: leads.reminderDate,
              reminderTime: leads.reminderTime,
              createdOn: leads.createdOn,
              additionalDetails: leads.additionalDetails,
            ),
          );
        } else {
          errorMessage.value = response[0].message ?? 'Failed to fetch leads';
          Get.snackbar(
            'Error',
            errorMessage.value,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
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

  Future<void> refreshleadsList({
    required BuildContext context,
    bool showLoading = true,
    required String leadId,
  }) async {
    try {
      errorMessage.value = '';
      if (showLoading) {
        isLoading.value = true;
      }
      await fecthLeadDtail(context: context, reset: true, leadId: leadId);
      if (errorMessage.value.isEmpty) {
        Get.snackbar(
          'Success',
          'Results refreshed successfully',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
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

  Future<void> updateNote({
    BuildContext? context,
    required String? id,
    required String? note,
  }) async {
    try {
      final jsonBody = {
        "user_id": AppUtility.userID,
        "lead_id": id,
        "sector_id": AppUtility.sectorID,
        "note": note,
      };

      isLoadingup.value = true;
      errorMessageUp.value = '';

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.upadteNoteApi,
        Networkutility.upadteNote,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetNoteUpdateResponse> response = List.from(list);
        if (response[0].status == "true") {
          Get.snackbar(
            'Success',
            'Note updated successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          await fecthLeadDtail(
            context: context!,
            leadId: id ?? "",
            reset: true,
          );
        } else {
          errorMessageUp.value = response[0].message;
          Get.snackbar(
            'Error',
            response[0].message,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessageUp.value = 'No response from server';
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      errorMessageUp.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessageUp.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessageUp.value = '${e.message} (Code: ${e.statusCode})';
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessageUp.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessageUp.value = 'Unexpected error: $e';
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoadingup.value = false;
    }
  }

  Future<void> setReminder({
    BuildContext? context,
    required String? id,
    required String? rdate,
    required String? rtime,
  }) async {
    try {
      final jsonBody = {
        "user_id": AppUtility.userID,
        "lead_id": id,
        "sector_id": AppUtility.sectorID,
        "reminder_date": rdate,
        "reminder_time": rtime,
      };

      isLoadingr.value = true;
      errorMessager.value = '';

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.setReminderApi,
        Networkutility.setReminder,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<SetReminderResponse> response = List.from(list);
        if (response[0].status == "true") {
          Get.snackbar(
            'Success',
            'Reminder added successfully',
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

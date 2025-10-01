import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/leads/get_note_update_response.dart';

import 'package:prime_leads/model/reminder/get_reminder_list_response.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/leads/get_leads_response.dart';
import '../../model/leads/set_reminder_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';

class ReminderListController extends GetxController {
  var leadsList = <ReminderData>[].obs;
  var errorMessage = ''.obs;
  var errorMessageUp = ''.obs;
  var errorMessager = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingr = true.obs;
  RxBool isLoadingup = true.obs;
  RxBool isLoadingMore = false.obs; // For pagination loading
  RxBool hasMoreData = true.obs; // To track if more data is available
  RxInt offset = 0.obs; // Pagination offset
  final int limit = 10; // Number of items per page
  RxString totalLeads = "".obs;
  RxString recivedLeads = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchReminderList(context: Get.context!);
  }

  Future<void> fetchReminderList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    String? date,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        leadsList.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) return; // No more data to fetch

      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "user_id": AppUtility.userID,
        "sector_id": AppUtility.sectorID,
        "reminder_date": date, //filter
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      List<GetReminderListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.reminderListApi,
                Networkutility.reminderList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetReminderListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final leads = response[0].data;
          if (leads.isEmpty || leads.length < limit) {
            hasMoreData.value = false; // No more data if fewer leads than limit
          }
          for (var lead in leads) {
            leadsList.add(
              ReminderData(id: lead.id,
              sectorId: lead.sectorId, 
              userId: lead.userId, 
              note: lead.note, 
              reminderDate: lead.reminderDate, 
              reminderTime: lead.reminderTime, 
              name: lead.name, 
              mobileNo: lead.mobileNo, 
              whatsappNo: lead.whatsappNo, 
              date: lead.date)
            );
          }
          offset.value += limit; // Increment offset for next page
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No leads found';
        }
      } else {
        hasMoreData.value = false;
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
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreResults({required BuildContext context}) async {
    if (!isLoadingMore.value && hasMoreData.value) {
      await fetchReminderList(context: context, isPagination: true);
    }
  }

  Future<void> refreshleadsList({
    required BuildContext context,
    bool showLoading = true,
    String? date, // Add date parameter
  }) async {
    try {
      // Reset the result list
      leadsList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      // Set loading state
      if (showLoading) {
        isLoading.value = true;
      }

      // Fetch the result list with the provided date
      await fetchReminderList(
        context: context,
        reset: true,
        forceFetch: true,
        date: date,
      );

      // Show success message if no errors
      if (errorMessage.value.isEmpty) {}
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
        "sector_id":
            AppUtility.sectorID, // Fixed typo: sectorID instead of userID
        "note": note,
      };

      isLoadingup.value = true;
      errorMessageUp.value = '';

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility
            .upadteNoteApi, // Typo in your code: should be updateNoteApi
        Networkutility.upadteNote, // Typo: should be updateNote
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetNoteUpdateResponse> response = List.from(list);
        if (response[0].status == "true") {
          // Update the specific lead in leadsList
          int index = leadsList.indexWhere((lead) => lead.id == id);
          if (index != -1) {
            leadsList[index] = leadsList[index].copyWith(note: note);
            leadsList.refresh(); // Notify GetX to update the UI
          }

          Get.snackbar(
            'Success',
            'Note updated successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
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
      if (errorMessageUp.value.isNotEmpty) {
        Get.back();
      }
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
        "sector_id":
            AppUtility.sectorID, // Fixed typo: sectorID instead of userID
        "reminder_date": rdate,
        "reminder_time": rtime,
      };

      isLoadingr.value = true;
      errorMessager.value = '';

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility
            .setReminderApi, // Typo in your code: should be updateNoteApi
        Networkutility.setReminder, // Typo: should be updateNote
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<SetReminderResponse> response = List.from(list);
        if (response[0].status == "true") {
          // Update the specific lead in leadsList
          // int index = leadsList.indexWhere((lead) => lead.id == id);
          // if (index != -1) {
          //   leadsList[index] = leadsList[index].copyWith(note: "");
          //   leadsList.refresh(); // Notify GetX to update the UI
          // }

          Get.snackbar(
            'Success',
            'Reminder added successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
        } else if (response[0].status == "false") {
          // errorMessager.value = response[0].message;
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
      if (errorMessager.value.isNotEmpty) {
        Get.back();
      }
    }
  }
}

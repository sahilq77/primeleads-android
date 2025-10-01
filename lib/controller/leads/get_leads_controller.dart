import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/leads/get_leads_response.dart';
import '../../model/leads/get_note_update_response.dart';

import '../../model/leads/set_reminder_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';
import '../profile/profile_controller.dart';

class GetLeadsController extends GetxController {
  final profileController = Get.put(ProfileController());
  var leadsList = <LeadsData>[].obs;
  var errorMessage = ''.obs;
  var errorMessageUp = ''.obs;
  var errorMessager = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingr = true.obs;
  RxBool isLoadingup = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMoreData = true.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxString totalLeads = "".obs;
  RxString recivedLeads = "".obs;
  RxString remainingLeads = "".obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await profileController.fetchUserProfile(context: Get.context!);
      await fetchleadsList(context: Get.context!);
    });
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
        leadsList.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) return;

      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "user_id": AppUtility.userID,
        "sector_id": AppUtility.sectorID,
        "subscribtion_id":
            profileController.userProfileList.first.subscriptionId.toString(),
        "created_date": date ?? "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      List<GetLeadsResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getleadsApi,
                Networkutility.getleads,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetLeadsResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final leads = response[0].data;
          if (leads == null || leads.isEmpty || leads.length < limit) {
            hasMoreData.value = false;
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            for (var lead in leads!) {
              if (!leadsList.any(
                (existingLead) => existingLead.leadId == lead.leadId,
              )) {
                leadsList.add(
                  LeadsData(
                    noteId: lead.noteId,
                    id: lead.id,
                    leadId: lead.leadId,
                    name: lead.name,
                    mobileNo: lead.mobileNo,
                    whatsappNo: lead.whatsappNo,
                    packageName: lead.packageName,
                    note: lead.note,
                    sectorName: lead.sectorName,
                    distributionDate: lead.distributionDate,
                    totalLeads: lead.totalLeads,
                    leadsSent: lead.leadsSent,
                    remainLeads: lead.remainLeads,
                    city: lead.city,
                    location: lead.location,
                    packageId: lead.packageId,
                    receivedLeads: lead.receivedLeads,
                    state: lead.state,
                  ),
                );
                totalLeads.value = lead.totalLeads.toString();
                recivedLeads.value = lead.receivedLeads.toString();
                remainingLeads.value = lead.remainLeads.toString();
              }
            }

            if (leads!.isNotEmpty) {
              offset.value += leads.length;
            } else {
              hasMoreData.value = false;
            }
          });
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
      await fetchleadsList(context: context, isPagination: true);
    }
  }

  Future<void> refreshleadsList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      errorMessage.value = '';
      if (showLoading) {
        isLoading.value = true;
      }
      await fetchleadsList(context: context, reset: true, forceFetch: true);
      if (errorMessage.value.isEmpty) {
        // Get.snackbar(
        //   'Success',
        //   'Results refreshed successfully',
        //   backgroundColor: AppColors.success,
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
          int index = leadsList.indexWhere((lead) => lead.id == id);
          if (index != -1) {
            leadsList[index] = leadsList[index].copyWith(note: note);
            leadsList.refresh();
          }
          int inde = leadsList.indexWhere((lead) => lead.noteId == id);
          if (inde != -1) {
            leadsList[inde] = leadsList[inde].copyWith(note: note);
            leadsList.refresh();
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

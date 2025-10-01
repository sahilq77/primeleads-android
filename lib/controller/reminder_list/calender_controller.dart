import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/reminder/get_calender_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';

class CalendarController extends GetxController {
  var currentDate = DateTime.now().obs;
  var reminders = <DateTime, int>{}.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReminders();
  }

  Future<void> fetchReminders({BuildContext? context}) async {
    try {
      final String month = DateFormat('yyyy-MM-01').format(currentDate.value);
      final jsonBody = {
        "month": month,
        "user_id": AppUtility.userID,
        "sector_id": AppUtility.sectorID,
      };

      isLoading.value = true;
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.reminderCountApi,
        Networkutility.reminderCount,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetCalenderResponse> response = List.from(list);
        if (response[0].status == "true") {
          final cal = response[0].data;
          reminders.clear();
          for (var reminder in cal) {
            final date = DateTime.parse(reminder.reminderDate.toString());
            reminders[date] = reminder.reminderCount as int;
          }
        } else {
          Get.snackbar(
            '', // Title (can be empty if not needed)
            response[0].message, // Message
            backgroundColor: AppColors.secondary,
            colorText: Colors.white,
            snackbarStatus: (status) {}, // Optional: handle status if needed

            titleText: Text(
              '', // Empty title if not needed
              style: TextStyle(
                color: Colors.white,
                fontSize: 0,
              ), // Hide title if empty
            ),
            messageText: Text(
              response[0].message,
              style: TextStyle(
                color: Colors.white,
                // fontSize: 16, // Adjust font size as needed
                // fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center, // Center the message text
            ),
          );
          // Get.snackbar(

          //   '',

          //   response[0].message,
          //   backgroundColor: AppColors.secondary,
          //   colorText: Colors.white,
          // );
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
      isLoading.value = false;
    }
  }

  Future<void> refreshCalendar() async {
    await fetchReminders();
  }

  void previousMonth() {
    currentDate.value = DateTime(
      currentDate.value.year,
      currentDate.value.month - 1,
    );
    fetchReminders();
  }

  void nextMonth() {
    currentDate.value = DateTime(
      currentDate.value.year,
      currentDate.value.month + 1,
    );
    fetchReminders();
  }
}

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/payment_list/get_payment_list_response.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/notification/get_notification_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';

class PaymentListController extends GetxController {
  var paymentList = <PaymentData>[].obs;
  var errorMessage = ''.obs;

  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs; // For pagination loading
  RxBool hasMoreData = true.obs; // To track if more data is available
  RxInt offset = 0.obs; // Pagination offset
  final int limit = 10; // Number of items per page

  @override
  void onInit() {
    super.onInit();
    fetchPaymentList(context: Get.context!);
  }

  Future<void> fetchPaymentList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    String? date,
    String? payment,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        paymentList.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) {
        log('No more data to fetch');
        return; // Exit if no more data is available
      }

      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "user_id": AppUtility.userID,
        "sector_id": AppUtility.sectorID,
        "limit": limit.toString(),
        "offset": offset.value.toString(),
        "buy_date": date, //filter
        "payment": payment, //filter
      };

      List<GetPaymentListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.paymentListApi,
                Networkutility.paymentList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetPaymentListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final leads = response[0].data;
          if (leads.isEmpty || leads.length < limit) {
            hasMoreData.value = false; // No more data if fewer leads than limit
            log('No more data or fewer items received: ${leads.length}');
          } else {
            hasMoreData.value = true; // More data might be available
          }
          // Add only new items to avoid duplicates
          for (var lead in leads) {
            if (!paymentList.any((existing) => existing.id == lead.id)) {
              paymentList.add(
                PaymentData(
                  refNo: lead.refNo,
                  id: lead.id,
                  transactionNo: lead.transactionNo,
                  userName: lead.userName,
                  mobileNumber: lead.mobileNumber,
                  buyDate: lead.buyDate,
                  amount: lead.amount,
                  packageName: lead.packageName,
                  payment: lead.payment,
                ),
              );
            }
          }
          // Increment offset only if new data was added
          if (leads.isNotEmpty) {
            offset.value += leads.length; // Use actual number of items received
            log('Offset updated to: ${offset.value}');
          }
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No leads found';
          log('API returned status false: No leads found');
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
        log('No response from server');
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      log('NoInternetException: ${e.message}');
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      log('TimeoutException: ${e.message}');
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      log('ParseException: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      log('Unexpected error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreResults({required BuildContext context}) async {
    if (!isLoadingMore.value && hasMoreData.value && !isLoading.value) {
      log('Loading more results with offset: ${offset.value}');
      await fetchPaymentList(context: context, isPagination: true);
    }
  }

  Future<void> refreshleadsList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      // Reset the result list
      paymentList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      // Set loading state
      if (showLoading) {
        isLoading.value = true;
      }

      // Fetch the result list
      await fetchPaymentList(context: context, reset: true, forceFetch: true);

      // Show success message if no errors
      if (errorMessage.value.isEmpty) {
        // Get.snackbar(
        //   'Success',
        //   'Results refreshed successfully',
        //   backgroundColor: AppColors.success ?? Colors.green,
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
}

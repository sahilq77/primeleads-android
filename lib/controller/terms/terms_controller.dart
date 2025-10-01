import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/terms/get_terms_response.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../utility/app_utility.dart';

class TermsController extends GetxController {
  var termsList = <Terms>[].obs;
  var termsData = <Terms>{}.obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs; // For pagination loading
  RxBool hasMoreData = true.obs; // To track if more data is available
  RxInt offset = 0.obs; // Pagination offset
  final int limit = 10; // Number of items per page
  RxString totalLeads = "".obs;
  RxString recivedLeads = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchTerms(context: Get.context!);
  }

  Future<void> fetchTerms({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        termsList.clear();
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
        // "user_id": AppUtility.userID,
        // "sector_id": AppUtility.sectorID,
        // "subscribtion_id": 1,
        // "note": "",
        // "no_of_leads_receive": 20,
        // "limit": limit.toString(),
        // "offset": offset.value.toString(),
      };

      List<GetTermsResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getTermsApi,
                Networkutility.getTerms,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetTermsResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final terms = response[0].data;
          if (terms.isEmpty || terms.length < limit) {
            hasMoreData.value = false; // No more data if fewer terms than limit
          }

          for (var term in terms) {
            termsList.add(
              Terms(
                id: term.id,
                pageHeading: term.pageHeading,
                pageHeadingInLocalLanguage: term.pageHeadingInLocalLanguage,
                pageContent: term.pageContent,
                pageContentInLocalLanguage: term.pageContentInLocalLanguage,
                isDeleted: term.isDeleted,
                status: term.status,
                createdOn: term.createdOn,
                updatedOn: term.updatedOn,
              ),
            );
          }
          offset.value += limit; // Increment offset for next page
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No terms found';
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
      await fetchTerms(context: context, isPagination: true);
    }
  }

  Future<void> refreshleadsList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      // Reset the result list
      termsList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      // Set loading state
      if (showLoading) {
        isLoading.value = true;
      }

      // Fetch the result list
      await fetchTerms(context: context, reset: true, forceFetch: true);

      // Show success message if no errors
      if (errorMessage.value.isEmpty) {
        // Get.snackbar(
        //   'Success',
        //   'Results refreshed successfully',
        //   backgroundColor: AppColors.successColor ?? Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh terms: $e';
      // Get.snackbar(
      //   'Error',
      //   errorMessage.value,
      //   backgroundColor: AppColors.errorColor,
      //   colorText: Colors.white,
      // );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/category/get_category_response.dart';
import 'package:prime_leads/utility/app_utility.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/app_banner/get_banner_reponse.dart';

class CategoryController extends GetxController {
  var categoryList = <Category>[].obs;

  var errorMessage = ''.obs;

  RxBool isLoading = true.obs;

  void onInit() {
    super.onInit();
    fetchCategory(context: Get.context!);
  }

  Future<void> fetchCategory({
    required BuildContext context,
    bool reset = false,

    bool isPagination = false,
    bool forceFetch = false,
    bool isRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (isRefresh) {
        categoryList.clear(); // Clear existing data on refresh
      }

      // final jsonBody = Createjson().createJsonForGetProduct(
      //   "10",
      //   offset.value,
      //   "",
      //   filterProductId.value,
      //   filterCompanyId.value,
      //   filterPackagingTypeId.value,
      // );
      final jsonBody = {
        // "sector_id": AppUtility.sectorID,
        // "user_id": AppUtility.userID,
      };
      List<GetCategoryResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getCategoryApi,
                Networkutility.getCategory,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetCategoryResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final category = response[0].data;

          for (var categ in category) {
            categoryList.add(
              Category(
                id: categ.id,
                sectorName: categ.sectorName,
                icon: categ.icon,
              ),
            );
          }
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
    categoryList.clear();
    await fetchCategory(context: context, isRefresh: true);
  }
}

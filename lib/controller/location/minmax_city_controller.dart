import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/category/get_category_response.dart';
import 'package:prime_leads/model/location/get_min_max_city_response.dart';
import 'package:prime_leads/utility/app_utility.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/app_banner/get_banner_reponse.dart';

class MinmaxCityController extends GetxController {
  var minmaxList = <MinMaxCity>[].obs;
  RxString minValue = "".obs;
  RxString maxValue = "".obs;
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
        minmaxList.clear(); // Clear existing data on refresh
      }

      // final jsonBody = Createjson().createJsonForGetProduct(
      //   "10",
      //   offset.value,
      //   "",
      //   filterProductId.value,
      //   filterCompanyId.value,
      //   filterPackagingTypeId.value,
      // );
      final jsonBody = {"sector_id": AppUtility.sectorID};
      List<GetMinMaxCityResposne>? response =
          (await Networkcall().postMethod(
                Networkutility.getMinMaxApi,
                Networkutility.getMinMax,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetMinMaxCityResposne>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final category = response[0].data;
          minValue.value = category.first.minCities;
          maxValue.value = category.first.maxCities;
          log(" MAX : ${minValue.value}  |  MAX : ${maxValue.value} ");
          for (var categ in category) {
            minmaxList.add(
              MinMaxCity(
                id: categ.id,
                sectorId: categ.sectorId,
                minCities: categ.minCities,
                maxCities: categ.maxCities,
                sectorName: categ.sectorName,
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
    minmaxList.clear();
    await fetchCategory(context: context, isRefresh: true);
  }
}

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/utility/app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/global_model/get_city_response.dart';


class CityController extends GetxController {
  RxList<CityData> cityList = <CityData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedcityval;

  static CityController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    // Defer fetching until context is available
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (Get.context != null) {
    //     // You may want to pass a default stateID here or handle it in the UI
    //     fetchCities(context: Get.context!, stateID: 'default_state_id');
    //   }
    // });
  }

  Future<void> fetchCities({
    required BuildContext context,
    bool forceFetch = false,
    required String stateID,
  }) async {
    if (!forceFetch && cityList.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Corrected jsonbody format
      final jsonbody = {
        "user_type": "0",
        "login_user_id": "1",
        "state_id": stateID.toString()
      };

      List<GetCityResponse>? response = await Networkcall().postMethod(
        Networkutility.getCityApi,
        Networkutility.getCity,
        jsonEncode(jsonbody),
        context,
      ) as List<GetCityResponse>?;

      log('Fetch Cities Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}');

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          cityList.value = response[0].data;
          log('City List Loaded: ${cityList.map((c) => "${c.id}: ${c.name}").toList()}');
        } else {
          errorMessage.value = response[0].message;
          Get.snackbar('Error', response[0].message,
              backgroundColor: AppColors.error, colorText: Colors.white);
        }
      } else {
        errorMessage.value = 'No response from server';
        Get.snackbar('Error', 'No response from server',
            backgroundColor: AppColors.error, colorText: Colors.white);
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.error, colorText: Colors.white);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.error, colorText: Colors.white);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      Get.snackbar('Error', '${e.message} (Code: ${e.statusCode})',
          backgroundColor: AppColors.error, colorText: Colors.white);
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.error, colorText: Colors.white);
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      log('Fetch Cities Exception: $e, stack: $stackTrace');
      Get.snackbar('Error', 'Unexpected error: $e',
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  List<String> getCityNames() {
    return cityList.map((s) => s.name).toSet().toList();
  }

  String? getCityId(String cityName) {
    return cityList.firstWhereOrNull((city) => city.name == cityName)?.id ?? '';
  }

  String? getCityNameById(String cityId) {
    return cityList.firstWhereOrNull((city) => city.id == cityId)?.name;
  }
}
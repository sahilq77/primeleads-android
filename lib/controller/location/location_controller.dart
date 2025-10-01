import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/utility/app_utility.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/global_model/get_state_response.dart';
import '../../model/location/get_location_response.dart';
import '../../utility/app_colors.dart';

class LocationController extends GetxController {
  RxList<LocationData> stateList = <LocationData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedStateName;
  RxString? selectedCityName;
  RxString? selectedStateId;
  RxString? selectedCityId;

  static LocationController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchSectorLocations(context: Get.context!);
      }
    });
  }

  Future<void> fetchSectorLocations({
    required BuildContext context,
    bool forceFetch = false,
    bool isRefresh = false,
  }) async {
    if (!forceFetch && stateList.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (isRefresh) {
        stateList.clear(); // Clear existing data on refresh
      }

      final jsonbody = {"sector_id": AppUtility.sectorID};

      List<GetLocationResponse>? response =
          await Networkcall().postMethod(
                Networkutility.sectorLocationApi,
                Networkutility.sectorLocation,
                jsonEncode(jsonbody),
                context,
              )
              as List<GetLocationResponse>?;

      log(
        'Fetch States Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          stateList.value = response[0].data;
          log(
            'State List Loaded: ${stateList.map((s) => "${s.id}: ${s.stateName}, ${s.cityName}").toList()}',
          );
        } else {
          errorMessage.value = response[0].message;
          Get.snackbar(
            'Error',
            response[0].message,
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
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      log('Fetch States Exception: $e, stack: $stackTrace');
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

  List<String> getStateNames() {
    return stateList.map((s) => s.stateName).toSet().toList();
  }

  List<String> getCityNames(String? stateName) {
    if (stateName == null) return [];
    return stateList
        .where((s) => s.stateName == stateName)
        .map((s) => s.cityName)
        .toSet()
        .toList();
  }

  String? getStateId(String? stateName) {
    return stateList
        .firstWhereOrNull((state) => state.stateName == stateName)
        ?.stateId;
  }

  String? getCityId(String? cityName) {
    return stateList
        .firstWhereOrNull((state) => state.cityName == cityName)
        ?.cityId;
  }

  String? getStateNameById(String? stateId) {
    return stateList
        .firstWhereOrNull((state) => state.stateId == stateId)
        ?.stateName;
  }

  String? getCityNameById(String? cityId) {
    return stateList
        .firstWhereOrNull((state) => state.cityId == cityId)
        ?.cityName;
  }

  void updateSelectedState(String? stateName) {
    selectedStateName = stateName?.obs;
    selectedStateId = getStateId(stateName)?.obs;
    selectedCityName = null; // Reset city when state changes
    selectedCityId = null;
    update();
  }

  void updateSelectedCity(String? cityName) {
    selectedCityName = cityName?.obs;
    selectedCityId = getCityId(cityName)?.obs;
    update();
  }

  // Method to handle pull-to-refresh
  Future<void> onRefresh(BuildContext context) async {
    selectedStateName!.value = "";
    stateList.value.clear();
    await fetchSectorLocations(context: context, isRefresh: true);
  }
}

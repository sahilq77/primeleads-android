import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/global_model/get_state_response.dart';
import '../../utility/app_colors.dart';

// State model to hold API response data

class StateController extends GetxController {
  RxList<StateData> stateList = <StateData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedstateval;

  static StateController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    // Defer fetching until context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchStates(context: Get.context!);
      }
    });
  }

  Future<void> fetchStates({
    required BuildContext context,
    bool forceFetch = false,
  }) async {
    if (!forceFetch && stateList.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // No jsonBody for GET request
      List<GetStateResponse>? response =
          await Networkcall().getMethod(
                Networkutility.getStatesApi,
                Networkutility.getStates,
                context,
              )
              as List<GetStateResponse>?;

      log(
        'Fetch States Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          stateList.value = response[0].data;
          log(
            'State List Loaded: ${stateList.map((s) => "${s.id}: ${s.name}").toList()}',
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
    return stateList.map((s) => s.name).toSet().toList();
  }

  String? getStateId(String stateName) {
    return stateList.firstWhereOrNull((state) => state.name == stateName)?.id ??
        '';
  }

  String? getStateNameById(String stateId) {
    return stateList.firstWhereOrNull((state) => state.id == stateId)?.name;
  }
}

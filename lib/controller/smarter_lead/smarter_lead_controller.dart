import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/utility/app_utility.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/app_banner/get_banner_reponse.dart';
import '../../model/smarter_lead/get_smarter_lead_response.dart';
import '../../model/why_primeleads/whyprimeleads_response.dart';

class SmarterLeadController extends GetxController {
  var smarterList = <SmarterLead>[].obs;
  //var availableExamList = <AvailableExam>[].obs;

  var errorMessage = ''.obs;
  var errorMessagel = ''.obs;
  RxBool isLoading = true.obs;

  Future<void> fetchSmartLead({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // final jsonBody = Createjson().createJsonForGetProduct(
      //   "10",
      //   offset.value,
      //   "",
      //   filterProductId.value,
      //   filterCompanyId.value,
      //   filterPackagingTypeId.value,
      // );
      final jsonBody = {
        "sector_id": AppUtility.sectorID,
        "user_id": AppUtility.userID,
      };
      List<GetSmarterLeadResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getSmartleadssApi,
                Networkutility.getSmartleads,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetSmarterLeadResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final smarter = response[0].data;

          for (var sm in smarter) {
            smarterList.add(
              SmarterLead(
                id: sm.id,
                sectorId: sm.sectorId,
                title: sm.title,
                icon: sm.icon,
                description: sm.description,
                sectorName: sm.sectorName,
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
}

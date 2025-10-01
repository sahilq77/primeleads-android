import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/utility/app_utility.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/app_banner/get_banner_reponse.dart';
import '../../model/why_primeleads/whyprimeleads_response.dart';

class WhyprimeleadsController extends GetxController {
  var whyprimeList = <WhyPrimeleads>[].obs;
  //var availableExamList = <AvailableExam>[].obs;

  var errorMessage = ''.obs;
  var errorMessagel = ''.obs;
  RxBool isLoading = true.obs;

  Future<void> fetchwhyprimeleads({
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
      List<GetwhyprimeLeadsResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getwhyPrimeleadsApi,
                Networkutility.getwhyPrimeleads,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetwhyprimeLeadsResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final whys = response[0].data;
          whyprimeList.clear();
          for (var why in whys) {
            whyprimeList.add(
              WhyPrimeleads(
                id: why.id,
                sectorId: why.sectorId,
                title: why.title,
                icon: why.icon,
                sectorName: why.sectorName,
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

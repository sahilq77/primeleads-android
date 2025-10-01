import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/testimonial/testimonial_response.dart';
import 'package:prime_leads/utility/app_utility.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/app_banner/get_banner_reponse.dart';
import '../../model/why_primeleads/whyprimeleads_response.dart';

class TestimonialController extends GetxController {
  var testimonialList = <Testmonial>[].obs;
  //var availableExamList = <AvailableExam>[].obs;

  var errorMessage = ''.obs;
  var errorMessagel = ''.obs;
  RxBool isLoading = true.obs;

  Future<void> fetchtestimonial({
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
      List<GetTestimonialResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getTestimonialsApi,
                Networkutility.getTestimonial,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetTestimonialResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final testi = response[0].data;
          testimonialList.clear();
          for (var ts in testi) {
            testimonialList.add(
              Testmonial(
                id: ts.id,
                sectorId: ts.sectorId,
                thumbnail: ts.thumbnail,
                testimonialVideo: ts.testimonialVideo,
                sectorName: ts.sectorName,
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

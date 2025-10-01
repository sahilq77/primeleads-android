import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:prime_leads/core/network/exceptions.dart';
import 'package:prime_leads/model/global_model/get_city_response.dart';
import 'package:prime_leads/model/subscription/get_subscription_response.dart'
    show getSubscriptionResponseFromJson;

import '../../model/app_banner/get_banner_reponse.dart';

import '../../model/category/get_category_response.dart';
import '../../model/check_mobile/check_mobile_response.dart';
import '../../model/global_model/get_state_response.dart';
import '../../model/leads/get_lead_detail_response.dart';
import '../../model/leads/get_leads_response.dart';
import '../../model/leads/get_note_update_response.dart';

import '../../model/leads/set_reminder_response.dart';
import '../../model/location/get_location_response.dart';
import '../../model/location/get_min_max_city_response.dart';
import '../../model/login/get_login_response.dart';
import '../../model/logout/get_logout_response.dart';
import '../../model/notification/get_notification_response.dart';
import '../../model/otp/get_send_otp_response.dart';
import '../../model/otp/get_verify_otp_response.dart';
import '../../model/payment_list/get_payment_list_response.dart';
import '../../model/payment_list/payment_reciept_download_response.dart';
import '../../model/profile/get_delete_user_response.dart';
import '../../model/profile/get_profile_response.dart';
import '../../model/profile/get_update_response.dart';
import '../../model/reminder/get_calender_response.dart';
import '../../model/reminder/get_reminder_list_response.dart';
import '../../model/smarter_lead/get_smarter_lead_response.dart';
import '../../model/subscription/set_cities_response.dart';
import '../../model/subscription/set_order_response.dart'
    show getSetOrderResponseFromJson;
import '../../model/subscription/set_payments_response.dart';
import '../../model/subscription/submit_subscription_response.dart';
import '../../model/subscription_status/get_subscription_status_response.dart';
import '../../model/terms/get_terms_response.dart';
import '../../model/testimonial/testimonial_response.dart';
import '../../model/video/get_training_video_response.dart';
import '../../model/why_primeleads/whyprimeleads_response.dart';
import '../../utility/app_routes.dart';
import '../../utility/customdesign/connctivityservice.dart';

class Networkcall {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  static GetSnackBar? _slowInternetSnackBar;
  static const int _minResponseTimeMs =
      3000; // Threshold for slow internet (3s)
  static bool _isNavigatingToNoInternet = false; // Prevent multiple navigations

  Future<List<Object?>?> postMethod(
    int requestCode,
    String url,
    String body,
    BuildContext context,
  ) async {
    try {
      // Check connectivity with retries
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _navigateToNoInternet();
        return null;
      }

      // Start measuring response time
      final stopwatch = Stopwatch()..start();

      // Make POST request with timeout
      var response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body.isEmpty ? null : body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out. Please try again.');
            },
          );

      // Stop measuring response time
      stopwatch.stop();
      final responseTimeMs = stopwatch.elapsedMilliseconds;

      // Handle slow internet
      _handleSlowInternet(responseTimeMs);

      var data = response.body;
      if (response.statusCode == 200) {
        log(
          "url : $url \n Request Code : $requestCode \n body : $body \n Response : $data",
        );

        // Wrap response in [] for consistency
        String str = "[${response.body}]";

        switch (requestCode) {
          case 1:
            final register = getLoginResponseFromJson(str);
            return register;

          case 3:
            final getCities = getCityResponseFromJson(str);
            return getCities;
          case 4:
            final login = getLoginResponseFromJson(str);
            return login;
          case 5:
            final checkmobile = checkMobileResponseFromJson(str);
            return checkmobile;
          case 7:
            final getBanner = getBannerImagesResponseFromJson(str);
            return getBanner;
          case 8:
            final whyprimeleads = getwhyprimeLeadsResponseFromJson(str);
            return whyprimeleads;
          case 9:
            final getSmarterLead = getSmarterLeadResponseFromJson(str);
            return getSmarterLead;
          case 10:
            final getTestimonial = getTestimonialResponseFromJson(str);
            return getTestimonial;
          case 11:
            final getCategory = getCategoryResponseFromJson(str);
            return getCategory;
          case 12:
            final getTrainingVideo = getTrainingVideoResponseFromJson(str);
            return getTrainingVideo;
          case 13:
            final getSubscription = getSubscriptionResponseFromJson(str);
            return getSubscription;
          case 14:
            final getProfile = getProfileResponseFromJson(str);
            return getProfile;
          case 15:
            final updateUser = getUpdateResponseFromJson(str);
            return updateUser;
          case 16:
            final getStates = getLocationResponseFromJson(str);
            return getStates;
          case 17:
            final getMinMax = getMinMaxCityResposneFromJson(str);
            return getMinMax;
          case 18:
            final getMinMax = getLogoutResponseFromJson(str);
            return getMinMax;
          case 19:
            final submitSubscription = getSetCitiesResponseFromJson(str);
            return submitSubscription;
          case 20:
            final getLeads = getLeadsResponseFromJson(str);
            return getLeads;
          case 21:
            final terms = getTermsResponseFromJson(str);
            return terms;
          case 22:
            final updateNote = getNoteUpdateResponseFromJson(str);
            return updateNote;
          case 23:
            final getNotification = getNotificationResoponseFromJson(str);
            return getNotification;
          case 24:
            final setReminder = setReminderResponseFromJson(str);
            return setReminder;
          case 25:
            final paymentlist = getPaymentListResponseFromJson(str);
            return paymentlist;
          case 26:
            final remindercunt = getCalenderResponseFromJson(str);
            return remindercunt;

          case 27:
            final reminderlist = getReminderListResponseFromJson(str);
            return reminderlist;
          case 28:
            final recieptDownload = getPaymentRecieptUrlResponseFromJson(str);
            return recieptDownload;
          case 29:
            final deleteUser = getDeleteUserResponseFromJson(str);
            return deleteUser;
          case 30:
            final deleteUser = getLeadDetailResponseFromJson(str);
            return deleteUser;
          case 31:
            final sendOTP = getSendOtpResponseFromJson(str);
            return sendOTP;
          case 32:
            final verifyOTP = getVerifyOtpResponseFromJson(str);
            return verifyOTP;
          case 33:
            final setPayment = getSetPaymentResponseFromJson(str);
            return setPayment;
          case 34:
            final getSubscriptionStatus = getSubscriptionStatusResponseFromJson(
              str,
            );
            return getSubscriptionStatus;
          case 35:
            final setOrder = getSetOrderResponseFromJson(str);
            return setOrder;

          default:
            log("Invalid request code: $requestCode");
            throw ParseException('Unhandled request code: $requestCode');
        }
      } else {
        log("url : $url \n Request body : $data");
        throw HttpException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on NoInternetException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      await _navigateToNoInternet();
      return null;
    } on TimeoutException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      Get.snackbar(
        'Request Timed Out',
        'The server took too long to respond. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return null;
    } on HttpException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      return null;
    } on SocketException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      await _navigateToNoInternet();
      return null;
    } catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      return null;
    }
  }

  Future<List<Object?>?> getMethod(
    int requestCode,
    String url,
    BuildContext context,
  ) async {
    try {
      // Check connectivity with retries
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _navigateToNoInternet();
        return null;
      }

      // Start measuring response time
      final stopwatch = Stopwatch()..start();

      // Make GET request with timeout
      var response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out. Please try again.');
            },
          );

      // Stop measuring response time
      stopwatch.stop();
      final responseTimeMs = stopwatch.elapsedMilliseconds;

      // Handle slow internet
      _handleSlowInternet(responseTimeMs);

      var data = response.body;
      log(url);
      if (response.statusCode == 200) {
        log("url : $url \n Response : $data");
        String str = "[${response.body}]";
        switch (requestCode) {
          case 2:
            final getStates = getStateResponseFromJson(str);
            return getStates;
          default:
            log("Invalid request code: $requestCode");
            throw ParseException('Unhandled request code: $requestCode');
        }
      } else {
        log("url : $url \n Response : $data");
        throw HttpException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on NoInternetException catch (e) {
      log("url : $url \n Response : $e");
      await _navigateToNoInternet();
      return null;
    } on TimeoutException catch (e) {
      log("url : $url \n Response : $e");
      Get.snackbar(
        'Request Timed Out',
        'The server took too long to respond. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return null;
    } on HttpException catch (e) {
      log("url : $url \n Response : $e");
      return null;
    } on SocketException catch (e) {
      log("url : $url \n Response : $e");
      await _navigateToNoInternet();
      return null;
    } catch (e) {
      log("url : $url \n Response : $e");
      return null;
    }
  }

  Future<void> _navigateToNoInternet() async {
    if (!_isNavigatingToNoInternet &&
        Get.currentRoute != AppRoutes.noInternet) {
      _isNavigatingToNoInternet = true;
      // Double-check connectivity before navigating
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await Get.offNamed(AppRoutes.noInternet);
      }
      // Reset flag after a delay
      await Future.delayed(const Duration(milliseconds: 500));
      _isNavigatingToNoInternet = false;
    }
  }

  void _handleSlowInternet(int responseTimeMs) {
    if (responseTimeMs > _minResponseTimeMs) {
      // Show slow internet snackbar if not already shown
      if (_slowInternetSnackBar == null || !Get.isSnackbarOpen) {
        _slowInternetSnackBar = const GetSnackBar(
          message:
              'Slow internet connection detected. Please check your network.',
          duration: Duration(days: 1), // Persistent until closed
          backgroundColor: Colors.orange,
          snackPosition: SnackPosition.TOP,
          isDismissible: false,
          margin: EdgeInsets.all(10),
          borderRadius: 8,
        );
        Get.showSnackbar(_slowInternetSnackBar!);
      }
    } else {
      // Close slow internet snackbar if connection improves
      if (_slowInternetSnackBar != null && Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        _slowInternetSnackBar = null;
      }
    }
  }
}

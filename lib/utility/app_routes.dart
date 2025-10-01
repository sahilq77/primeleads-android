import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/model/subscription/get_subscription_response.dart';
import 'package:prime_leads/utility/customdesign/nointernetconnectionpage.dart';
import 'package:prime_leads/view/bill/bill_list_screen.dart';
import 'package:prime_leads/view/bill/payment_reciept_screen.dart';
import 'package:prime_leads/view/calender/calender_screen.dart';
import 'package:prime_leads/view/category/category_screen.dart';
import 'package:prime_leads/view/home/home_screen.dart';
import 'package:prime_leads/view/leads/leads_detail_screen.dart';
import 'package:prime_leads/view/leads/leads_screen.dart';
import 'package:prime_leads/view/location/select_location_screen.dart';
import 'package:prime_leads/view/notification/notification_detail.dart';
import 'package:prime_leads/view/notification/notification_screen.dart';
import 'package:prime_leads/view/otp/register_otp_screen.dart';
import 'package:prime_leads/view/profile/profile_screen.dart';
import 'package:prime_leads/view/profile/update_profile_screen.dart';
import 'package:prime_leads/view/reminder/reminder_list_screen.dart';
import 'package:prime_leads/view/subscription/payment_gatway_screen.dart';
import 'package:prime_leads/view/subscription/payment_success_screen.dart';
import 'package:prime_leads/view/subscription/subscription_screen.dart';
import 'package:prime_leads/view/terms/terms_screen.dart';
import 'package:prime_leads/view/video/video_details_screen.dart';
import 'package:prime_leads/view/video/video_screen.dart';
import 'package:prime_leads/view/welcome/welcome_screen.dart';
import 'package:prime_leads/view/otp/login_otp_screen.dart';
import 'package:prime_leads/view/register/register_screen.dart';

import '../binding/video/video_binding.dart';
import '../view/login/login_screen.dart';
import '../view/profile/subscription_detail_screen.dart';
import '../view/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String register = '/register';
  static const String category = '/category';
  static const String home = '/home';
  static const String leads = '/leads_list';
  static const String leadsDetails = '/leads_details';
  static const String videolist = '/video_list';
  static const String videoDetail = '/video_detail';
  static const String subscription = '/subscription';
  static const String paymentRieceipt = '/payment_receipt';
  static const String selectLocation = '/select_location';
  static const String profile = '/profile';
  static const String updateprofile = '/updateprofile';
  static const String notification = '/notification';
  static const String terms = '/terms';
  static const String bill = '/bil_payments';
  static const String noInternet = '/nointernet';
  static const String registerotp = '/register_otp';
  static const String calender = '/calender';
  static const String notifcationDetail = '/notifcationDetail';
  static const String reminderList = '/reminderlist';
  static const String paymentRecieptdownload = '/payment_download';
  static const String subdetail = '/sub_detail';
  static const String razorpayGateway = '/razorpay_gateway';
  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: welcome,
      page: () => WelcomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: otp,
      page: () => OtpVerifyScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: register,
      page: () => RegisterScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: category,
      page: () => CategorySelectionScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: leads,
      page: () => LeadsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: leadsDetails,
      page: () => LeadsDetailScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: videolist,
      page: () => VideoListScreen(),
      transition: Transition.fadeIn,
      binding: VideoBinding(),
    ),
    GetPage(
      name: videoDetail,
      page: () => VideoDetailsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: subscription,
      page: () => SubscriptionScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: paymentRieceipt,
      page: () => PaymentReceiptDetailsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: selectLocation,
      page: () => LocationSelectionScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: profile,
      page: () => ProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: updateprofile,
      page: () => UpdateProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: notification,
      page: () => NotificationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: terms,
      page: () => TermsOfUseScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: bill,
      page: () => BillListScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: noInternet,
      page: () => NoInternetPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: registerotp,
      page: () => RegisterOtpScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: calender,
      page: () => CalendarScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: notifcationDetail,
      page: () => NotificationDetailScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: reminderList,
      page: () => ReminderListScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: paymentRecieptdownload,
      page: () => PaymentRecieptScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: subdetail,
      page: () => SubscriptionDetailScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: razorpayGateway,
      page: () {
        final args = Get.arguments;
        final Subscription package = args['package'] as Subscription;
        debugPrint(
          '[AppRoutes] Creating RazorpayGateway with package: ${package.packageName}, amount: ₹${package.discountAmount}, subscriptionId: ${package.id}',
        );
        return RazorpayGateway(
          totalPayable: double.parse(
            package.discountAmount.isNotEmpty &&
                    package.discountAmount != "" &&
                    package.discountAmount != null
                ? package.discountAmount
                : package.amount,
          ),
          subscriptionId: package.id,
          finalOrderPrice: double.parse(package.discountAmount),
        );
      },
      transition: Transition.fadeIn,
    ),
  ];
}

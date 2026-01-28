import 'dart:developer';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_leads/controller/app_banner/app_banner_video_controller.dart';
import 'package:prime_leads/controller/global_controller.dart/set_device_details_controller.dart';
import 'package:prime_leads/controller/home/home_controller.dart';
import 'package:prime_leads/controller/profile/profile_controller.dart';
import 'package:prime_leads/controller/whyprimeleads/whyprimeleads_controller.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:prime_leads/utility/app_routes.dart';
import 'package:prime_leads/view/bottomnavgation/bottom_navigation.dart';
import 'package:prime_leads/view/home/full_video_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../controller/app_banner/app_banner_controller.dart';
import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/leads/get_leads_controller.dart';
import '../../controller/smarter_lead/smarter_lead_controller.dart';
import '../../controller/testimonial/testimonial_controller.dart';
import '../../controller/subscription/set_payment_controller.dart';
import '../../notification_services .dart';
import '../../utility/nodatascreen.dart';

// Define the color scheme based on the image
const Color backgroundDark = Color(0xFF1A1A2E);
const Color primaryTeal = Color(0xFF00C4B4);
const Color textWhite = Colors.white;
const Color cardWhite = Color(0xFFF5F5F5);
const Color accentOrange = Color(0xFFFFA500);
const Color accentRed = Color(0xFFFF4D4F);
const Color accentBlue = Color(0xFF4DA8DA);
const Color balanceColor = Color(0xFFFFC107);
final List<String> bannerImages = [
  AppImages.appbanner,
  AppImages.appbanner,
  AppImages.appbanner,
];

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bottomController = Get.put(BottomNavigationController());
  final appbannerVideoController = Get.put(AppBannerVideoController());
  final appbannerController = Get.put(AppBannerController());
  final homeController = Get.put(HomeController());
  final whyprimeleadsController = Get.put(WhyprimeleadsController());
  final smartleadController = Get.put(SmarterLeadController());
  final testimonialController = Get.put(TestimonialController());
  final profileController = Get.put(ProfileController());
  final leadsController = Get.put(GetLeadsController());
  final setDeviceDetailController = Get.put(SetDeviceDetailsController());
  final setPaymentController = Get.put(SetPaymentController());

  dynamic _currentPlayingVideo;

  VideoPlayerController? _videoController; // Nullable to prevent late error
  bool _hasError = false;
  double _scale = 1.0; // Initial zoom scale
  final double _minScale = 1.0; // Minimum zoom level
  final double _maxScale = 3.0; // Maximum zoom level
  int _current = 0;

  Future<void> playVideo(String url) async {
    // Dispose existing controller if any
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(url);
    try {
      await _videoController!.initialize();
      setState(() {
        _hasError = false;
        _videoController!.play(); // Autoplay after initialization
      });
    } catch (error) {
      setState(() {
        _hasError = true;
      });
      print('Error initializing video: $error');
    }
  }

  var pushtoken = ''.obs;
  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check for pending payments on app startup
      _checkPendingPayments();
      appbannerVideoController.fetchBannerVideos(context: context);
      leadsController.fetchleadsList(context: context);
      notificationServices.firebaseInit(context);
      notificationServices.setInteractMessage(context);
      notificationServices.getDevicetoken().then((value) {
        log('Device Token $value');
        pushtoken.value = value;
        // Call fetchBannerImages after token is available
        appbannerController.fetchBannerImages(
          context: context,
          token: pushtoken.value,
        );
      });
      whyprimeleadsController.fetchwhyprimeleads(context: context);
      smartleadController.fetchSmartLead(context: context);
      testimonialController.fetchtestimonial(context: context);
    });
  }

  void _showPendingPaymentSuccessDialog(
    String subscriptionId,
    String transactionId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  backgroundColor: Color(0xFFF8F8F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Payment Successful!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your payment has been processed successfully.',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Transaction ID: $transactionId',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Get.offNamed(
                                      AppRoutes.selectLocation,
                                      arguments: {
                                        'subscription_id': subscriptionId,
                                        'transaction': transactionId,
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  Future<void> _checkPendingPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingOrderId = prefs.getString('pending_order_id');
      final pendingSubscriptionId = prefs.getString('pending_subscription_id');
      final pendingTransactionId = prefs.getString('pending_transaction_id');
      final pendingRefNo = prefs.getString('pending_ref_no');
      final pendingSubsUserId = prefs.getString('pending_subs_user_id');

      if (pendingOrderId != null && pendingSubscriptionId != null) {
        log('Found pending payment: $pendingOrderId');

        // Verify payment status
        bool isPaymentCaptured = await _verifyPendingPayment(pendingOrderId);

        if (isPaymentCaptured &&
            pendingRefNo != null &&
            pendingSubsUserId != null) {
          // Call setPayment API
          await _callSetPaymentApi(
            refNo: pendingRefNo,
            subsUserId: pendingSubsUserId,
            subscriptionId: pendingSubscriptionId,
            transactionId: pendingTransactionId ?? '',
          );

          // Clear pending data and show success dialog
          await _clearPendingOrder();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showPendingPaymentSuccessDialog(
              pendingSubscriptionId,
              pendingTransactionId ?? '',
            );
          });
        }
      }
    } catch (e) {
      log('Error checking pending payments: $e');
    }
  }

  Future<bool> _verifyPendingPayment(String orderId) async {
    try {
      // Test Credentials (Replace with production credentials as needed)
      // final String _keyId = 'rzp_test_R7Swkdhjyig54S';
      // final String _keySecret = 'jS36wByFlnpeVgyEicfK2AFb';

      // live Credentials
      final String keyId = 'rzp_live_R7zacfGtzhXGgs'; //live
      final String keySecret = 'uJvnRhRllfqNuqqticemkVKX';

      final authString = base64Encode(utf8.encode('$keyId:$keySecret'));
      final response = await http.get(
        Uri.parse('https://api.razorpay.com/v1/orders/$orderId/payments'),
        headers: {'Authorization': 'Basic $authString'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List;

        if (items.isNotEmpty) {
          final payment = items.first;
          if (payment['status'] == 'captured') {
            log('Pending payment verified as captured: ${payment['id']}');
            return true;
          }
        }
      }
    } catch (e) {
      log('Error verifying pending payment: $e');
    }
    return false;
  }

  Future<void> _callSetPaymentApi({
    required String refNo,
    required String subsUserId,
    required String subscriptionId,
    required String transactionId,
  }) async {
    try {
      await setPaymentController.setPayment(
        refNo: refNo,
        subsUserid: subsUserId,
        context: context,
        subscriptionid: subscriptionId,
        paymentStaus: "1",
        transactionID: transactionId,
      );
      log('SetPayment API called successfully');
    } catch (e) {
      log('Error calling setPayment API: $e');
    }
  }

  Future<void> _clearPendingOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_order_id');
    await prefs.remove('pending_subscription_id');
    await prefs.remove('pending_transaction_id');
    await prefs.remove('pending_amount');
    await prefs.remove('pending_ref_no');
    await prefs.remove('pending_subs_user_id');
    log('Cleared pending order data');
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // appbannerController.fetchBannerImages(context: context, token: pushtoken);
    return WillPopScope(
      onWillPop: () async {
        print(
          'Main: WillPopScope triggered, current route: ${Get.currentRoute}, selectedIndex: ${bottomController.selectedIndex.value}',
        );
        if (Get.currentRoute != AppRoutes.home &&
            Get.currentRoute != AppRoutes.splash) {
          print('Main: Navigating to home');
          bottomController.selectedIndex.value = 0;
          Get.offAllNamed(AppRoutes.home);
          return false; // Prevent app exit
        }
        print('Main: On home or splash, allowing app exit');
        return true; // Allow app exit
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.white,
          centerTitle: false,
          title: Obx(() {
            if (profileController.isLoading.value &&
                profileController.userProfileList.isEmpty) {
              return Text("");
            }

            if (profileController.userProfileList.isEmpty) {
              return const Center(child: Text(""));
            }

            final user = profileController.userProfileList[0];
            print("Building with cityId: ${user.city}");

            return Text(
              'Hi, ${user.fullName} 😊',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          }),

          actions: [
            Obx(() {
              if (leadsController.isLoading.value &&
                  profileController.isLoading.value &&
                  leadsController.leadsList.isEmpty &&
                  profileController.userProfileList.isEmpty) {
                return SizedBox.shrink();
              }

              if (leadsController.leadsList.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(
                      width: 2,
                      color: const Color(0xFFFFC621),
                    ),
                    borderRadius: BorderRadius.circular(5),
                    shape: BoxShape.rectangle,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppImages.leadclockIcon,
                        height: 25,
                        width: 25,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Buy Package',
                        style: TextStyle(
                          color: const Color(
                            0xFFFF2602,
                          ), // Fixed invalid color code
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              // if (profileController
              //     .userProfileList
              //     .first
              //     .subscriptionDetail!
              //     .noOfLeads!
              //     .isNotEmpty) {
              //   return Container(
              //     padding: EdgeInsets.all(5),
              //     decoration: BoxDecoration(
              //       color: AppColors.white,
              //       border: Border.all(
              //         width: 2,
              //         color: const Color(0xFFFFC621),
              //       ),
              //       borderRadius: BorderRadius.circular(5),
              //       shape: BoxShape.rectangle,
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Image.asset(
              //           AppImages.leadclockIcon,
              //           height: 25,
              //           width: 25,
              //         ),
              //         SizedBox(width: 10),
              //         Text(
              //           '${profileController.userProfileList.first.subscriptionDetail!.noOfLeads} Leads \nRemaining!',
              //           style: TextStyle(
              //             color: const Color(
              //               0xFFFF2602,
              //             ), // Fixed invalid color code
              //             fontSize: 10,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       ],
              //     ),
              //   );
              // }
              final remainingLeads = leadsController.remainingLeads.value;
              if (remainingLeads == "0") {
                return Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(
                      width: 2,
                      color: const Color(0xFFFFC621),
                    ),
                    borderRadius: BorderRadius.circular(5),
                    shape: BoxShape.rectangle,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppImages.leadclockIcon,
                        height: 25,
                        width: 25,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Buy Package!',
                        style: TextStyle(
                          color: const Color(
                            0xFFFF2602,
                          ), // Fixed invalid color code
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              int count = int.tryParse(remainingLeads) ?? 0;
              print("Building with Remaining Leads: $count");
              return Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(width: 2, color: const Color(0xFFFFC621)),
                  borderRadius: BorderRadius.circular(5),
                  shape: BoxShape.rectangle,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.leadclockIcon, height: 25, width: 25),
                    SizedBox(width: 10),
                    Text(
                      '$count Leads \nRemaining!',
                      style: TextStyle(
                        color: const Color(
                          0xFFFF2602,
                        ), // Fixed invalid color code
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.notification);
              },
              child: SizedBox(
                height: 25,
                width: 25,
                child: SvgPicture.asset(AppImages.notificatioIcon),
              ),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.calender);
              },
              child: SizedBox(
                height: 25,
                width: 25,
                child: SvgPicture.asset(AppImages.calender2),
              ),
            ),
            SizedBox(width: 16),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10),
            child: Divider(
              color: const Color(0xFFDADADA),
              thickness: 2,
              height: 0,
            ),
          ),
        ),
        body: Obx(() {
          // Check if all data lists are empty and not loading
          bool isAllDataEmpty =
              !appbannerController.isLoading.value &&
              appbannerController.bannerImagesList.isEmpty &&
              !whyprimeleadsController.isLoading.value &&
              whyprimeleadsController.whyprimeList.isEmpty &&
              !smartleadController.isLoading.value &&
              smartleadController.smarterList.isEmpty &&
              !testimonialController.isLoading.value &&
              testimonialController.testimonialList.isEmpty;

          return RefreshIndicator(
            onRefresh: () async {
              // Reset video state before refresh
              setState(() {
                _videoController?.dispose();
                _videoController = null;
                _currentPlayingVideo = null;
              });
              return homeController.refreshAllData(
                context: context,
                token: pushtoken.value,
              );
            },
            child:
                isAllDataEmpty
                    ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height, // Ensure full height
                        child: NoDataScreen(),
                      ),
                    )
                    : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.01),
                          SizedBox(
                            child:
                                profileController.userProfileList.isNotEmpty &&
                                        profileController
                                                .userProfileList
                                                .first
                                                .isSelectedCities ==
                                            "0"
                                    ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          await Get.toNamed(
                                            AppRoutes.selectLocation,
                                            arguments: {
                                              'subscription_id':
                                                  profileController
                                                      .userProfileList
                                                      .first
                                                      .subscriptionId,
                                              'transaction':
                                                  profileController
                                                      .userProfileList
                                                      .first
                                                      .transactioId, // Fixed typo
                                            },
                                          );
                                        },
                                        child: SizedBox(
                                          height: 50,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Shimmer.fromColors(
                                                baseColor: AppColors.error,
                                                highlightColor:
                                                    AppColors.errorDark,
                                                period: const Duration(
                                                  seconds: 2,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: [
                                                            Color(0xFFFFC621),
                                                            Color(0xFFF78A21),
                                                          ],
                                                          begin:
                                                              Alignment
                                                                  .centerLeft,
                                                          end:
                                                              Alignment
                                                                  .centerRight,
                                                          tileMode:
                                                              TileMode.clamp,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  12.0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.location_pin,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          'Please Select City',
                                                          style: TextStyle(
                                                            color:
                                                                AppColors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Icon(
                                                      Icons.arrow_forward,
                                                      color: AppColors.white,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    : SizedBox.shrink(),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          _buildBannerCarousel(appbannerController),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                (appbannerVideoController.bannerVideoList)
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      return Container(
                                        width: 20.0,
                                        height: 8.0,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              _current == entry.key
                                                  ? AppColors.primaryTeal
                                                  : Colors.grey,
                                        ),
                                      );
                                    })
                                    .toList(),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.subscription),
                            child: _startyourleads(),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          _testimonial(context, screenHeight),
                          SizedBox(height: screenHeight * 0.02),
                          _whyPrimeleads(screenHeight),
                          SizedBox(height: screenHeight * 0.02),
                          _smarterleads(screenWidth, screenHeight),
                          SizedBox(height: screenHeight * 0.02),
                        ],
                      ),
                    ),
          );
        }),
        bottomNavigationBar: CustomBottomBar(),
      ),
    );
  }

  Widget _cityButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 50,
        child: Stack(
          fit: StackFit.expand, // Ensure the Stack fills the SizedBox
          children: [
            // Shimmering background
            Shimmer.fromColors(
              baseColor: const Color(0xFFFFC621),
              highlightColor: const Color(0xFFF78A21),
              period: const Duration(seconds: 2),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC621), Color(0xFFF78A21)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    tileMode: TileMode.clamp,
                  ),
                ),
              ),
            ),
            // Content on top
            Container(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppImages.crownIcon2,
                        height: 30,
                        width: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Start Your Leads Now',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, color: AppColors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _startyourleads() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 50,
        child: Stack(
          fit: StackFit.expand, // Ensure the Stack fills the SizedBox
          children: [
            // Shimmering background
            Shimmer.fromColors(
              baseColor: const Color(0xFFFFC621),
              highlightColor: const Color(0xFFF78A21),
              period: const Duration(seconds: 2),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC621), Color(0xFFF78A21)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    tileMode: TileMode.clamp,
                  ),
                ),
              ),
            ),
            // Content on top
            Container(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppImages.crownIcon2,
                        height: 30,
                        width: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Start Your Leads Now',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, color: AppColors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smarterleads(double screenWidth, screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smarter leads, Better business.',
            style: GoogleFonts.poppins(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Obx(() {
            if (smartleadController.isLoading.value) {
              return _smarterLeadsShimmerEffect(screenWidth, screenWidth);
            }

            final list = smartleadController.smarterList.value;
            if (list.isEmpty) {
              return const Center(
                child: Text(
                  'No Data',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: screenWidth * 0.02,
                mainAxisSpacing: screenHeight * 0.01,
                childAspectRatio: (screenWidth / 2) / (screenHeight * 0.11),
              ),
              itemCount: list.length < 4 ? list.length : 4,
              itemBuilder: (context, index) {
                final colors = [
                  const Color(0xFFF98428),
                  const Color(0xFFE94B64),
                  const Color(0xFF4866D2),
                  const Color(0xFF2DABE1),
                ];
                final icons = [
                  Icons.local_fire_department,
                  Icons.rocket_launch,
                  Icons.local_fire_department,
                  Icons.rocket_launch,
                ];
                return _buildSmarterLeadsCard(
                  title: list[index].title,
                  subtitle: list[index].description,
                  icon: list[index].icon,
                  color: colors[index % colors.length],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _smarterLeadsShimmerEffect(double screenWidth, double screenHeight) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: screenWidth * 0.02,
        mainAxisSpacing: screenHeight * 0.02,
        childAspectRatio: (screenWidth / 2) / (screenHeight * 0.20),
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        height: 120,
      ),
    );
  }

  Padding _whyPrimeleads(screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Prime Leads?',
            style: GoogleFonts.poppins(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Obx(() {
            if (whyprimeleadsController.isLoading.value) {
              return _whyShimmerEffect();
            }
            final items = whyprimeleadsController.whyprimeList.value;
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  'No Data',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (index) {
                return _buildFeatureCard(
                  icon: items[index].icon,
                  title: items[index].title,
                  color: primaryTeal,
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _whyShimmerEffect() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (generator) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: screenWidth * 0.28,
            height: screenHeight * 0.12,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }),
    );
  }

  Widget _testimonial(BuildContext context, screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Testimonial',
            style: GoogleFonts.poppins(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Obx(
            () =>
                testimonialController.isLoading.value
                    ? _testiShimmerEffect()
                    : testimonialController.testimonialList.isEmpty
                    ? const Center(
                      child: Text(
                        'No Data',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          testimonialController.testimonialList.length,
                          (index) => _cardtestimonial(
                            testimonialController
                                .testimonialList[index]
                                .thumbnail,
                            () async {
                              log(
                                testimonialController
                                    .testimonialList[index]
                                    .testimonialVideo
                                    .replaceAll(r'\/', '/')
                                    .replaceAll(r'\:', ':'),
                              );
                              await playVideo(
                                testimonialController
                                    .testimonialList[index]
                                    .testimonialVideo
                                    .replaceAll(r'\/', '/')
                                    .replaceAll(r'\:', ':'),
                              );
                              if (_videoController == null || _hasError) return;
                              await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder:
                                    (ctx) => StatefulBuilder(
                                      builder: (context, setStateDialog) {
                                        void listener() {
                                          if (context.mounted &&
                                              _videoController != null) {
                                            setStateDialog(() {});
                                          }
                                        }

                                        _videoController!.addListener(listener);
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: WillPopScope(
                                            onWillPop: () async {
                                              _videoController?.removeListener(
                                                listener,
                                              );
                                              return true;
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ValueListenableBuilder(
                                                  valueListenable:
                                                      _videoController!,
                                                  builder: (
                                                    context,
                                                    value,
                                                    child,
                                                  ) {
                                                    return _videoController!
                                                            .value
                                                            .isInitialized
                                                        ? AspectRatio(
                                                          aspectRatio:
                                                              _videoController!
                                                                  .value
                                                                  .aspectRatio,
                                                          child: VideoPlayer(
                                                            _videoController!,
                                                          ),
                                                        )
                                                        : Container(
                                                          height: 200,
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                        );
                                                  },
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: IconButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (
                                                                    _,
                                                                  ) => FullScreenVideoView(
                                                                    controller:
                                                                        _videoController!,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.videocam,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: IconButton(
                                                        onPressed: () {
                                                          setStateDialog(() {
                                                            if (_videoController!
                                                                .value
                                                                .isPlaying) {
                                                              _videoController!
                                                                  .pause();
                                                            } else {
                                                              _videoController!
                                                                  .play();
                                                            }
                                                          });
                                                        },
                                                        icon: Icon(
                                                          _videoController!
                                                                  .value
                                                                  .isPlaying
                                                              ? Icons.pause
                                                              : Icons
                                                                  .play_arrow,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: IconButton(
                                                        onPressed: () {
                                                          _videoController
                                                              ?.removeListener(
                                                                listener,
                                                              );
                                                          _videoController!
                                                              .pause();
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        icon: Icon(
                                                          Icons.cancel,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel(AppBannerController appbannerController) {
    return Obx(() {
      if (appbannerVideoController.isLoading.value &&
          appbannerVideoController.bannerVideoList.isEmpty) {
        return _bannerShimmerEffect();
      }

      // Combine images and videos
      List<dynamic> allBannerItems = [];
      // allBannerItems.addAll(appbannerController.bannerImagesList);
      allBannerItems.addAll(appbannerVideoController.bannerVideoList);

      if (allBannerItems.isEmpty) {
        return _bannerShimmerEffect();
      }

      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: CarouselSlider(
          options: CarouselOptions(
            autoPlay:
                _videoController == null || !_videoController!.value.isPlaying,
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            height: 180,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items:
              allBannerItems.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            item.runtimeType.toString().contains('BannerVideo')
                                ? _buildVideoPlayer(item)
                                : CachedNetworkImage(
                                  imageUrl: item.bannerImage,
                                  fit: BoxFit.fitWidth,
                                  width: double.infinity,
                                  placeholder:
                                      (context, url) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  errorWidget:
                                      (context, url, error) => const Center(
                                        child: Icon(
                                          Icons.error,
                                          color: AppColors.error,
                                          size: 50,
                                        ),
                                      ),
                                ),
                      ),
                    );
                  },
                );
              }).toList(),
        ),
      );
    });
  }

  Widget _buildVideoThumbnail(dynamic bannerVideo) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: bannerVideo.thumbnail,
          fit: BoxFit.fitWidth,
          width: double.infinity,
          placeholder:
              (context, url) =>
                  const Center(child: CircularProgressIndicator()),
          errorWidget:
              (context, url, error) => const Center(
                child: Icon(Icons.error, color: AppColors.error, size: 50),
              ),
        ),
        GestureDetector(
          onTap: () async {
            String videoUrl = bannerVideo.bannerVideo
                .replaceAll(r'\/', '/')
                .replaceAll(r'\:', ':');
            setState(() {
              _currentPlayingVideo = bannerVideo;
            });
            await playVideo(videoUrl);
          },
          child: Center(
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(dynamic bannerVideo) {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child:
          _videoController != null &&
                  _videoController!.value.isInitialized &&
                  bannerVideo == _currentPlayingVideo
              ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 180,
                      child: VideoPlayer(_videoController!),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_videoController!.value.isPlaying) {
                                _videoController!.pause();
                              } else {
                                _videoController!.play();
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _videoController!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : GestureDetector(
                onTap: () async {
                  String videoUrl = bannerVideo.bannerVideo
                      .replaceAll(r'\/', '/')
                      .replaceAll(r'\:', ':');
                  setState(() {
                    _currentPlayingVideo = bannerVideo;
                  });
                  await playVideo(videoUrl);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: bannerVideo.thumbnail,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                          placeholder:
                              (context, url) => Container(
                                width: double.infinity,
                                height: 180,
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                width: double.infinity,
                                height: 180,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(
                                    Icons.error,
                                    color: AppColors.error,
                                    size: 50,
                                  ),
                                ),
                              ),
                        ),
                        Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _cardtestimonial(String imagesUrl, VoidCallback press) {
    return GestureDetector(
      onTap: press,
      child: Container(
        height: 97,
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: AppColors.primary.withOpacity(0.1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imagesUrl,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                errorWidget:
                    (context, url, error) => const Center(
                      child: Icon(
                        Icons.error,
                        color: AppColors.error,
                        size: 30,
                      ),
                    ),
              ),
              Center(
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Container(
        height: screenHeight * 0.12,
        width: screenWidth * 0.13,
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: icon,
              fit: BoxFit.cover,
              width: 21,
              height: 25,
              placeholder:
                  (context, url) =>
                      const Center(child: CircularProgressIndicator()),
              errorWidget:
                  (context, url, error) => const Center(
                    child: Icon(Icons.error, color: AppColors.error, size: 20),
                  ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              style: TextStyle(
                color: const Color(0xFF333333),
                fontFamily: GoogleFonts.inter().fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmarterLeadsCard({
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.12,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    //   overflow: TextOverflow.ellipsis,
                    color: textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    color: textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: icon,
                    fit:
                        BoxFit
                            .cover, // Use BoxFit.cover to maintain aspect ratio, or BoxFit.fill to stretch
                    width: 13, // Match container size
                    height: 13, // Match container size
                    placeholder:
                        (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                    errorWidget:
                        (context, url, error) => const Center(
                          child: Icon(
                            Icons.error,
                            color: AppColors.error,
                            size: 13,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _bannerShimmerEffect() {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
      ),
    ),
  );
}

Widget _testiShimmerEffect() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(
        3,
        (index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 97,
            width: 160,
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    ),
  );
}

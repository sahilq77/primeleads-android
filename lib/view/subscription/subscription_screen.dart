import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_leads/model/subscription/get_subscription_response.dart';
import 'package:prime_leads/utility/app_routes.dart';
import 'package:prime_leads/utility/app_utility.dart';
import 'package:prime_leads/view/bottomnavgation/bottom_navigation.dart';
import 'package:prime_leads/controller/bottomnavigation/bottom_navigation_controller.dart';
import 'package:prime_leads/controller/leads/get_leads_controller.dart';
import 'package:prime_leads/controller/profile/profile_controller.dart';
import 'package:prime_leads/controller/subscription/subscription_controller.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:prime_leads/utility/nodatascreen.dart';
import 'package:shimmer/shimmer.dart';

import '../../controller/subscription/set_order_controller.dart';
import '../../controller/subscription_status/subscription_status_controller.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final bottomController = Get.put(BottomNavigationController());
  final controller = Get.put(SubscriptionController());
  final leadsController = Get.put(GetLeadsController());
  final profileController = Get.put(ProfileController());
  final SubscriptionStatusController subsStatusController = Get.put(
    SubscriptionStatusController(),
  );
  int _selectedIndex = -1;

  void _selectCard(int index) {
    setState(() {
      _selectedIndex = index;
      debugPrint(
        '[SubscriptionScreen] Selected package index: $_selectedIndex',
      );
      if (_selectedIndex >= 0 &&
          _selectedIndex < controller.subcriptionsList.value.length) {
        final package = controller.subcriptionsList.value[_selectedIndex];
        debugPrint(
          '[SubscriptionScreen] Selected package: ${package.packageName}, amount: ₹${package.discountAmount}, id: ${package.id}',
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint('[SubscriptionScreen] Initializing SubscriptionScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSubcriptions(context: context);
      subsStatusController.getSubStatus(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Leads Packages',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10),
            child: Divider(
              color: const Color(0xFFDADADA),
              thickness: 2,
              height: 0,
            ),
          ),
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => controller.refreshAllData(context: context),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: SizedBox(
                          height: screenHeight * 0.10,
                          child: Image.asset(AppImages.logoP),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AppImages.lockIcon),
                          SizedBox(width: 5),
                          Text(
                            'Unlock your growth with Prime Leads',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Obx(() {
                        if (controller.isLoading.value &&
                            controller.subcriptionsList.isEmpty) {
                          return ShimmerSubscriptionCard();
                        }
                        if (controller.subcriptionsList.isEmpty) {
                          return NoDataScreen();
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.subcriptionsList.length,
                          itemBuilder: (context, int index) {
                            final package = controller.subcriptionsList[index];
                            return SubscriptionCard(
                              package: package,
                              isSelected: _selectedIndex == index,
                              onTap: () => _selectCard(index),
                            );
                          },
                        );
                      }),
                      SizedBox(height: screenHeight * 0.1),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.white,
                child: ElevatedButton(
                  onPressed:
                      _selectedIndex >= 0 &&
                              _selectedIndex <
                                  controller.subcriptionsList.length
                          ? () {
                            subsStatusController.getSubStatus(context: context);
                            // _navigateToRazorpay();
                            if (subsStatusController.firstBy.value == false) {
                              _navigateToRazorpay();
                            } else if (subsStatusController
                                    .subStatus
                                    .value
                                    .isNotEmpty &&
                                subsStatusController.subStatus.value == "0") {
                              _showThankYouDialog(
                                context,
                                "Your package is not expired",
                                "After it expires, you can buy a new package anytime.",
                              );
                            } else {
                              _navigateToRazorpay();
                            }
                          }
                          : () {
                            debugPrint(
                              '[SubscriptionScreen] Pay Now disabled: No package selected',
                            );
                            Get.snackbar(
                              '',
                              'Please select a subscription plan',
                              backgroundColor: AppColors.secondary,
                              colorText: Colors.white,
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 25),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomBar(),
      ),
    );
  }

  void _navigateToRazorpay() async {
    if (_selectedIndex >= 0 &&
        _selectedIndex < controller.subcriptionsList.length) {
      final package = controller.subcriptionsList[_selectedIndex];
      debugPrint(
        '[SubscriptionScreen] Initiating setOrder for package: ${package.packageName}',
      );
      debugPrint(
        '[SubscriptionScreen] Amount: ₹${package.discountAmount}, Subscription ID: ${package.id}',
      );

      // Create an instance of SetOrderController
      final setOrderController = Get.put(SetOrderController());

      // Call setOrder API
      await setOrderController.setOrder(
        context: context,
        subscriptionid: package.id,
      );

      // Check if setOrder was successful
      if (setOrderController.setOrderList.isNotEmpty &&
          setOrderController.setOrderList.last.subscribtionId == package.id) {
        debugPrint(
          '[SubscriptionScreen] setOrder successful, navigating to RazorpayGateway',
        );
        // Navigate to Razorpay gateway if setOrder is successful
        Get.toNamed(AppRoutes.razorpayGateway, arguments: {'package': package});
      } else {
        debugPrint(
          '[SubscriptionScreen] setOrder failed, not navigating to Razorpay',
        );
        Get.snackbar(
          'Error',
          'Failed to set order. Please try again.',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } else {
      debugPrint('[SubscriptionScreen] Navigation failed: No package selected');
      Get.snackbar(
        '',
        'Please select a subscription plan',
        backgroundColor: AppColors.secondary,
        colorText: Colors.white,
      );
    }
  }

  void _showThankYouDialog(
    BuildContext context,
    String packageName,
    String msg,
  ) {
    debugPrint('[SubscriptionScreen] Showing dialog: $msg');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: SvgPicture.asset(AppImages.notificatioIcon),
                    ),
                    SizedBox(height: 16.0),
                    Obx(
                      () => Text(
                        profileController.packageName.value.isNotEmpty
                            ? profileController.packageName.value
                            : packageName,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 15),
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          debugPrint('[SubscriptionScreen] Closing dialog');
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Close',
                          style: GoogleFonts.inter(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
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
      },
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final Subscription package;
  final bool isSelected;
  final VoidCallback onTap;

  SubscriptionCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<String> tagList = package.tags.split(",");
    debugPrint(
      '[SubscriptionCard] Rendering package: ${package.packageName}, tags: ${package.tags}, amount: ₹${package.discountAmount}',
    );
    Color color =
        package.tags.isNotEmpty ? AppColors.primary : AppColors.primaryTeal;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? color : AppColors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          children: [
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? color : Colors.transparent,
                  border: Border.all(color: isSelected ? color : Colors.grey),
                ),
                child: Icon(
                  Icons.check,
                  color: isSelected ? AppColors.white : Colors.transparent,
                  size: 20,
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (package.tags.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            package.tags,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? color : AppColors.grey,
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: package.image,
                              fit: BoxFit.cover,
                              width: 20,
                              height: 20,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) => const Center(
                                    child: Icon(
                                      Icons.error,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                  ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            package.packageName,
                            style: TextStyle(
                              color: isSelected ? color : AppColors.textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (package.discountAmount.isNotEmpty &&
                          package.discountAmount != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "₹ ${package.amount}",
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "₹ ${package.discountAmount}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? color : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      if (package.discountAmount.isEmpty &&
                          package.discountAmount == "" &&
                          package.discountAmount != null)
                        Text(
                          "₹ ${package.amount}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : AppColors.textDark,
                          ),
                        ),

                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? color.withOpacity(0.1)
                                      : AppColors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                color: isSelected ? color : AppColors.grey,
                                size: 17,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "${package.noOfLeads} Leads",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? color.withOpacity(0.1)
                                      : AppColors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                color: isSelected ? color : AppColors.grey,
                                size: 17,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "${package.validityDays} Days",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          package.bulletPoints.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? color.withOpacity(0.1)
                                            : AppColors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.check,
                                      color:
                                          isSelected ? color : AppColors.grey,
                                      size: 17,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    package.bulletPoints[index],
                                    style: TextStyle(fontSize: 16),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String text;
  final bool isSelected;

  FeatureItem({required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.primaryTeal.withOpacity(0.1)
                      : AppColors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.check,
                color: isSelected ? AppColors.primaryTeal : AppColors.grey,
                size: 17,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class ShimmerSubscriptionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.grey, width: 1),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Stack(
              children: [
                Positioned(
                  right: 20,
                  top: 20,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.grey),
                    ),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Container(
                            width: 100,
                            height: 16,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.grey),
                                    ),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Container(
                                    width: 150,
                                    height: 18,
                                    color: Colors.grey[300],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: 80,
                            height: 16,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: 100,
                            height: 20,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 100,
                                height: 16,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 80,
                                height: 16,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              2,
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      width: 200,
                                      height: 16,
                                      color: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

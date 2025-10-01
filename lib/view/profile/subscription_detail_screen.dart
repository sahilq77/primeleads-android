import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/leads/get_leads_controller.dart';
import '../../controller/profile/profile_controller.dart';
import '../../controller/subscription_status/subscription_status_controller.dart';
import '../../model/profile/get_profile_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  @override
  _SubscriptionDetailScreen createState() => _SubscriptionDetailScreen();
}

class _SubscriptionDetailScreen extends State<SubscriptionDetailScreen> {
  final profileController = Get.put(ProfileController());
  final SubscriptionStatusController subsStatusController = Get.put(
    SubscriptionStatusController(),
  );
  final bottomController = Get.put(BottomNavigationController());

  int _selectedIndex =
      -1; // Initialize to -1 to have no card selected by default
  final leadsController = Get.put(GetLeadsController());

  void _selectCard(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index on tap
    });
  }

  SubscriptionDetail? detail;
  @override
  void initState() {
    super.initState();
    subsStatusController.getSubStatus(context: context);
    final arguments = Get.arguments as SubscriptionDetail;
    if (arguments != null) {
      setState(() {
        detail = arguments as SubscriptionDetail?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Subscription Detail',
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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SubscriptionCard(
                package: detail!,
                controller: subsStatusController,
              ),

              SizedBox(height: 10),
              SizedBox(
                child:
                    profileController.userProfileList.first.isSelectedCities ==
                            "0"
                        ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
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
                                        .transactioId,
                              },
                            );
                          },
                          child: Text("Please select cities to get leads"),
                        )
                        : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to show the Thank You dialog

class SubscriptionCard extends StatelessWidget {
  SubscriptionDetail package;
  SubscriptionStatusController controller;

  SubscriptionCard({required this.package, required this.controller});

  @override
  Widget build(BuildContext context) {
    // List<String> tagList = package.tags.split(",");
    //print(package.tags);
    Color color =
        package.tags!.isNotEmpty ? AppColors.primary : AppColors.primaryTeal;
    return GestureDetector(
      onTap: () {}, // Trigger the callback on tap
      child: Card(
        elevation: 2, // Higher elevation for selected card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: AppColors.grey, // Border for selected card
            width: 1,
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          children: [
            Obx(
              () => Positioned(
                right: 5,
                top: 20,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()..scale(1.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          controller.subStatus.value.isNotEmpty &&
                                  controller.subStatus.value == "0"
                              ? [
                                AppColors.success.withOpacity(0.9),
                                AppColors.success.withOpacity(0.7),
                              ]
                              : [
                                Colors.red.withOpacity(0.9),
                                Colors.red.withOpacity(0.7),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            controller.subStatus.value.isNotEmpty &&
                                    controller.subStatus.value == "0"
                                ? AppColors.success.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.subStatus.value.isNotEmpty &&
                                controller.subStatus.value == "0"
                            ? Icons.verified_rounded
                            : Icons.cancel_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.subStatus.value.isNotEmpty &&
                                controller.subStatus.value == "0"
                            ? "Active"
                            : "Expired",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (package.tags!.isNotEmpty)
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
                            "${package.tags}",
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
                          // Container(
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     border: Border.all(
                          //       color: isSelected ? color : AppColors.grey,
                          //     ),
                          //   ),
                          //   child: CachedNetworkImage(
                          //     imageUrl: package.image,
                          //     fit: BoxFit.cover,
                          //     width: 20,
                          //     height: 20,
                          //     placeholder:
                          //         (context, url) => const Center(
                          //           child: CircularProgressIndicator(),
                          //         ),
                          //     errorWidget:
                          //         (context, url, error) => const Center(
                          //           child: Icon(
                          //             Icons.error,
                          //             color: AppColors.error,
                          //             size: 20,
                          //           ),
                          //         ),
                          //   ),
                          // ),
                          SizedBox(width: 4),
                          Text(
                            package.packageName.toString(),
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // SizedBox(height: 8),
                      // Text(
                      //   "₹ ${package.amount}",
                      //   style: TextStyle(
                      //     decoration: TextDecoration.lineThrough,
                      //     color: AppColors.grey,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      // Text(
                      //   "₹ ${package.discountAmount}",
                      //   style: TextStyle(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.bold,
                      //     color: isSelected ? color : AppColors.textDark,
                      //   ),
                      // ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                color: AppColors.grey,
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
                              color: AppColors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                color: AppColors.grey,
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
                                    color: color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.check,
                                      color: AppColors.grey,
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
                          // Simulate bullet points (assuming 2-3 items)
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

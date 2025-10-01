import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_leads/utility/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/notification/notification_controller.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_images.dart';
import '../../utility/nodatascreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final controller = Get.put(NotificationController());

  String _getTimeAgo(DateTime createdOn) {
    final now = DateTime.now();
    final difference = now.difference(createdOn);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes == 1) {
      return "1 min ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours == 1) {
      return "1 hr ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hrs ago";
    } else if (difference.inDays == 1) {
      return "1 day ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore.value &&
          controller.hasMoreData.value) {
        controller.loadMoreResults(context: context);
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.0,
        title: Text(
          'Notification',
          // style: GoogleFonts.poppins(
          //   color: AppColors.textDark,
          //   fontSize: 18,
          //   fontWeight: FontWeight.bold,
          // ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Divider(color: Color(0xFFDADADA), thickness: 2, height: 0),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshleadsList(context: context),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: _buildShimmerItem());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            itemCount:
                controller.notiList.isEmpty
                    ? 1
                    : controller.notiList.length +
                        (controller.hasMoreData.value ||
                                controller.isLoadingMore.value
                            ? 1
                            : 0),
            itemBuilder: (context, int index) {
              if (controller.notiList.isEmpty) {
                return NoDataScreen();
              }

              if (index == controller.notiList.length) {
                return controller.isLoadingMore.value
                    ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No more data',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.defaultblack,
                          ),
                        ),
                      ),
                    );
              }

              var noti = controller.notiList[index];
              return Column(
                children: [
                  ListTile(
                    onTap: () {
                      Get.toNamed(AppRoutes.notifcationDetail, arguments: noti);
                    },
                    leading: Container(
                      height: 40,
                      width: 40,
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTeal, // AppColors.primaryTeal
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppImages
                              .notificatioIcon, // Replace with your asset path
                          color: Colors.white,
                          height: 25,
                          width: 25,
                        ),
                      ),
                    ),
                    title: Text(
                      noti.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF3B4453),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      _getTimeAgo(noti.createdOn),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const Divider(thickness: 0.5),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (ctx, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.white,
                ),
                subtitle: Container(
                  height: 12,
                  width: 100,
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 8),
                ),
                trailing: Container(height: 12, width: 50, color: Colors.white),
              ),
              const Divider(thickness: 0.5),
            ],
          ),
        );
      },
    );
  }
}

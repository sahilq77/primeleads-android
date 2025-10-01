import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/notification/notification_controller.dart';
import '../../model/notification/get_notification_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_images.dart';
import '../../utility/nodatascreen.dart';

class NotificationDetailScreen extends StatefulWidget {
  const NotificationDetailScreen({super.key});

  @override
  _NotificationDetailScreenState createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  final controller = Get.put(NotificationController());
  NotificationData? notiData;
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
  void initState() {
    // TODO: implement initState
    super.initState();
    notiData = Get.arguments as NotificationData;
  }

  @override
  Widget build(BuildContext context) {
    print(notiData!.notificationImage);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.0,
        title: Text(
          'Notification Detail',
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
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Color(0xFFDADADA), width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child:
                          notiData!.notificationImage != null
                              ? Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTeal.withOpacity(0.1),
                                  border: Border.all(
                                    color: const Color(0xFFDADADA),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: notiData!.notificationImage,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) =>
                                          Center(child: _buildShimmerItem()),
                                  errorWidget:
                                      (context, url, error) => Center(
                                        child: const Text(
                                          "Failed to load image!",
                                        ),
                                      ),
                                ),
                              )
                              : SizedBox(),
                    ),

                    const SizedBox(height: 12.0),
                    Text(
                      notiData!.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF4A4A4A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      notiData!.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF4A4A4A),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      _getTimeAgo(notiData!.createdOn),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF4A4A4A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            const SizedBox(height: 12.0),
            Container(height: 16, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8.0),
            Container(height: 12, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8.0),
            Container(height: 12, width: 100, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

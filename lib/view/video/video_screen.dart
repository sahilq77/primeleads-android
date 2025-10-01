import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_leads/controller/bottomnavigation/bottom_navigation_controller.dart';
import 'package:prime_leads/controller/video/video_controller.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:prime_leads/utility/app_routes.dart';
import 'package:prime_leads/utility/youtube_utility.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart'; // Add url_launcher import

import '../../utility/nodatascreen.dart';
import '../../utility/widgets/video_list_shimmer.dart';

import '../bottomnavgation/bottom_navigation.dart' show CustomBottomBar;

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final bottomController = Get.put(BottomNavigationController());
  final videoController = Get.put(VideoController());
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    videoController.fetchVideos(context: context);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        log(
          'Checking scroll position: pixels=${_scrollController.position.pixels}, maxScrollExtent=${_scrollController.position.maxScrollExtent}, threshold=${_scrollController.position.maxScrollExtent - 200}',
        );
        if (!videoController.isLoading.value &&
            !videoController.isFetchingMore.value &&
            videoController.hasMore.value) {
          log(
            'Fetching more videos with offset: ${videoController.offset.value}',
          );
          videoController.fetchVideos(context: context, isPagination: true);
        }
      }
    });
  }

  // Function to open WhatsApp
  Future<void> _openWhatsApp() async {
    // Temporary WhatsApp group invite link or phone number
    const String whatsappUrl =
        'https://chat.whatsapp.com/GbSgcbRongJGlhUgX5yfSL?mode=ac_t'; // Replace with actual link later
    // Alternatively, use a phone number: 'https://wa.me/1234567890?text=Hello%20I%20want%20to%20join%20the%20community'

    final Uri url = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open WhatsApp. Please ensure it is installed.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
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
          title: Text('Watch Video'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(10),
            child: Divider(color: Color(0xFFDADADA), thickness: 2, height: 0),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Learn. Apply. Grow Your Business',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          SvgPicture.asset(
                            AppImages.whatsappgreenlIcon,
                            height: 35,
                            width: 35,
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _openWhatsApp, // Call _openWhatsApp on tap
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF44C554),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Center(
                                child: Text(
                                  'Join Now',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReadMoreText(
                              "Join Our WhatsApp Community",
                              trimMode: TrimMode.Line,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              trimLines: 1,
                              colorClickableText: Colors.pink,
                              trimCollapsedText: 'Learn more',

                              trimExpandedText: 'Show less',

                              moreStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Text(
                            //   'Join Our WhatsApp Community',
                            //   style: GoogleFonts.poppins(
                            //     fontSize: 15,
                            //     fontWeight: FontWeight.w600,
                            //   ),
                            // ),
                            const SizedBox(height: 5),
                            Text(
                              'Connect with 1000+ active coaches.\nLearn, share,& grow together.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              Expanded(
                child: Obx(() {
                  if (videoController.isLoading.value &&
                      videoController.videoList.isEmpty) {
                    return const VideoListShimmer();
                  } else if (videoController.videoList.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await videoController.refreshVideos(context);
                      },
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: const NoDataScreen(),
                      ),
                    );
                  } else {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await videoController.refreshVideos(context);
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            videoController.videoList.length +
                            (videoController.isFetchingMore.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == videoController.videoList.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final video = videoController.videoList[index];
                          final thumbnailUrl =
                              YouTubeUtility.getYouTubeThumbnail(
                                video.videoLink,
                              ) ??
                              'https://via.placeholder.com/150';
                          log(thumbnailUrl);
                          return GestureDetector(
                            onTap: () {
                              if (Get.currentRoute != AppRoutes.videoDetail) {
                                Get.toNamed(
                                  AppRoutes.videoDetail,
                                  arguments: video,
                                );
                              }
                            },
                            child: Card(
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: CachedNetworkImage(
                                        imageUrl: thumbnailUrl,
                                        width: 150,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (context, url) =>
                                                Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        errorWidget:
                                            (context, url, error) =>
                                                SvgPicture.asset(
                                                  AppImages.defaultVideo,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            video.title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              color: AppColors.defaultblack,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ReadMoreText(
                                            video.description,
                                            trimMode: TrimMode.Line,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                            ),
                                            trimLines: 2,
                                            colorClickableText: Colors.pink,
                                            trimCollapsedText: 'Learn more',
                                            trimExpandedText: 'Show less',
                                            moreStyle: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Text(
                                            'Date: ${video.date} | Time: ${video.time}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.textDark,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }
}

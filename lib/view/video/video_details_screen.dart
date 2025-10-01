import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for SystemChrome
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_leads/model/video/get_training_video_response.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/view/bottomnavgation/bottom_navigation.dart';
import 'package:readmore/readmore.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoDetailsScreen extends StatefulWidget {
  const VideoDetailsScreen({super.key});

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  late YoutubePlayerController _controller;
  late VideoData video;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    video = Get.arguments as VideoData;

    // Extract YouTube video ID
    String? videoId = _getYoutubeVideoId(video.videoLink);
    if (videoId == null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: 'invalid',
        params: const YoutubePlayerParams(
          mute: false,
          showControls: false,
          showFullscreenButton: false,
          loop: false,
          enableCaption: false,
        ),
      );
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid YouTube URL. Please check the video link.';
      });
      return;
    }

    // Initialize YouTube player controller
    try {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        params: const YoutubePlayerParams(
          mute: false,
          showControls: true,
          showFullscreenButton: false,
          loop: false,
          enableCaption: true,
          captionLanguage: 'en',
          playsInline: true,
        ),
      );

      // Listen for player state changes to detect play button click
      _controller.listen((event) {
        if (event.playerState == PlayerState.playing) {
          // Video is playing, set to landscape
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else if (event.playerState == PlayerState.paused ||
            event.playerState == PlayerState.ended) {
          // Video is paused or ended, restore to portrait
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }
      });

      // Listen for fullscreen toggle
      _controller.onFullscreenChange = (isFullscreen) {
        if (isFullscreen) {
          // Force landscape in fullscreen
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else {
          // Restore portrait when exiting fullscreen
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }
      };

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: 'invalid',
        params: const YoutubePlayerParams(
          mute: false,
          showControls: false,
          showFullscreenButton: false,
          loop: false,
          enableCaption: false,
        ),
      );
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error initializing player: $e';
      });
    }
  }

  // Utility to extract YouTube video ID from URL
  String? _getYoutubeVideoId(String url) {
    try {
      if (url.contains('youtube.com')) {
        return Uri.parse(url).queryParameters['v'];
      } else if (url.contains('youtu.be')) {
        return url.split('/').last.split('?').first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    // Reset orientation to default (portrait) when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: false,
            title: Text(
              'Watch Video Detail',
              style: GoogleFonts.poppins(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                    side: const BorderSide(
                      color: Color(0xFFDADADA),
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFDADADA),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 200.0,
                              child:
                                  _isLoading
                                      ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                      : _errorMessage != null
                                      ? Center(
                                        child: Text(
                                          _errorMessage!,
                                          style: GoogleFonts.poppins(
                                            color: Colors.red,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                      : player,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          video.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        ReadMoreText(
                          video.description,
                          trimMode: TrimMode.Line,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4A4A4A),
                          ),
                          trimLines: 3,
                          colorClickableText: Colors.pink,
                          trimCollapsedText: 'Read more',
                          trimExpandedText: 'Show less',
                          moreStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Date: ',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: '${video.date.replaceAll('-', '/')} | ',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF757575),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: 'Time: ',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: video.time,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF757575),
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
              ),
            ),
          ),
          // bottomNavigationBar: const CustomBottomBar(),
        );
      },
    );
  }
}

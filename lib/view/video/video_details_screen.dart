import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_leads/model/video/get_training_video_response.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:readmore/readmore.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _hasPlaybackError = false;

  @override
  void initState() {
    super.initState();
    video = Get.arguments as VideoData;

    String? videoId = _getYoutubeVideoId(video.videoLink);
    if (videoId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid YouTube URL. Please check the video link.';
      });
      return;
    }

    try {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        params: const YoutubePlayerParams(
          mute: false,
          showControls: true,
          showFullscreenButton: true,
          loop: false,
          enableCaption: false,
          captionLanguage: 'en',
          playsInline: false, // Changed to false to allow fullscreen
          strictRelatedVideos: true,
          origin: 'https://www.youtube-nocookie.com',
        ),
      );

      // Listen for errors
      _controller.listen((event) {
        // Check for playback errors
        if (event.hasError) {
          setState(() {
            _hasPlaybackError = true;
            _errorMessage = 'This video cannot be played in embedded mode.';
          });
        }

        if (event.playerState == PlayerState.playing) {
          setState(() {
            _hasPlaybackError = false;
          });
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else if (event.playerState == PlayerState.paused ||
            event.playerState == PlayerState.ended) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }
      });

      _controller.onFullscreenChange = (isFullscreen) {
        if (isFullscreen) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else {
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
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error initializing player: $e';
      });
    }
  }

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

  // Open video in YouTube app or browser
  Future<void> _openInYouTube() async {
    final Uri youtubeUrl = Uri.parse(video.videoLink);
    if (await canLaunchUrl(youtubeUrl)) {
      await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open YouTube')));
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                                      : _errorMessage != null ||
                                          _hasPlaybackError
                                      ? _buildErrorWidget()
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
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _errorMessage ?? 'Video cannot be played in embedded mode',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openInYouTube,
              icon: const Icon(Icons.open_in_new),
              label: Text(
                'Watch on YouTube',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

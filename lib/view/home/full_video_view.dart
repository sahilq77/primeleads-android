import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoView extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenVideoView({Key? key, required this.controller})
    : super(key: key);

  @override
  State<FullScreenVideoView> createState() => _FullScreenVideoViewState();
}

class _FullScreenVideoViewState extends State<FullScreenVideoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child:
                  widget.controller.value.isInitialized
                      ? AspectRatio(
                        aspectRatio: widget.controller.value.aspectRatio,
                        child: VideoPlayer(widget.controller),
                      )
                      : CircularProgressIndicator(),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: IconButton(
                icon: Icon(
                  widget.controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  setState(() {
                    widget.controller.value.isPlaying
                        ? widget.controller.pause()
                        : widget.controller.play();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File video;

  const VideoPlayerWidget({super.key, required this.video});

  static VideoPlayerWidgetState of(BuildContext context) {
    final VideoPlayerWidgetState? result =
        context.findAncestorStateOfType<VideoPlayerWidgetState>();
    return result!;
  }

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.video)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          )
        : const Center(child: CircularProgressIndicator());
  }

  // Metoda do przewijania w przód o określony czas
  void rewind(Duration duration) {
      controller.seekTo(controller.value.position - duration);
  }

  void fastForward(Duration duration) {

      controller.seekTo(controller.value.position + duration);

  }

  void togglePlay() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
  }

  bool get isPlaying => controller.value.isPlaying;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

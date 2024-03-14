import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File video;
  final Function() onVideoEnd;

  const VideoPlayerWidget(
      {super.key, required this.video, required this.onVideoEnd});

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
    controller.addListener(_videoListener);
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

  void rewind10sec(Duration duration) {
    controller.seekTo(controller.value.position - duration);
  }

  void rewindToBeginningAndPause() {
    controller.seekTo(Duration.zero);
    controller.pause();
  }

  void fastForward10sec(Duration duration) {
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

  void _videoListener() {
    if (!controller.value.isPlaying &&
        controller.value.position == controller.value.duration) {
      widget.onVideoEnd();
    }
  }

  bool get isPlaying => controller.value.isPlaying;

  @override
  void dispose() {
    controller.dispose();
    controller.removeListener(_videoListener);
    super.dispose();
  }
}

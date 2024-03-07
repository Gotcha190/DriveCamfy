import 'dart:io';
import 'package:drive_camfy/widgets/options_popup_menu_button.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:drive_camfy/widgets/video_player_widget.dart';

class FullscreenVideoView extends StatefulWidget {
  final File video;

  const FullscreenVideoView({super.key, required this.video});

  @override
  State<FullscreenVideoView> createState() => _FullscreenVideoViewState();
}

class _FullscreenVideoViewState extends State<FullscreenVideoView> {
  final GlobalKey<VideoPlayerWidgetState> _videoPlayerKey = GlobalKey();
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _isPlaying = false;
  }

  @override
  Widget build(BuildContext context) {
    String fileName = path.basename(widget.video.path);
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: VideoPlayerWidget(key: _videoPlayerKey, video: widget.video),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 50),
              IconButton(
                onPressed: () {
                  _videoPlayerKey.currentState
                      ?.rewind(const Duration(seconds: 10));
                },
                icon: const Icon(Icons.replay_10),
                iconSize: 40,
              ),
              IconButton(
                onPressed: () {
                  _videoPlayerKey.currentState?.togglePlay();
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                iconSize: 40,
              ),
              IconButton(
                onPressed: () {
                  _videoPlayerKey.currentState
                      ?.fastForward(const Duration(seconds: 10));
                },
                icon: const Icon(Icons.forward_10),
                iconSize: 40,
              ),
              OptionsPopupMenuButton(video: widget.video),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:drive_camfy/widgets/options_popup_menu_button.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:drive_camfy/widgets/video_player_widget.dart';

class FullscreenVideoView extends StatefulWidget {
  final List<File> videos;
  final int vidIndex;
  final Function() onDelete;

  const FullscreenVideoView({
    super.key,
    required this.videos,
    required this.onDelete,
    required this.vidIndex,
  });

  @override
  State<FullscreenVideoView> createState() => _FullscreenVideoViewState();
}

class _FullscreenVideoViewState extends State<FullscreenVideoView> {
  late bool _isPlaying;
  late int _currentIndex;
  late PageController _pageController;
  late List<GlobalKey<VideoPlayerWidgetState>> _videoPlayerKeys;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.vidIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _isPlaying = false;
    _videoPlayerKeys = List.generate(widget.videos.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(path.basename(widget.videos[_currentIndex].path)),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.videos.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _isPlaying = false;
              });
            },
            itemBuilder: (context, index) {
              return VideoPlayerWidget(
                key: _videoPlayerKeys[index],
                video: widget.videos[index],
                onVideoEnd: () {
                  setState(() {
                    _isPlaying = false; // Update isPlaying state
                    _videoPlayerKeys[_currentIndex]
                        .currentState
                        ?.rewindToBeginningAndPause();
                  });
                },
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 50),
                  IconButton(
                    onPressed: () {
                      _videoPlayerKeys[_currentIndex]
                          .currentState
                          ?.rewind10sec(const Duration(seconds: 10));
                    },
                    icon: const Icon(Icons.replay_10),
                    iconSize: 40,
                  ),
                  IconButton(
                    onPressed: () {
                      _videoPlayerKeys[_currentIndex]
                          .currentState
                          ?.togglePlay();
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
                      _videoPlayerKeys[_currentIndex]
                          .currentState
                          ?.fastForward10sec(const Duration(seconds: 10));
                    },
                    icon: const Icon(Icons.forward_10),
                    iconSize: 40,
                  ),
                  OptionsPopupMenuButton(
                    file: widget.videos[_currentIndex],
                    onDelete: widget.onDelete,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

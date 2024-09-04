import 'dart:io';
import 'package:drive_camfy/utils/media_tools/file_selection_manager.dart';
import 'package:drive_camfy/widgets/options_popup_menu_buttons.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class FullscreenImageView extends StatefulWidget {
  final List<File> images;
  final int imgIndex;
  final Function() onDelete;

  const FullscreenImageView({
    super.key,
    required this.images,
    required this.imgIndex,
    required this.onDelete,
  });

  @override
  State<FullscreenImageView> createState() => _FullscreenImageViewState();
}

class _FullscreenImageViewState extends State<FullscreenImageView> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.imgIndex;
    _pageController = PageController(initialPage: _currentIndex);
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
        title: Text(path.basename(widget.images[_currentIndex].path)),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.file(widget.images[index]);
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
                      if (_currentIndex > 0) {
                        _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      }
                    },
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 40,
                  ),
                  IconButton(
                    onPressed: () {
                      if (_currentIndex < widget.images.length - 1) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      }
                    },
                    icon: const Icon(Icons.chevron_right),
                    iconSize: 40,
                  ),
                  OptionsPopupMenuButton(
                    files: [SelectableFile(widget.images[_currentIndex])],
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

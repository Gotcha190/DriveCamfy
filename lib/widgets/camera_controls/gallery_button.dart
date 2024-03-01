import 'dart:io';
import 'package:drive_camfy/utils/media_tools/gallery_helper.dart';
import 'package:drive_camfy/widgets/camera_controls/concave_button.dart';
import 'package:flutter/material.dart';

class GalleryButton extends StatelessWidget {
  const GalleryButton({super.key});

  Future<List<File>> _getImages() async {
    return await GalleryHelper.getImages();
  }

  Future<List<File>> _getVideos() async {
    return await GalleryHelper.getVideos();
  }

  Future<void> _openGalleryScreen(BuildContext context) async {
    final List<File> images = await _getImages();
    final List<File> videos = await _getVideos();
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamed('/gallery', arguments: {'images': images, 'videos': videos});
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-80, 0),
      child: ConcaveButton(
        width: 60,
        height: 100,
        arcHeight: 12,
        isRightButton: false,
        onPressed: () {
          _openGalleryScreen(context);
        },
        child: const Icon(
          Icons.filter,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }
}

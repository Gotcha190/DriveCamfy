import 'dart:io';
import 'package:flutter/material.dart';
import 'package:drive_camfy/views/fullscreen_image_view.dart';

class GalleryView extends StatelessWidget {
  final List<File> images;
  final List<File> videos;

  const GalleryView({Key? key, required this.images, required this.videos})
      : super(key: key);

  Future<void> _openFullScreenImage(BuildContext context, File file) async {
    if (images.contains(file)) {
      await Navigator.of(context)
          .pushNamed('/fullscreenImage', arguments: file);
    } else if (videos.contains(file)) {
      await Navigator.of(context)
          .pushNamed('/fullscreenVideo', arguments: file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gallery'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Videos'),
              Tab(text: 'Pictures'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGridView(context, videos),
            _buildGridView(context, images),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(BuildContext context, List<File> files) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: files.length,
      itemBuilder: (BuildContext context, int index) {
        final file = files[index];
        return GestureDetector(
          onTap: () {
            _openFullScreenImage(context, file);
          },
          child: Image.file(
            file,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

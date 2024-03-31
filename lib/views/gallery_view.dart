import 'dart:io';
import 'dart:typed_data';
import 'package:drive_camfy/utils/media_tools/gallery_helper.dart';
import 'package:drive_camfy/utils/media_tools/thumbnail_generator.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({super.key});

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late List<File> images = [];
  late List<File> videos = [];
  late List<File> emergency = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    images = await GalleryHelper.getImages();
    videos = await GalleryHelper.getVideos();
    emergency = await GalleryHelper.getEmergency();
    setState(() {});
  }

  Future<void> _openFullScreen(BuildContext context, File file) async {
    String routeName =
        images.contains(file) ? '/fullscreenImage' : '/fullscreenVideo';
    List<File> whichFile = images.contains(file)
        ? images
        : emergency.contains(file)
            ? emergency
            : videos;
    int index = whichFile.indexOf(file);
    await Navigator.of(context).pushNamed(
      routeName,
      arguments: {
        'file': whichFile,
        'index': index,
        'onDelete': _loadFiles,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gallery'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Videos'),
              Tab(
                child: Text(
                  'Emergency',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              Tab(text: 'Pictures'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            videos.isEmpty
                ? const Center(
                    child: Text(
                      "No video created yet",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : _buildGridView(context, videos),
            emergency.isEmpty
                ? const Center(
                    child: Text(
                      "No emergency video created yet",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : _buildGridView(context, emergency),
            images.isEmpty
                ? const Center(
                    child: Text(
                      "No photo created yet",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : _buildGridView(context, images),
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
        return VisibilityDetector(
          key: Key(index.toString()),
          onVisibilityChanged: (VisibilityInfo info) {
            if (info.visibleFraction == 1 && file.path.endsWith('.mp4')) {
              ThumbnailsGenerator.generateThumbnail(file);
            }
          },
          child: GestureDetector(
            onTap: () {
              _openFullScreen(context, file);
            },
            child: _buildMediaWidget(context, file),
          ),
        );
      },
    );
  }

  Widget _buildMediaWidget(BuildContext context, File file) {
    return file.path.endsWith('.mp4')
        ? FutureBuilder<Uint8List?>(
            future: ThumbnailsGenerator.generateThumbnail(file),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Icon(Icons.error);
              } else {
                return snapshot.hasData
                    ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                    : const SizedBox(); // Placeholder for non-visible items
              }
            },
          )
        : Image.file(file, fit: BoxFit.cover);
  }
}

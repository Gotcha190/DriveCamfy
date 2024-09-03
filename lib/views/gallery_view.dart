import 'dart:io';
import 'dart:typed_data';
import 'package:drive_camfy/utils/media_tools/gallery_helper.dart';
import 'package:drive_camfy/utils/media_tools/thumbnail_generator.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:drive_camfy/utils/media_tools/selectable_file.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({super.key});

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView>
    with SingleTickerProviderStateMixin {
  List<SelectableFile> selectableImages = [];
  List<SelectableFile> selectableVideos = [];
  List<SelectableFile> selectableEmergency = [];

  final ValueNotifier<Set<SelectableFile>> _selectedFilesNotifier =
      ValueNotifier<Set<SelectableFile>>({});

  final ValueNotifier<bool> _anySelectedNotifier = ValueNotifier<bool>(false);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _selectedFilesNotifier.dispose();
    _anySelectedNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    List<File> images = await GalleryHelper.getImages();
    List<File> videos = await GalleryHelper.getVideos();
    List<File> emergency = await GalleryHelper.getEmergency();

    setState(() {
      selectableImages = images.map((file) => SelectableFile(file)).toList();
      selectableVideos = videos.map((file) => SelectableFile(file)).toList();
      selectableEmergency =
          emergency.map((file) => SelectableFile(file)).toList();
    });

    // Update the notifier
    _selectedFilesNotifier.value = {};
  }

  void _toggleFileSelection(SelectableFile file) {
    file.toggleSelection();
    final selectedFiles = _selectedFilesNotifier.value;

    if (file.isSelectedNotifier.value) {
      selectedFiles.add(file);
    } else {
      selectedFiles.remove(file);
    }

    _selectedFilesNotifier.value = Set.from(selectedFiles);

    // Update _anySelectedNotifier
    _anySelectedNotifier.value = selectedFiles.isNotEmpty;
  }

  void _toggleAllFilesSelection(List<SelectableFile> currentTabFiles) {
    final selectedFiles = _selectedFilesNotifier.value;
    final areAllSelected = _areAllFilesSelected(currentTabFiles);

    for (var file in currentTabFiles) {
      file.setSelection(!areAllSelected);
    }

    if (areAllSelected) {
      selectedFiles.removeAll(currentTabFiles);
    } else {
      selectedFiles.addAll(currentTabFiles);
    }

    _selectedFilesNotifier.value = Set.from(selectedFiles);

    // Update _anySelectedNotifier
    _anySelectedNotifier.value = selectedFiles.isNotEmpty;
  }

  bool _areAllFilesSelected(List<SelectableFile> currentFiles) {
    return currentFiles
        .every((file) => _selectedFilesNotifier.value.contains(file));
  }

  void _openFullScreen(BuildContext context, SelectableFile file) async {
    String routeName = file.file.path.endsWith('.mp4')
        ? '/fullscreenVideo'
        : '/fullscreenImage';

    // Wybieramy odpowiednią listę w zależności od typu pliku
    List<File> filesToSend;
    if (file.file.path.endsWith('.mp4')) {
      filesToSend = selectableVideos.map((f) => f.file).toList();
    } else if (selectableEmergency.contains(file)) {
      filesToSend = selectableEmergency.map((f) => f.file).toList();
    } else {
      filesToSend = selectableImages.map((f) => f.file).toList();
    }

    int index = filesToSend.indexOf(file.file);

    await Navigator.of(context).pushNamed(
      routeName,
      arguments: {
        'file': filesToSend,
        'index': index,
        'onDelete': _loadFiles,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _anySelectedNotifier,
      builder: (context, anySelected, _) {
        return Scaffold(
          appBar: AppBar(
            title: anySelected
                ? Row(
                    children: [
                      ValueListenableBuilder<Set<SelectableFile>>(
                        valueListenable: _selectedFilesNotifier,
                        builder: (context, selectedFiles, _) {
                          return IconButton(
                            icon: Icon(
                              _areAllFilesSelected(_getCurrentFiles())
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: _areAllFilesSelected(_getCurrentFiles())
                                  ? Colors.blueAccent
                                  : Colors.black,
                            ),
                            onPressed: () {
                              _toggleAllFilesSelection(_getCurrentFiles());
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<Set<SelectableFile>>(
                        valueListenable: _selectedFilesNotifier,
                        builder: (context, selectedFiles, _) {
                          return Text("Selected: ${selectedFiles.length}");
                        },
                      ),
                    ],
                  )
                : const Text('Gallery'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Videos'),
                Tab(
                  child: Text('Emergency', style: TextStyle(color: Colors.red)),
                ),
                Tab(text: 'Pictures'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildGridView(context, selectableVideos),
              _buildGridView(context, selectableEmergency),
              _buildGridView(context, selectableImages),
            ],
          ),
        );
      },
    );
  }

  List<SelectableFile> _getCurrentFiles() {
    int currentIndex = _tabController.index;
    if (currentIndex == 0) return selectableVideos;
    if (currentIndex == 1) return selectableEmergency;
    return selectableImages;
  }

  Widget _buildGridView(BuildContext context, List<SelectableFile> files) {
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
            if (_selectedFilesNotifier.value.isNotEmpty) {
              _toggleFileSelection(file);
            } else {
              _openFullScreen(context, file);
            }
          },
          onLongPress: () {
            if (_selectedFilesNotifier.value.isEmpty) {
              _toggleFileSelection(file);
            }
          },
          child: _buildMediaWidget(context, file),
        );
      },
    );
  }

  Widget _buildMediaWidget(BuildContext context, SelectableFile file) {
    return ValueListenableBuilder<bool>(
      valueListenable: file.isSelectedNotifier,
      builder: (context, isSelected, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: file.file.path.endsWith('.mp4')
                  ? FutureBuilder<Uint8List?>(
                      future: ThumbnailsGenerator.generateThumbnail(file.file),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error);
                        } else {
                          return snapshot.hasData
                              ? Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : const SizedBox();
                        }
                      },
                    )
                  : Image.file(
                      file.file,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
            ),
            if (isSelected)
              const Positioned(
                top: 8,
                left: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.blueAccent,
                  size: 24,
                ),
              ),
            if (!isSelected && _selectedFilesNotifier.value.isNotEmpty)
              const Positioned(
                top: 8,
                left: 8,
                child: Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
          ],
        );
      },
    );
  }
}

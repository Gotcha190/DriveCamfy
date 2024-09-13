import 'dart:io';
import 'package:drive_camfy/utils/media_tools/file_selection_manager.dart';
import 'package:drive_camfy/widgets/options_popup_menu_buttons.dart';
import 'package:flutter/material.dart';
import 'package:drive_camfy/utils/media_tools/gallery_helper.dart';
import 'package:drive_camfy/widgets/gallery_media_widget.dart';

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

  late final FileSelectionManager _fileSelectionManager;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fileSelectionManager = FileSelectionManager();
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fileSelectionManager.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    try {
      final fileLists = await GalleryHelper.loadFiles();
      setState(() {
        selectableImages = fileLists.images;
        selectableVideos = fileLists.videos;
        selectableEmergency = fileLists.emergency;
      });
      _fileSelectionManager.resetSelection();
    } catch (e) {
      if(!mounted)return;
      Navigator.pushNamed(
        context,
        '/error',
        arguments: {
          'title': 'Błąd ładowania plików',
          'message': 'Wystąpił błąd podczas ładowania plików: $e',
        },
      );
    }
  }

  void _toggleFileSelection(SelectableFile file, {bool? selectAll}) {
    _fileSelectionManager.toggleFileSelection(file, _getCurrentFiles(),
        selectAll: selectAll);
  }

  bool get _areAllFilesSelected {
    return _fileSelectionManager.areAllFilesSelected(_getCurrentFiles());
  }

  void _openFullScreen(BuildContext context, SelectableFile file) async {
    String routeName = file.file.path.endsWith('.mp4')
        ? '/fullscreenVideo'
        : '/fullscreenImage';
    List<File> filesToSend = _getFilesToSend(file);

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

  List<File> _getFilesToSend(SelectableFile file) {
    // Check if the file is in the emergency list first
    if (selectableEmergency.contains(file)) {
      return selectableEmergency.map((f) => f.file).toList();
    }
    // Check if the file is a video based on its extension
    if (file.file.path.endsWith('.mp4')) {
      return selectableVideos.map((f) => f.file).toList();
    }
    // If it's neither an emergency nor a video, return image files
    return selectableImages.map((f) => f.file).toList();
  }

  void _handleFloatingActionButtonPress() {
    setState(() {
      _fileSelectionManager.resetSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _fileSelectionManager.anySelectedNotifier,
      builder: (context, anySelected, _) {
        return Scaffold(
          appBar: AppBar(
            title: _buildAppBarTitle(anySelected),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Videos'),
                Tab(
                    child:
                        Text('Emergency', style: TextStyle(color: Colors.red))),
                Tab(text: 'Pictures'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              selectableVideos.isEmpty
                  ? const Center(child: Text("No video recordings"))
                  : _buildGridView(context, selectableVideos),
              selectableEmergency.isEmpty
                  ? const Center(child: Text("No emergency recordings"))
                  : _buildGridView(context, selectableEmergency),
              selectableImages.isEmpty
                  ? const Center(child: Text("No photos"))
                  : _buildGridView(context, selectableImages),
            ],
          ),
          floatingActionButton: anySelected
              ? ValueListenableBuilder<Set<SelectableFile>>(
                  valueListenable: _fileSelectionManager.selectedFilesNotifier,
                  builder: (context, selectedFiles, _) {
                    return OptionsFloatingActionButton(
                      files: _fileSelectionManager.selectedFilesNotifier.value
                          .toList(),
                      onDelete: _handleFloatingActionButtonPress,
                    );
                  },
                )
              : null,
        );
      },
    );
  }

  Widget _buildAppBarTitle(bool anySelected) {
    return ValueListenableBuilder<Set<SelectableFile>>(
      valueListenable: _fileSelectionManager.selectedFilesNotifier,
      builder: (context, selectedFiles, _) {
        if (anySelected) {
          return Row(
            children: [
              IconButton(
                icon: Icon(
                  _areAllFilesSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color:
                      _areAllFilesSelected ? Colors.blueAccent : Colors.black,
                ),
                onPressed: () {
                  _toggleFileSelection(_getCurrentFiles().first,
                      selectAll: !_areAllFilesSelected);
                },
              ),
              const SizedBox(width: 8),
              Text("Selected: ${selectedFiles.length}"),
            ],
          );
        } else {
          return const Text('Gallery');
        }
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
    return RepaintBoundary(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          final file = files[index];
          return RepaintBoundary(
            child: GestureDetector(
              onTap: () {
                if (_fileSelectionManager
                    .selectedFilesNotifier.value.isNotEmpty) {
                  _toggleFileSelection(file);
                } else {
                  _openFullScreen(context, file);
                }
              },
              onLongPress: () {
                _toggleFileSelection(file);
              },
              child: buildGalleryMediaWidget(
                context,
                file,
                _fileSelectionManager.selectedFilesNotifier.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

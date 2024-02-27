import 'dart:io';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:drive_camfy/widgets/concave_button.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class SaveDirectory {
  final Directory saveDir;

  SaveDirectory(this.saveDir);

  String get images => path.join(saveDir.path, 'images');
  String get videos => path.join(saveDir.path, 'videos');
}

class CameraControlButtonsWidget extends StatelessWidget {
  final CameraController controller;
  final Directory saveDir;

  const CameraControlButtonsWidget(
      {super.key, required this.controller, required this.saveDir});

  Future<void> _takeAndSavePicture() async {
    try {
      final XFile image = await controller.takePicture();
      SaveDirectory saveDirectory = SaveDirectory(saveDir);
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now);
      final String imagePath =
          '${saveDirectory.images}/image_$formattedDate.jpg';
      final File newImage = File(image.path);

      await newImage.copy(imagePath);
    } catch (e) {
      print('Błąd podczas robienia i zapisywania zdjęcia: $e');
    }
  }

  Future<void> _openGalleryScreen(BuildContext context) async {
    SaveDirectory saveDirectory = SaveDirectory(saveDir);
    final List<File> images = [];
    final List<File> videos = [];

    if (await Directory(saveDirectory.images).exists()) {
      final List<FileSystemEntity> imageFiles =
          Directory(saveDirectory.images).listSync();
      for (var entity in imageFiles) {
        if (entity is File && entity.lengthSync() > 0) {
          images.add(File(entity.path));
        }
      }
    }

    if (await Directory(saveDirectory.videos).exists()) {
      final List<FileSystemEntity> videoFiles =
          Directory(saveDirectory.videos).listSync();
      for (var entity in videoFiles) {
        if (entity is File && entity.lengthSync() > 0) {
          videos.add(File(entity.path));
        }
      }
    }

    if (images.isNotEmpty || videos.isNotEmpty) {
      ///TODO: Add videos to navigator and change position of builders
      Navigator.of(context).pushNamed('/gallery',
          arguments: {'images': images, 'videos': videos});
    } else {
      /// TODO: Obsługa przypadku gdy katalog istnieje, ale nie zawiera prawidłowych obrazów
      print('Brak prawidłowych obrazów w galerii.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            _buildCameraButton(),
            _buildGalleryButton(context),
            _buildCaptureButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return Transform.translate(
      offset: const Offset(80, 0),
      child: ConcaveButton(
        width: 60,
        height: 100,
        arcHeight: 12,
        isRightButton: true,
        onPressed: _takeAndSavePicture,
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }

  Widget _buildGalleryButton(BuildContext context) {
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

  Widget _buildCaptureButton() {
    return ElevatedButton(
      onPressed: () {
        // Obsługa przycisku do przechwytywania
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(30),
        backgroundColor: Colors.white.withOpacity(0.5),
      ),
      child: const Icon(
        Icons.circle,
        color: Colors.red,
      ),
    );
  }
}

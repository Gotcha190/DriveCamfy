import 'dart:io';
import 'package:camera/camera.dart';
import 'package:drive_camfy/utils/app_directory.dart';
import 'package:drive_camfy/widgets/camera_controls/concave_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drive_camfy/widgets/camera_widget.dart';

class PhotoButton extends StatelessWidget {
  const PhotoButton({super.key});

  Future<void> _takeAndSavePicture(BuildContext context) async {
    late final CameraController? controller = CameraWidget.of(context);
    try {
      final XFile image = await controller!.takePicture();
      final String imagePath = _getImagePath();
      final File newImage = File(image.path);
      await newImage.copy(imagePath);
    } catch (e) {
      print('Błąd podczas robienia i zapisywania zdjęcia: $e');
    }
  }

  String _getImagePath() {
    final now = DateTime.now();
    return '${AppDirectory().images}/image_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(now)}.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(80, 0),
      child: ConcaveButton(
        width: 60,
        height: 100,
        arcHeight: 12,
        isRightButton: true,
        onPressed: () async {
          await _takeAndSavePicture(context);
        },
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }
}

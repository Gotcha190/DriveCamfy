import 'package:drive_camfy/widgets/camera_controls/gallery_button.dart';
import 'package:drive_camfy/widgets/camera_controls/photo_button.dart';
import 'package:drive_camfy/widgets/camera_controls/video_button.dart';
import 'package:flutter/material.dart';

class CameraControlButtonsWidget extends StatelessWidget {

  const CameraControlButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            PhotoButton(),
            GalleryButton(),
            VideoButton(),
          ],
        ),
      ),
    );
  }
}

import 'package:drive_camfy/widgets/camera_controls/concave_button.dart';
import 'package:flutter/material.dart';

class GalleryButton extends StatelessWidget {
  const GalleryButton({super.key});

  Future<void> _openGalleryScreen(BuildContext context) async {
    if (!context.mounted) return;
    Navigator.of(context).pushNamed('/gallery');
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

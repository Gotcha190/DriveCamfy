import 'package:camera/camera.dart';
import 'package:drive_camfy/utils/app_directory.dart';
import 'package:drive_camfy/utils/media_tools/file_manager.dart';
import 'package:drive_camfy/widgets/camera_controls/concave_button.dart';
import 'package:flutter/material.dart';
import 'package:drive_camfy/widgets/camera_widget.dart';

class PhotoButton extends StatefulWidget {
  const PhotoButton({super.key});

  @override
  State<PhotoButton> createState() => _PhotoButtonState();
}

class _PhotoButtonState extends State<PhotoButton> {
  late OverlayEntry _overlayEntry;

  Future<void> _takeAndSavePicture(BuildContext context) async {
    final CameraController? controller = CameraWidget.of(context);
    try {
      final XFile image = await controller!.takePicture();
      if (!context.mounted) return;
      _showOverlay(context);
      await Future.delayed(const Duration(milliseconds: 500));
      _hideOverlay();
      await FileManager.saveImage(image, DateTime.now(), AppDirectory().images);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/error',
        arguments: {
          'title': 'Error taking or saving photo',
          'error': e.toString(),
        },
      );
    }
  }

  void _showOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: 1.0,
              child: Container(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry);
  }

  void _hideOverlay() {
    _overlayEntry.remove();
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

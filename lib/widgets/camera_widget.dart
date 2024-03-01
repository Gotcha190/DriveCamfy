import 'package:drive_camfy/widgets/camera_controls/camera_control_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  CameraWidgetState createState() => CameraWidgetState();

  static CameraController? of(BuildContext context) {
    final state = context.findAncestorStateOfType<CameraWidgetState>();
    return state?._controller;
  }
}

class CameraWidgetState extends State<CameraWidget> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.max,
    );

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                CameraPreview(_controller),
                const CameraControlButtonsWidget(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

import 'package:drive_camfy/utils/media_tools/video_recorder.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:drive_camfy/widgets/camera_controls/camera_control_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

final GlobalKey<CameraWidgetState> cameraWidgetKey =
    GlobalKey<CameraWidgetState>();

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  CameraWidgetState createState() => CameraWidgetState();

  static CameraController? of(BuildContext context) {
    final state = context.findAncestorStateOfType<CameraWidgetState>();
    return state?._controller;
  }

  static Future<CameraController> createController() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    return CameraController(
      firstCamera,
      ResolutionPreset.max,
      enableAudio: SettingsManager.recordSoundEnabled,
    );
  }

  static void setController(BuildContext context, CameraController controller) {
    final state = context.findAncestorStateOfType<CameraWidgetState>();
    state?._setController(controller);
  }
}

class CameraWidgetState extends State<CameraWidget> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  // late VideoRecorder _videoRecorder;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    SettingsManager.subscribeToSettingsChanges(_onSettingsChanged);
    // _videoRecorder = VideoRecorder.instance;
    // _videoRecorder.setup(context: context, key: cameraWidgetKey);
  }

  @override
  void dispose() {
    SettingsManager.unsubscribeFromSettingsChanges(_onSettingsChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSettingsChanged(String settingName) async {
    if (!_controller.value.isRecordingVideo &&
        settingName == SettingsManager.keyRecordSoundEnabled) {
      _controller.dispose();
      await reinitializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    _controller = await CameraWidget.createController();
    try {
      await _controller.initialize();
      print("CONTROLLER INITIALIZED IN CAMERA WIDGET: $_controller");
      VideoRecorder.instance.setController(_controller);
      if (mounted) {
        setState(() {});
      }
      print("CONTROLLER INITIALIZED IN CAMERA WIDGET: $_controller");
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> reinitializeCamera() async {
    setState(() {
      _initializeControllerFuture = _initializeCamera();
    });
  }

  void _setController(CameraController controller) {
    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print("CameraWidget preview controller: $_controller");
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

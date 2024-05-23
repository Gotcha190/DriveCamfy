import 'package:drive_camfy/utils/media_tools/video_recorder.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:drive_camfy/widgets/camera_controls/camera_control_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

final GlobalKey<CameraWidgetState> cameraWidgetKey =
    GlobalKey<CameraWidgetState>();

class CameraWidget extends StatefulWidget {
  final Function(bool) onControllerInitialized;
  const CameraWidget({super.key, required this.onControllerInitialized});

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
  late bool _isControllerInitialized;

  @override
  void initState() {
    super.initState();
    _isControllerInitialized = false;
    _initializeControllerFuture = _initializeCamera();
    SettingsManager.subscribeToSettingsChanges(_onSettingsChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    SettingsManager.unsubscribeFromSettingsChanges(_onSettingsChanged);
  }

  void _onSettingsChanged(String settingName) async {
    if (!_controller.value.isRecordingVideo &&
        settingName == SettingsManager.keyRecordSoundEnabled) {
      setState(() {
        _isControllerInitialized = true;
      });
      _controller.dispose();
      await reinitializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    _controller = await CameraWidget.createController();
    try {
      await _controller.initialize();
      setState(() {
        _isControllerInitialized = true;
      });
      widget.onControllerInitialized(true);
      VideoRecorder.instance.setController(_controller);
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> reinitializeCamera() async {
    widget.onControllerInitialized(false);
    setState(() {
      _initializeControllerFuture = _initializeCamera();
      _isControllerInitialized = false;
    });
  }

  void _setController(CameraController controller) {
    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("_isControllerInitialized: $_isControllerInitialized");
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isControllerInitialized
      ? FutureBuilder<void>(
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
      )
            : const Center(child: CircularProgressIndicator())
    );
  }
}

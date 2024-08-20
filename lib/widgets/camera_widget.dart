import 'package:drive_camfy/utils/media_tools/video_recorder.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:drive_camfy/widgets/camera_controls/camera_control_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

final GlobalKey<CameraWidgetState> cameraWidgetKey =
    GlobalKey<CameraWidgetState>();

class CameraWidget extends StatefulWidget {
  final Function(bool) onControllerInitializationChanged;
  const CameraWidget(
      {super.key, required this.onControllerInitializationChanged});

  @override
  CameraWidgetState createState() => CameraWidgetState();

  static CameraController? of(BuildContext context) {
    final state = context.findAncestorStateOfType<CameraWidgetState>();
    return state?._controller;
  }

  static Future<CameraController> createController() async {
    CameraController controller = CameraController(
      SettingsManager.selectedCamera,
      SettingsManager.cameraQuality,
      enableAudio: SettingsManager.recordSoundEnabled,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller.initialize();
    await controller.setFlashMode(FlashMode.off);
    return controller;
  }

  static void setController(BuildContext context, CameraController controller) {
    final state = context.findAncestorStateOfType<CameraWidgetState>();
    state?._isControllerInitialized = false;
    state?._setController(controller);
  }
}

class CameraWidgetState extends State<CameraWidget>
    with WidgetsBindingObserver {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool _isControllerInitialized = false;
  bool _isProcessingSettingsChange = false;

  @override
  void initState() {
    super.initState();
    _isControllerInitialized = false;
    _initializeControllerFuture = _initializeCamera();
    SettingsManager.subscribeToSettingsChanges(_onSettingsChanged);
    VideoRecorder.instance.setControllerStateCallback(_onControllerChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    SettingsManager.unsubscribeFromSettingsChanges(_onSettingsChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      setState(() {
        _isControllerInitialized = false;
      });
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        _initializeControllerFuture = _initializeCamera();
      });
    }
  }

  void _setController(CameraController controller) {
    setState(() {
      _controller = controller;
      _isControllerInitialized = true;
    });
  }

  void _onControllerChanged(bool isInitialized) {
    widget.onControllerInitializationChanged(isInitialized);
  }

  void _onSettingsChanged(String settingName) async {
    if (_isProcessingSettingsChange ||
        (_controller?.value.isRecordingVideo ?? false)) {
      return;
    }
    _isProcessingSettingsChange = true;
    switch (settingName) {
      case SettingsManager.keyRecordSoundEnabled:
      case SettingsManager.keyCameraQuality:
      case SettingsManager.keySelectedCamera:
        widget.onControllerInitializationChanged(false);
        setState(() {
          _isControllerInitialized = false;
        });
        await reinitializeCamera();
        break;
      case SettingsManager.keyEmergencyDetectionEnabled:
      case SettingsManager.keyAccelerationThreshold:
      case SettingsManager.keySpeedThreshold:
        VideoRecorder.instance.initializeEmergencyDetection();
        break;
    }
    _isProcessingSettingsChange = false;
  }

  Future<void> _initializeCamera() async {
    _controller = await CameraWidget.createController();
    setState(() {
      _isControllerInitialized = true;
    });
    widget.onControllerInitializationChanged(true);
    VideoRecorder.instance.setController(_controller!);
  }

  Future<void> reinitializeCamera() async {
    setState(() {
      _isControllerInitialized = false;
    });
    await _controller?.dispose();
    widget.onControllerInitializationChanged(false);
    setState(() {
      _initializeControllerFuture = _initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isControllerInitialized
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    _isControllerInitialized) {
                  return Stack(
                    fit: StackFit.expand,
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      CameraPreview(_controller!),
                      const CameraControlButtonsWidget(),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

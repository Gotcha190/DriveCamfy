import 'package:drive_camfy/utils/emergency_controller.dart';
import 'package:drive_camfy/utils/video_recorder.dart';
import 'package:drive_camfy/widgets/camera_widget.dart';
import 'package:flutter/material.dart';

class VideoButton extends StatefulWidget {
  const VideoButton({super.key});

  @override
  State<VideoButton> createState() => _VideoButtonState();
}

class _VideoButtonState extends State<VideoButton> {
  late VideoRecorder _videoRecorder;
  late EmergencyController _emergencyController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _videoRecorder = VideoRecorder.instance;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = CameraWidget.of(context);
      if (controller != null) {
        _videoRecorder
            .setup(
          controller: controller,
          context: context,
          key: cameraWidgetKey,
          callback: _onEmergencyStateChange,
        )
            .then((_) {
          _emergencyController = _videoRecorder.emergencyController;
          _emergencyController.addListener(_onEmergencyStateChange);
          if (mounted) {
            setState(() {});
          }
        }).catchError((e) {
          print('Error setting up video recorder: $e');
        });
      } else {
        print('Camera controller not found.');
      }
    });
  }

  void _onEmergencyStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _waitForRecordingToStart() async {
    while (!_videoRecorder.controller.value.isRecordingVideo) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void dispose() {
    _emergencyController.removeListener(_onEmergencyStateChange);
    super.dispose();
  }

  Future<void> _handleButtonPress() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_videoRecorder.controller.value.isRecordingVideo) {
        if (_emergencyController.isEmergencyActive) {
          await _emergencyController.stopEmergency();
        }
        await _videoRecorder.stopRecording(
          cleanup: true,
          shouldContinueRecording: false,
        );
        return;
      } else {
        _videoRecorder.recordRecursively(true);
        await _waitForRecordingToStart();
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleLongPress() async {
    if (_isProcessing) return;

    if (!_videoRecorder.controller.value.isRecordingVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Start recording first to use emergency recording"),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (!_emergencyController.isEmergencyActive) {
        _emergencyController.startEmergency();
        await _waitForRecordingToStart();
      } else {
        await _emergencyController.stopEmergency();
        _videoRecorder.recordRecursively(true);
        await _waitForRecordingToStart();
      }
    } catch (e) {
      print('Error handling long press: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_videoRecorder.controller.value.isInitialized) {
      return const CircularProgressIndicator();
    }
    return ElevatedButton(
      onPressed: _handleButtonPress,
      onLongPress: _handleLongPress,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(30),
        backgroundColor: Colors.white.withOpacity(0.5),
      ),
      child: Icon(
        Icons.circle,
        color: _videoRecorder.controller.value.isRecordingVideo
            ? Colors.red
            : Colors.black,
      ),
    );
  }
}

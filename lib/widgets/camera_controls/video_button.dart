import 'dart:async';
import 'package:camera/camera.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:drive_camfy/utils/media_tools/video_recorder.dart';
import 'package:drive_camfy/widgets/camera_widget.dart';
import 'package:flutter/material.dart';

class VideoButton extends StatefulWidget {
  const VideoButton({super.key});

  @override
  State<VideoButton> createState() => _VideoButtonState();
}

class _VideoButtonState extends State<VideoButton> {
  late VideoRecorder _videoRecorder;
  late OverlayEntry _overlayEntry;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _videoRecorder = VideoRecorder.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = CameraWidget.of(context);
      if (controller != null) {
        _videoRecorder.setup(
          controller: controller,
          context: context,
          key: cameraWidgetKey,
          callback: _updateRecordingState,
        );
        // _videoRecorder.setController(controller);
        setState(() {
          _isRecording = controller.value.isRecordingVideo;
        });
      } else {
        print('Camera controller not found.');
      }
    });
    _overlayEntry = OverlayEntry(builder: (context) {
      return const Positioned(
        top: 40,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
            ),
            Text(
              "EMERGENCY",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 40,
                decoration: TextDecoration.none,
              ),
            ),
            Icon(
              Icons.warning,
              color: Colors.red,
            ),
          ],
        ),
      );
    });
  }

  void _updateRecordingState(bool isRecording) {
    setState(() {
      _isRecording = isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        print("BUTTON CONTROLLER: ${_videoRecorder.controller}");
        if (!_videoRecorder.controller.value.isInitialized) {
          print('Controller is not initialized.');
          return;
        }
        if (_videoRecorder.controller.value.isRecordingVideo) {
          await _videoRecorder.stopRecording(false);
          setState(() {
            _isRecording = false;
          });
        } else if (SettingsManager.recordLength > 0 &&
            SettingsManager.recordCount >= 0) {
          await _videoRecorder.recordRecursively();
          setState(() {
            _isRecording = true;
          });
        }
      },
      onLongPress: () async {
        if (!_videoRecorder.controller.value.isInitialized) {
          print('Controller is not initialized.');
          return;
        }
        if (SettingsManager.recordLength > 0 &&
            SettingsManager.recordCount >= 0) {
          await _videoRecorder.startEmergencyRecording();
          Overlay.of(context).insert(
              _overlayEntry); // Add overlay when emergency recording starts
          Timer(const Duration(minutes: 2), () {
            _overlayEntry.remove();
          });
        }
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(30),
        backgroundColor: Colors.white.withOpacity(0.5),
      ),
      child: Icon(
        Icons.circle,
        color: _isRecording ? Colors.red : Colors.black,
      ),
    );
  }
}

import 'dart:async';
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
        if (mounted) {
          setState(() {});
        }
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

  void _updateRecordingState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (!_videoRecorder.controller.value.isInitialized) {
          print('Controller is not initialized.');
          return;
        }
        if (_videoRecorder.controller.value.isRecordingVideo) {
          await _videoRecorder.stopRecording(true);
          setState(() {});
        } else if (SettingsManager.recordLength > 0 &&
            SettingsManager.recordCount >= 0) {
          await _videoRecorder.recordRecursively(true);
          setState(() {});
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
        color: _videoRecorder.controller.value.isRecordingVideo
            ? Colors.red
            : Colors.black,
      ),
    );
  }
}
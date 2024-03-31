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
  late CameraController _controller;
  late OverlayEntry _overlayEntry;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _videoRecorder = VideoRecorder();
    _controller = CameraWidget.of(context)!;
    _videoRecorder.setup(_controller);
    _overlayEntry = OverlayEntry(builder: (context) {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 5),
            ),
          ),
          const Positioned(
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
                ///TODO: DELETE THIS YELLOW UNDERLINE UNDER EMERGENCY TEXT
                Text(
                  "EMERGENCY",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
                Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_controller.value.isRecordingVideo) {
          _videoRecorder.stopRecording(false);
          setState(() {
            _isRecording = false;
          });
        } else if (SettingsManager.recordMins > 0 &&
            SettingsManager.recordCount >= 0) {
          _videoRecorder.recordRecursively();
          setState(() {
            _isRecording = true;
          });
        }
      },
      onLongPress: () {
        if (SettingsManager.recordMins > 0 &&
            SettingsManager.recordCount >= 0) {
          _videoRecorder.startEmergencyRecording();
          Overlay.of(context).insert(
              _overlayEntry); // Add overlay when emergency recording starts
          Timer(const Duration(minutes: 2), () {
            // Remove overlay after 3 minutes
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

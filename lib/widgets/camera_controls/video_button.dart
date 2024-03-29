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
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _videoRecorder = VideoRecorder();
    _controller = CameraWidget.of(context)!;
    _videoRecorder.setup(_controller);
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
        if (SettingsManager.recordMins > 0 && SettingsManager.recordCount >= 0) {
          _videoRecorder.startEmergencyRecording();
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

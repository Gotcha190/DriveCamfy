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
  late VideoRecorder videoRecorder;

  @override
  void initState() {
    super.initState();
    videoRecorder = VideoRecorder();
  }

  @override
  Widget build(BuildContext context) {
    final CameraController controller = CameraWidget.of(context)!;
    return ElevatedButton(
      onPressed: controller.value.isRecordingVideo
          ? () => videoRecorder.stopRecording(false)
          : SettingsManager.recordMins > 0 && SettingsManager.recordCount >= 0
              ? () {
                  videoRecorder.recordRecursively();
                }
              : null,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(30),
        backgroundColor: Colors.white.withOpacity(0.5),
      ),
      child: Icon(
        Icons.circle,
        color: controller.value.isRecordingVideo ? Colors.red : Colors.black,
      ),
    );
  }
}

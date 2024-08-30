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
  OverlayEntry? _overlayEntry;
  bool _isStoppingEmergencyRecording = false;

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
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
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
      },
    );
  }

  void _updateRecordingState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove(); // Clean up any overlays
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_videoRecorder.controller.value.isInitialized) {
      return const CircularProgressIndicator();
    }
    return ElevatedButton(
      onPressed: _isStoppingEmergencyRecording
          ? null // Disable the button while stopping emergency recording
          : () async {
              if (_videoRecorder.controller.value.isRecordingVideo) {
                await _videoRecorder.stopRecording(
                    cleanup: true, shouldContinueRecording: false);
                if (_videoRecorder.isEmergencyRecording &&
                    _overlayEntry != null &&
                    _overlayEntry!.mounted) {
                  _isStoppingEmergencyRecording = true; // Set flag
                  setState(() {});

                  await _videoRecorder.stopEmergencyRecording();
                  _overlayEntry!.remove();

                  _isStoppingEmergencyRecording = false; // Reset flag
                  setState(() {});
                }
              } else if (SettingsManager.recordLength > 0 &&
                  SettingsManager.recordCount >= 0) {
                await _videoRecorder.recordRecursively(true);
              }
              if (mounted) {
                setState(() {});
              }
            },
      onLongPress: _isStoppingEmergencyRecording
          ? null // Disable the button while stopping emergency recording
          : () async {
              if (!_videoRecorder.controller.value.isRecordingVideo) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Start recording first to use emergency recording"),
                  ),
                );
                return; // Exit if not recording
              }
              if (!_videoRecorder.isEmergencyRecording) {
                _overlayEntry = _createOverlayEntry();
                Overlay.of(context).insert(
                    _overlayEntry!); // Add overlay when emergency recording starts
                await _videoRecorder.startEmergencyRecording();
                Timer(const Duration(minutes: 2), () {
                  if (_overlayEntry != null && _overlayEntry!.mounted) {
                    _overlayEntry!.remove();
                  }
                });
                return;
              }
              if (_overlayEntry != null && _overlayEntry!.mounted) {
                _overlayEntry!.remove(); // Ensure it's removed
              }

              _isStoppingEmergencyRecording = true;
              setState(() {});
              await _videoRecorder.stopEmergencyRecording();
              _isStoppingEmergencyRecording = false;
              setState(() {});

              await _videoRecorder.recordRecursively(true);
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

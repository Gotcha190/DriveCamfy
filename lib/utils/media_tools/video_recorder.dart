import 'dart:io';
import 'package:camera/camera.dart';
import 'package:drive_camfy/utils/app_directory.dart';
import 'package:drive_camfy/utils/media_tools/gallery_helper.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:intl/intl.dart';

class VideoRecorder {
  late CameraController controller;
  late DateTime _currentClipStart = DateTime.now();
  late DateTime _emergencyClipStart = DateTime.now();
  late int _recordMins = 0;
  late int _recordCount = 0;
  bool _isEmergencyRecording = false;

  void setup(CameraController cameraController) {
    controller = cameraController;
    _recordMins = SettingsManager.recordMins;
    _recordCount = SettingsManager.recordCount;
  }

  Future<void> recordRecursively() async {
    if (_recordMins > 0 && _recordCount >= 0) {
      await controller.startVideoRecording();
      _currentClipStart = DateTime.now();
      await Future.delayed(Duration(minutes: _recordMins));
      if (controller.value.isRecordingVideo && !_isEmergencyRecording) {
        await stopRecording(true);
        await recordRecursively();
      }
    }
  }

  Future<void> startEmergencyRecording() async {
    print("START EMERGENCY RECORDING!!!");
    _isEmergencyRecording = true;
    _emergencyClipStart = DateTime.now();
    Duration timeDifference = _emergencyClipStart.difference(_currentClipStart);
    Duration emergencyDuration = const Duration(minutes: 2);

    Duration remainingTime = emergencyDuration - timeDifference;

    await Future.delayed(remainingTime);

    await stopEmergencyRecording();
  }

  Future<void> stopRecording(bool cleanup) async {
    if (controller.value.isRecordingVideo) {
      XFile tempFile = await controller.stopVideoRecording();
      String formattedDate =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(_currentClipStart);
      final String videoPath =
          '${AppDirectory().videos}/video_$formattedDate.mp4';
      await tempFile.saveTo(videoPath);
      File(tempFile.path).delete();
      if (cleanup) {
        await deleteOldRecordings();
      }
    }
  }

  Future<void> stopEmergencyRecording() async {
    if (controller.value.isRecordingVideo) {
      XFile tempFile = await controller.stopVideoRecording();
      String formattedDate =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(_emergencyClipStart);
      final String videoPath =
          '${AppDirectory().emergency}/video_$formattedDate.mp4';
      await tempFile.saveTo(videoPath);
      File(tempFile.path).delete();
    }
  }

  Future<void> deleteOldRecordings() async {
    List<File>? existingClips = await GalleryHelper.getVideos();
    if (existingClips.length > _recordCount) {
      // Sort existing clips by creation date
      existingClips
          .sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

      // Delete the oldest recordings beyond the record count
      for (int i = 0; i < existingClips.length - _recordCount; i++) {
        await existingClips[i].delete();
      }
    }
  }
}

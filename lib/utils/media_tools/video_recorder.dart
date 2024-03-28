import 'dart:io';
import 'package:camera/camera.dart';
import 'package:drive_camfy/utils/app_directory.dart';
import 'package:drive_camfy/utils/media_tools/gallery_helper.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:intl/intl.dart';

class VideoRecorder {
  late CameraController controller;
  late DateTime currentClipStart;
  late int recordMins = 0;
  late int recordCount = 0;

  void setup(CameraController cameraController) {
    controller = cameraController;
    recordMins = SettingsManager.recordMins;
    recordCount = SettingsManager.recordCount;
  }

  Future<void> recordRecursively() async {
    if (recordMins > 0 && recordCount >= 0) {
      await controller.startVideoRecording();
      currentClipStart = DateTime.now();
      await Future.delayed(Duration(minutes: recordMins));
      if (controller.value.isRecordingVideo) {
        await stopRecording(true);
        await recordRecursively();
      }
    }
  }

  Future<void> stopRecording(bool cleanup) async {
    if (controller.value.isRecordingVideo) {
      XFile tempFile = await controller.stopVideoRecording();
      String formattedDate =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(currentClipStart);
      final String videoPath =
          '${AppDirectory().videos}/video_$formattedDate.mp4';
      await tempFile.saveTo(videoPath);
      File(tempFile.path).delete();
      if (cleanup) {
        await deleteOldRecordings();
      }
    }
  }

  Future<void> deleteOldRecordings() async {
    List<File>? existingClips = await GalleryHelper.getVideos();
    if (existingClips.length > recordCount) {
      // Sort existing clips by creation date
      existingClips
          .sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

      // Delete the oldest recordings beyond the record count
      for (int i = 0; i < existingClips.length - recordCount; i++) {
        await existingClips[i].delete();
      }
    }
  }
}

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:drive_camfy/utils/app_directory.dart';
import 'package:drive_camfy/utils/media_tools/gallery_helper.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:intl/intl.dart';

class VideoRecorder {
  late CameraController controller;
  late DateTime currentClipStart;

  void setup(CameraController cameraController) {
    controller = cameraController;
  }

  Future<void> recordRecursively() async {
    final recordMins = SettingsManager.recordMins;
    final recordCount = SettingsManager.recordCount;

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
    final recordCount = SettingsManager.recordCount;

    List<File>? existingClips = await GalleryHelper.getVideos();
    if (existingClips.length > recordCount) {
      await Future.wait(existingClips.sublist(recordCount).map((eC) {
        return eC.delete();
      }));
    }
  }
}

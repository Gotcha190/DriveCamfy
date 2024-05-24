import 'dart:io';
import 'package:camera/camera.dart';
import 'package:drive_camfy/utils/app_directory.dart';
import 'package:drive_camfy/utils/media_tools/gallery_helper.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:drive_camfy/widgets/camera_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef RecordingStateCallback = void Function();

class VideoRecorder {
  static final VideoRecorder _instance = VideoRecorder._internal();

  factory VideoRecorder() {
    return _instance;
  }

  VideoRecorder._internal();

  static VideoRecorder get instance => _instance;

  late BuildContext _context;
  late CameraController _controller;
  late DateTime _currentClipStart;
  late DateTime _emergencyClipStart;
  late int _recordMins;
  late int _recordCount;
  bool _shouldContinueRecording = false;

  bool get isEmergencyRecording => _isEmergencyRecording;
  bool _isEmergencyRecording = false;

  RecordingStateCallback? recordingStateCallback;

  CameraController get controller => _controller;
  void setController(CameraController controller) {
    _controller = controller;
  }

  Future<void> setup({
    required CameraController controller,
    required BuildContext context,
    required GlobalKey<CameraWidgetState> key,
    RecordingStateCallback? callback,
  }) async {
    _controller = controller;
    _context = context;
    _recordMins = SettingsManager.recordLength;
    _recordCount = SettingsManager.recordCount;
    SettingsManager.subscribeToSettingsChanges(_onSettingsChanged);
    recordingStateCallback = callback;
  }

  Future<void> _onSettingsChanged(String settingName) async {
    if (!_controller.value.isRecordingVideo) return;
    switch (settingName) {
      case SettingsManager.keyRecordSoundEnabled:
        await stopRecording(
          cleanup: false,
          shouldContinueRecording: true,
        );
        await reinitializeCamera(_context);
        await recordRecursively(true);
        break;
      case SettingsManager.keyRecordLength:
        _recordMins = SettingsManager.recordLength;
        break;
      case SettingsManager.keyRecordCount:
        _recordCount = SettingsManager.recordCount;
        break;
    }
  }

  Future<void> recordRecursively(bool? shouldContinueRecording) async {
    if (shouldContinueRecording != null) {
      _shouldContinueRecording = shouldContinueRecording;
    }
    if (_recordMins > 0 && _recordCount >= 0) {
      if (!_controller.value.isInitialized) {
        print('Controller is not initialized.');
        return;
      }
      while (_shouldContinueRecording) {
        if (!_controller.value.isRecordingVideo) {
          await _controller.startVideoRecording();
          _currentClipStart = DateTime.now();
          recordingStateCallback?.call();
        }
        await Future.delayed(Duration(minutes: _recordMins));
        if (_controller.value.isRecordingVideo && !_isEmergencyRecording) {
          await stopRecording(cleanup: true, shouldContinueRecording: true);
          await recordRecursively(null);
        }
      }
    }
  }

  Future<void> startEmergencyRecording() async {
    _isEmergencyRecording = true;
    _emergencyClipStart = DateTime.now();
    Duration timeDifference = _emergencyClipStart.difference(_currentClipStart);
    Duration emergencyDuration = const Duration(minutes: 2);
    Duration remainingTime = emergencyDuration - timeDifference;
    await Future.delayed(remainingTime);
    await stopEmergencyRecording();
  }

  Future<void> stopRecording({
    required bool cleanup,
    required bool shouldContinueRecording,
  }) async {
    try {
      if (_controller.value.isRecordingVideo) {
        XFile tempFile = await _controller.stopVideoRecording();
        String formattedDate =
            DateFormat('yyyy-MM-dd_HH-mm-ss').format(_currentClipStart);
        final String videoPath =
            '${AppDirectory().videos}/video_$formattedDate.mp4';
        await tempFile.saveTo(videoPath);
        File(tempFile.path).delete();
        recordingStateCallback?.call();
        if (cleanup) await deleteOldRecordings();
        if (!shouldContinueRecording) _shouldContinueRecording = false;
      }
    } on CameraException catch (e) {
      print('Error stopping video recording: ${e.description}');
    }
  }

  Future<void> stopEmergencyRecording() async {
    if (_controller.value.isRecordingVideo) {
      XFile tempFile = await _controller.stopVideoRecording();
      String formattedDate =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(_emergencyClipStart);
      final String videoPath =
          '${AppDirectory().emergency}/EMERGENCY_$formattedDate.mp4';
      await tempFile.saveTo(videoPath);
      File(tempFile.path).delete();
    }
  }

  Future<void> deleteOldRecordings() async {
    List<File>? existingClips = await GalleryHelper.getVideos();
    if (existingClips.length > _recordCount) {
      existingClips
          .sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
      for (int i = 0; i < existingClips.length - _recordCount; i++) {
        await existingClips[i].delete();
      }
    }
  }

  Future<void> reinitializeCamera(BuildContext context) async {
    if (_controller.value.isRecordingVideo) {
      await _controller.stopVideoRecording();
      recordingStateCallback?.call();
    }
    await _controller.dispose();
    _controller = await CameraWidget.createController();
    await _controller.initialize();
    CameraWidget.setController(context, _controller);
  }
}

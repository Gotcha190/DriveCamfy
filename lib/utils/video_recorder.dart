import 'dart:io';
import 'package:camera/camera.dart';
import 'package:drive_camfy/utils/emergency_controller.dart';
import 'package:drive_camfy/utils/emergency_detection.dart';
import 'package:drive_camfy/utils/app_directory.dart';
import 'package:drive_camfy/utils/media_tools/file_manager.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:drive_camfy/widgets/camera_widget.dart';
import 'package:flutter/material.dart';

typedef RecordingStateCallback = void Function();
typedef ControllerStateCallback = void Function(bool isInitialized);

class VideoRecorder {
  static final VideoRecorder _instance = VideoRecorder._internal();

  factory VideoRecorder() {
    return _instance;
  }

  VideoRecorder._internal();

  static VideoRecorder get instance => _instance;

  late BuildContext _context;
  late CameraController _controller;
  late EmergencyController emergencyController;
  late EmergencyDetection emergencyDetection;
  late DateTime _currentClipStart;
  late DateTime _emergencyClipStart;
  late int _recordMins;
  late int _recordCount;
  late bool _autoEmergency;
  bool _shouldContinueRecording = false;
  bool _isProcessingSettingsChange = false;

  bool get isEmergencyRecording => _isEmergencyRecording;
  bool _isEmergencyRecording = false;

  RecordingStateCallback? recordingStateCallback;
  ControllerStateCallback? controllerStateCallback;

  void setControllerStateCallback(ControllerStateCallback callback) {
    controllerStateCallback = callback;
  }

  CameraController get controller => _controller;
  void setController(CameraController controller) {
    _controller = controller;
  }

  // Re-initialize EmergencyController to pick up new settings
  void reinitializeEmergencyDetection() {
    emergencyController = EmergencyController(this);
    emergencyController.initialize(_context);
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
    _autoEmergency = SettingsManager.emergencyDetectionEnabled;
    SettingsManager.subscribeToSettingsChanges(_onSettingsChanged);
    recordingStateCallback = callback;
    emergencyController = EmergencyController(this);
    emergencyController.initialize(context);
  }

  Future<void> _onSettingsChanged(String settingName) async {
    if (_isProcessingSettingsChange || (!_controller.value.isRecordingVideo)) {
      return;
    }
    _isProcessingSettingsChange = true;
    try {
      switch (settingName) {
        case SettingsManager.keyRecordSoundEnabled:
        case SettingsManager.keyCameraQuality:
        case SettingsManager.keySelectedCamera:
          controllerStateCallback?.call(false);
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
        case SettingsManager.keyEmergencyDetectionEnabled:
          _autoEmergency = SettingsManager.emergencyDetectionEnabled;
          if (!_autoEmergency) {
            emergencyController.deactivateMonitoring();
          } else {
            emergencyController.activateMonitoring();
          }
          break;
        case SettingsManager.keyDecelerationThreshold:
        case SettingsManager.keySpeedThreshold:
          reinitializeEmergencyDetection();
          break;
      }
    } catch (e) {
      print('Error in _onSettingsChanged: $e');
    } finally {
      _isProcessingSettingsChange = false;
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

          if (_autoEmergency) emergencyController.activateMonitoring();

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
        await FileManager.saveVideo(
            tempFile, _currentClipStart, AppDirectory().videos);
        recordingStateCallback?.call();
        if (cleanup) FileManager.deleteOldRecordings(_recordCount);
        if (!shouldContinueRecording) {
          _shouldContinueRecording = false;
          if (_autoEmergency) emergencyController.deactivateMonitoring();
        }
      }
    } on CameraException catch (e) {
      print('Error stopping video recording: ${e.description}');
    }
  }

  Future<void> stopEmergencyRecording() async {
    _isEmergencyRecording = false;
    if (_controller.value.isRecordingVideo) {
      XFile tempFile = await _controller.stopVideoRecording();
      await FileManager.saveVideo(
          tempFile, _emergencyClipStart, AppDirectory().emergency);
    }
  }

  Future<void> reinitializeCamera(BuildContext context) async {
    try {
      if (_controller.value.isRecordingVideo) {
        await _controller.stopVideoRecording();
        recordingStateCallback?.call();
      }
      await _controller.dispose();
      _controller = await CameraWidget.createController();
      CameraWidget.setController(context, _controller);
    } catch (e) {
      print('Error in reinitializeCamera: ${e}');
    } finally {
      _isProcessingSettingsChange = false;
      controllerStateCallback?.call(true);
    }
  }
}

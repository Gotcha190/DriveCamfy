import 'dart:async';
import 'package:drive_camfy/utils/emergency_detection.dart';
import 'package:drive_camfy/utils/video_recorder.dart';
import 'package:flutter/material.dart';

class EmergencyController extends ChangeNotifier {
  bool _isEmergencyActive = false;
  bool get isEmergencyActive => _isEmergencyActive;

  final VideoRecorder _videoRecorder;
  EmergencyDetection? _emergencyDetection;
  OverlayEntry? _emergencyOverlay;
  BuildContext? _context;

  EmergencyController(this._videoRecorder);

  void initialize(BuildContext context) {
    _emergencyDetection = EmergencyDetection(this);
    _context = context;
  }

  void activateMonitoring() {
    if (_emergencyDetection != null) {
      _emergencyDetection!.startMonitoringEmergencyBrake(true);
    }
  }

  void deactivateMonitoring() {
    if (_emergencyDetection != null) {
      _emergencyDetection!.startMonitoringEmergencyBrake(false);
      _emergencyDetection!.checkVehicleSpeed(false);
    }
  }

  Future<void> startEmergency() async {
    if (_isEmergencyActive) return;

    _isEmergencyActive = true;
    _showEmergencyOverlay();
    notifyListeners();

    await _startEmergencyRecording();
  }

  Future<void> stopEmergency() async {
    if (!_isEmergencyActive) return;

    _isEmergencyActive = false;
    _removeEmergencyOverlay();
    notifyListeners();

    await _stopEmergencyRecording();
  }

  Future<void> _startEmergencyRecording() async {
    if (_videoRecorder.controller.value.isRecordingVideo) {
      await _videoRecorder.startEmergencyRecording();
    }
  }

  Future<void> _stopEmergencyRecording() async {
    if (_videoRecorder.isEmergencyRecording) {
      await _videoRecorder.stopEmergencyRecording();
    }
  }

  void _showEmergencyOverlay() {
    if (_context == null) return;

    _emergencyOverlay = OverlayEntry(
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

    Overlay.of(_context!).insert(_emergencyOverlay!);
  }

  void _removeEmergencyOverlay() {
    _emergencyOverlay?.remove();
    _emergencyOverlay = null;
  }
}

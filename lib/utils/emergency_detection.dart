import 'dart:async';
import 'package:drive_camfy/utils/media_tools/video_recorder.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:location/location.dart';

class EmergencyDetection {
  final VideoRecorder videoRecorder;
  late StreamSubscription<AccelerometerEvent> _accelerometerListener;
  double _previousZ = 0.0; // Store previous z-axis acceleration

  final double _speedThreshold = SettingsManager.speedThreshold; // Speed threshold (m/s)

  final double _accelerationThreshold = -SettingsManager.accelerationThreshold; // Prog gwałtownego hamowania

  EmergencyDetection(this.videoRecorder);

  // Method to start monitoring for emergency braking
  void startMonitoringEmergencyBrake(bool shouldContinueMonitoring) {
    if (videoRecorder.controller.value.isRecordingVideo && shouldContinueMonitoring && SettingsManager.emergencyDetectionEnabled) {
      // Rozpocznij nasłuchiwanie zdarzeń akcelerometru
      _accelerometerListener = accelerometerEventStream().listen((AccelerometerEvent event) {

        double deltaZ = event.z - _previousZ; // Oblicz zmianę przyspieszenia w osi Z
        _previousZ = event.z;
        print(_previousZ);

        if (deltaZ < _accelerationThreshold) {
          // Wykryto znaczne hamowanie
          checkVehicleSpeed();
        }
      });
    } else {
      // Zatrzymaj nasłuchiwanie zdarzeń akcelerometru
      _accelerometerListener.cancel();
    }
  }

  // Method to check vehicle speed based on GPS data
  void checkVehicleSpeed() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get current vehicle speed from GPS data
    LocationData? currentLocation = await location.getLocation();
    double? currentSpeed = currentLocation.speed;
    print(currentSpeed);

    // Check if vehicle speed is below the threshold

    if (currentSpeed != null && currentSpeed < _speedThreshold) {
      videoRecorder.startEmergencyRecording();
    }
  }
}

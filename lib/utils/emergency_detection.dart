import 'dart:async';
import 'package:drive_camfy/utils/emergency_controller.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:location/location.dart';

class EmergencyDetection {
  final EmergencyController emergencyController;
  late StreamSubscription<UserAccelerometerEvent> _accelerometerListener;
  double _previousZ = 0.0; // Store previous z-axis acceleration
  double _filteredZ = 0.0; // Store filtered z-axis acceleration
  final double _alpha = 0.2; // Smoothing factor for low-pass filter

  final double _speedThreshold =
      SettingsManager.speedThreshold; // Speed threshold (m/s)

  final double _decelerationThreshold =
      -SettingsManager.decelerationThreshold; // Threshold for braking

  EmergencyDetection(this.emergencyController);

  // Method to start monitoring for emergency braking
  void startMonitoringEmergencyBrake(bool shouldContinueMonitoring) {
    if (shouldContinueMonitoring && SettingsManager.emergencyDetectionEnabled) {
      // Start listening to accelerometer events
      _accelerometerListener = userAccelerometerEventStream(
              samplingPeriod: const Duration(seconds: 1))
          .listen((UserAccelerometerEvent event) {
        // Apply low-pass filter to smooth the Z-axis acceleration
        _filteredZ = _alpha * event.z + (1 - _alpha) * _previousZ;
        _previousZ = _filteredZ;

        int deltaZ = (event.z - _previousZ)
            .round(); // Calculate change in Z-axis acceleration
        if (deltaZ < _decelerationThreshold) {
          // Significant braking detected
          checkVehicleSpeed(shouldContinueMonitoring);
        }
      });
    } else {
      // Stop listening to accelerometer events
      _accelerometerListener.cancel();
      checkVehicleSpeed(shouldContinueMonitoring);
    }
  }

  // Method to check vehicle speed based on GPS data
  void checkVehicleSpeed(bool shouldContinueMonitoring) async {
    if (!shouldContinueMonitoring) return;

    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    LocationData? currentLocation = await location.getLocation();
    double? currentSpeed = currentLocation.speed;

    if (currentSpeed != null && currentSpeed < _speedThreshold) {
      emergencyController.startEmergency();
    }
  }
}

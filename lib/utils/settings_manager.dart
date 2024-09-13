import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static SharedPreferences? _prefs;
  static List<CameraDescription> _availableCameras = [];

  // Settings keys
  static const String keyRotationLocked = 'rotation_locked';
  static const String keySelectedCamera = 'selected_camera';
  static const String keyCameraQuality = 'camera_quality';
  static const String keyRecordSoundEnabled = 'record_sound_enabled';
  static const String keyEmergencyDetectionEnabled =
      'emergency_detection_enabled';
  static const String keyDecelerationThreshold = 'deceleration_threshold';
  static const String keySpeedThreshold = 'speed_threshold';
  static const String keyRecordLength = 'record_length';
  static const String keyRecordCount = 'record_count';
  static const String keyStorageLocation = 'storage_location';

  // Default values
  static const ResolutionPreset _defaultCameraQuality = ResolutionPreset.max;
  static const int _defaultSelectedCameraIndex = 0;
  static const bool _defaultRecordSoundEnabled = true;
  static const bool _defaultEmergencyDetectionEnabled = true;
  static const double _defaultDecelerationThreshold = 15.0;
  static const double _defaultSpeedThreshold = 10.0;
  static const bool _defaultRotationLocked = false;
  static const int _defaultRecordLength = 1;
  static const int _defaultRecordCount = 5;
  static const String _defaultStorageLocation = 'Internal';

  // Initialization of SharedPreferences and available cameras
  static Future<void> init() async {
    if (_prefs == null) {
      await _initPrefs();
    }

    _availableCameras = await availableCameras();

    if (_availableCameras.isNotEmpty &&
        !_prefs!.containsKey(keySelectedCamera)) {
      selectedCameraIndex = _defaultSelectedCameraIndex;
    }
  }

  // Initialization of SharedPreferences with default values
  static Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    // Map of default values
    Map<String, dynamic> defaultValues = {
      keyRotationLocked: _defaultRotationLocked,
      keySelectedCamera: _defaultSelectedCameraIndex,
      keyCameraQuality: _defaultCameraQuality,
      keyRecordSoundEnabled: _defaultRecordSoundEnabled,
      keyEmergencyDetectionEnabled: _defaultEmergencyDetectionEnabled,
      keyDecelerationThreshold: _defaultDecelerationThreshold,
      keySpeedThreshold: _defaultSpeedThreshold,
      keyRecordLength: _defaultRecordLength,
      keyRecordCount: _defaultRecordCount,
      keyStorageLocation: _defaultStorageLocation,
    };

    defaultValues.forEach((key, value) {
      if (!_prefs!.containsKey(key)) {
        if (value is String) {
          _prefs?.setString(key, value);
        } else if (value is bool) {
          _prefs?.setBool(key, value);
        } else if (value is int) {
          _prefs?.setInt(key, value);
        } else if (value is double) {
          _prefs?.setDouble(key, value);
        }
      }
    });
  }

  // Methods to subscribe and unsubscribe to changes in settings
  static final List<ValueChanged<String>> _listeners = [];

  static void subscribeToSettingsChanges(ValueChanged<String> onChanged) {
    _listeners.add(onChanged);
  }

  static void unsubscribeFromSettingsChanges(ValueChanged<String> onChanged) {
    _listeners.remove(onChanged);
  }

  static void _notifyListeners(String settingName) {
    for (var listener in _listeners) {
      listener(settingName);
    }
  }

  // Map for converting between String and ResolutionPreset
  static const Map<String, ResolutionPreset> resolutionPresetMap = {
    'Low': ResolutionPreset.low,
    'Medium': ResolutionPreset.medium,
    'High': ResolutionPreset.high,
    'VeryHigh': ResolutionPreset.veryHigh,
    'UltraHigh': ResolutionPreset.ultraHigh,
    'Max': ResolutionPreset.max,
  };

  static const Map<ResolutionPreset, String> resolutionPresetReverseMap = {
    ResolutionPreset.low: 'Low',
    ResolutionPreset.medium: 'Medium',
    ResolutionPreset.high: 'High',
    ResolutionPreset.veryHigh: 'VeryHigh',
    ResolutionPreset.ultraHigh: 'UltraHigh',
    ResolutionPreset.max: 'Max',
  };

  // Methods to lock and unlock screen rotation
  static void rotationLock() {
    _prefs?.setBool(keyRotationLocked, true);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _notifyListeners(keyRotationLocked);
  }

  static void rotationUnlock() {
    _prefs?.setBool(keyRotationLocked, false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _notifyListeners(keyRotationLocked);
  }

  // Screen rotation getter
  static bool get rotationLocked =>
      _prefs?.getBool(keyRotationLocked) ?? _defaultRotationLocked;

  // Camera settings getters and setters
  static ResolutionPreset get cameraQuality {
    String? qualityString = _prefs?.getString(keyCameraQuality);
    return resolutionPresetMap[qualityString] ?? _defaultCameraQuality;
  }

  static set cameraQuality(ResolutionPreset value) {
    String qualityString = resolutionPresetReverseMap[value]!;
    _prefs?.setString(keyCameraQuality, qualityString);
    _notifyListeners(keyCameraQuality);
  }

  static List<CameraDescription> get availableCamerasList => _availableCameras;

  static int get selectedCameraIndex =>
      _prefs?.getInt(keySelectedCamera) ?? _defaultSelectedCameraIndex;

  static set selectedCameraIndex(int index) {
    if (index >= 0 && index < _availableCameras.length) {
      _prefs?.setInt(keySelectedCamera, index);
      _notifyListeners(keySelectedCamera);
    }
  }

  static CameraDescription get selectedCamera =>
      _availableCameras[selectedCameraIndex];

  static bool get recordSoundEnabled =>
      _prefs?.getBool(keyRecordSoundEnabled) ?? _defaultRecordSoundEnabled;

  static set recordSoundEnabled(bool value) {
    _prefs?.setBool(keyRecordSoundEnabled, value);
    _notifyListeners(keyRecordSoundEnabled);
  }

  static bool get emergencyDetectionEnabled =>
      _prefs?.getBool(keyEmergencyDetectionEnabled) ??
      _defaultEmergencyDetectionEnabled;
  static set emergencyDetectionEnabled(bool value) {
    _prefs?.setBool(keyEmergencyDetectionEnabled, value);
    _notifyListeners(keyEmergencyDetectionEnabled);
  }

  static double get decelerationThreshold =>
      _prefs?.getDouble(keyDecelerationThreshold) ??
      _defaultDecelerationThreshold;
  static double get defaultDecelerationThreshold =>
      _defaultDecelerationThreshold;
  static set decelerationThreshold(double value) {
    _prefs?.setDouble(keyDecelerationThreshold, value);
    _notifyListeners(keyDecelerationThreshold);
  }

  static double get speedThreshold =>
      _prefs?.getDouble(keySpeedThreshold) ?? _defaultSpeedThreshold;
  static double get defaultSpeedThreshold => _defaultSpeedThreshold;
  static set speedThreshold(double value) {
    _prefs?.setDouble(keySpeedThreshold, value);
    _notifyListeners(keySpeedThreshold);
  }

  // Storage settings getters and setters
  static int get recordLength =>
      _prefs?.getInt(keyRecordLength) ?? _defaultRecordLength;
  static set recordLength(int value) {
    _prefs?.setInt(keyRecordLength, value);
    _notifyListeners(keyRecordLength);
  }

  static int get recordCount =>
      _prefs?.getInt(keyRecordCount) ?? _defaultRecordCount;
  static set recordCount(int value) {
    _prefs?.setInt(keyRecordCount, value);
    _notifyListeners(keyRecordCount);
  }

  static String get storageLocation =>
      _prefs?.getString(keyStorageLocation) ?? _defaultStorageLocation;
  static set storageLocation(String value) {
    _prefs?.setString(keyStorageLocation, value);
    _notifyListeners(keyStorageLocation);
  }
}

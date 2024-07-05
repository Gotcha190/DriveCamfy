import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static SharedPreferences? _prefs;

  // Methods to subscribe and unsubscribe to changes in settings
  static final List<ValueChanged<String>> _listeners = [];

  static Future<void> init() async {
    if (_prefs == null) {
      await _initPrefs();
    }
  }

  static Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    // Mapa zawierająca klucze i ich domyślne wartości
    Map<String, dynamic> defaultValues = {
      keyRotationLocked: _defaultRotationLocked,
      keyCameraQuality: _defaultCameraQuality,
      keyFrontCameraEnabled: _defaultFrontCameraEnabled,
      keyRecordSoundEnabled: _defaultRecordSoundEnabled,
      keyEmergencyDetectionEnabled: _defaultEmergencyDetectionEnabled,
      keyAccelerationThreshold: _defaultAccelerationThreshold,
      keySpeedThreshold: _defaultSpeedThreshold,
      keyRecordLength: _defaultRecordLength,
      keyRecordCount: _defaultRecordCount,
      keyRecordLocation: _defaultRecordLocation,
      keyPhotoLocation: _defaultPhotoLocation,
    };

    // Iteracja przez mapę i ustawienie domyślnych wartości, jeśli nie są jeszcze ustawione
    defaultValues.forEach((key, value) {
      if (!_prefs!.containsKey(key)) {
        if (value is String) {
          _prefs?.setString(key, value);
        } else if (value is bool) {
          _prefs?.setBool(key, value);
        } else if (value is int) {
          _prefs?.setInt(key, value);
        } else if (value is double){
          _prefs?.setDouble(key, value);
        }
        // Dodaj tutaj obsługę innych typów preferencji
      }
    });
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

  // Default values
  static const ResolutionPreset _defaultCameraQuality = ResolutionPreset.max;
  static const bool _defaultFrontCameraEnabled = false;
  static const bool _defaultRecordSoundEnabled = true;
  static const bool _defaultEmergencyDetectionEnabled = true;
  static const double _defaultAccelerationThreshold = 15.0;
  static const double _defaultSpeedThreshold = 10.0;
  static const bool _defaultRotationLocked = false;
  static const int _defaultRecordLength = 1;
  static const int _defaultRecordCount = 5;
  static const String _defaultRecordLocation = 'External';
  static const String _defaultPhotoLocation = 'External';

  // Screen rotation
  static const String keyRotationLocked = 'rotation_locked';

  // Camera settings
  static const String keyCameraQuality = 'camera_quality';
  static const String keyFrontCameraEnabled = 'front_camera_enabled';
  static const String keyRecordSoundEnabled = 'record_sound_enabled';

  // Emergency detection settings
  static const String keyEmergencyDetectionEnabled = 'emergency_detection_enabled';
  static const String keyAccelerationThreshold = 'acceleration_threshold';
  static const String keySpeedThreshold = 'speed_threshold';

  // Storage settings
  static const String keyRecordLength = 'record_length';
  static const String keyRecordCount = 'record_count';
  static const String keyRecordLocation = 'record_location';
  static const String keyPhotoLocation = 'photo_location';

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

  static bool get frontCameraEnabled =>
      _prefs?.getBool(keyFrontCameraEnabled) ?? _defaultFrontCameraEnabled;
  static set frontCameraEnabled(bool value) {
    _prefs?.setBool(keyFrontCameraEnabled, value);
    _notifyListeners(keyFrontCameraEnabled);
  }

  static bool get recordSoundEnabled =>
     _prefs?.getBool(keyRecordSoundEnabled) ?? _defaultRecordSoundEnabled;

  static set recordSoundEnabled(bool value) {
    _prefs?.setBool(keyRecordSoundEnabled, value);
    _notifyListeners(keyRecordSoundEnabled);
  }

  static bool get emergencyDetectionEnabled =>
      _prefs?.getBool(keyEmergencyDetectionEnabled) ?? _defaultEmergencyDetectionEnabled;
  static set emergencyDetectionEnabled(bool value) {
    _prefs?.setBool(keyEmergencyDetectionEnabled, value);
    _notifyListeners(keyEmergencyDetectionEnabled);
  }

  static double get accelerationThreshold =>
      _prefs?.getDouble(keyAccelerationThreshold) ?? _defaultAccelerationThreshold;
  static double get defaultAccelerationThreshold => _defaultAccelerationThreshold;
  static set accelerationThreshold(double value) {
    _prefs?.setDouble(keyAccelerationThreshold, value);
    _notifyListeners(keyAccelerationThreshold);
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

  static String get recordLocation =>
      _prefs?.getString(keyRecordLocation) ?? _defaultRecordLocation;
  static set recordLocation(String value) {
    _prefs?.setString(keyRecordLocation, value);
    _notifyListeners(keyRecordLocation);
  }

  static String get photoLocation =>
      _prefs?.getString(keyPhotoLocation) ?? _defaultPhotoLocation;
  static set photoLocation(String value) {
    _prefs?.setString(keyPhotoLocation, value);
    _notifyListeners(keyPhotoLocation);
  }
}

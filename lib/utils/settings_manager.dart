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
      keyGSensorEnabled: _defaultGSensorEnabled,
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
        }
        // Dodaj tutaj obsługę innych typów preferencji
      }
    });
  }

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
  static const String _defaultCameraQuality = 'High';
  static const bool _defaultFrontCameraEnabled = false;
  static const bool _defaultRecordSoundEnabled = true;
  static const bool _defaultGSensorEnabled = true;
  static const bool _defaultRotationLocked = false;
  static const int _defaultRecordLength = 1;
  static const int _defaultRecordCount = 5;
  static const String _defaultRecordLocation = 'Internal';
  static const String _defaultPhotoLocation = 'Internal';

  // Screen rotation
  static const String keyRotationLocked = 'rotation_locked';

  // Camera settings
  static const String keyCameraQuality = 'camera_quality';
  static const String keyFrontCameraEnabled = 'front_camera_enabled';
  static const String keyRecordSoundEnabled = 'record_sound_enabled';
  static const String keyGSensorEnabled = 'gsensor_enabled';

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
  static String get cameraQuality =>
      _prefs?.getString(keyCameraQuality) ?? _defaultCameraQuality;
  static set cameraQuality(String value) {
    _prefs?.setString(keyCameraQuality, value);
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

  static bool get gSensorEnabled =>
      _prefs?.getBool(keyGSensorEnabled) ?? _defaultGSensorEnabled;
  static set gSensorEnabled(bool value) {
    _prefs?.setBool(keyGSensorEnabled, value);
    print("set gSensor value: $value");
    _notifyListeners(keyGSensorEnabled);
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

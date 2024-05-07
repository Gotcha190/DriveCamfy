import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    if (_prefs == null) {
      await _initPrefs();
    }
  }

  static Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Screen rotation
  static const String _keyRotationLocked = 'rotation_locked';
  static const bool _defaultRotationLocked = false;

  // Method to lock screen rotation
  static void rotationLock() {
    _prefs?.setBool(_keyRotationLocked, true);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  // Method to unlock screen rotation
  static void rotationUnlock() {
    _prefs?.setBool(_keyRotationLocked, false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // Camera settings
  static const String _keyCameraQuality = 'camera_quality';
  static const String _keyFlashEnabled = 'flash_enabled';
  static const String _keyFrontCameraEnabled = 'front_camera_enabled';
  static const String _keyRecordSoundEnabled = 'record_sound_enabled';
  static const String _keyGSensorEnabled = 'gsensor_enabled';

  // Storage settings
  static const String _keyRecordLength = 'record_length';
  static const String _keyRecordCount = 'record_count';
  static const String _keyRecordLocation = 'record_location';
  static const String _keyPhotoLocation = 'photo_location';

  // Default values
  static const String _defaultCameraQuality = 'High';
  static const bool _defaultFlashEnabled = false;
  static const bool _defaultFrontCameraEnabled = false;
  static const bool _defaultRecordSoundEnabled = false;
  static const bool _defaultGSensorEnabled = false;
  static const int _defaultRecordLength = 1;
  static const int _defaultRecordCount = 5;
  static const String _defaultRecordLocation = 'Internal';
  static const String _defaultPhotoLocation = 'Internal';

  // Screen rotation getter
  static bool get rotationLocked =>
      _prefs?.getBool(_keyRotationLocked) ?? _defaultRotationLocked;

  // Camera settings getters and setters
  static String get cameraQuality =>
      _prefs?.getString(_keyCameraQuality) ?? _defaultCameraQuality;
  static set cameraQuality(String value) =>
      _prefs?.setString(_keyCameraQuality, value);

  static bool get flashEnabled =>
      _prefs?.getBool(_keyFlashEnabled) ?? _defaultFlashEnabled;
  static set flashEnabled(bool value) =>
      _prefs?.setBool(_keyFlashEnabled, value);

  static bool get frontCameraEnabled =>
      _prefs?.getBool(_keyFrontCameraEnabled) ?? _defaultFrontCameraEnabled;
  static set frontCameraEnabled(bool value) =>
      _prefs?.setBool(_keyFrontCameraEnabled, value);

  static bool get recordSoundEnabled =>
      _prefs?.getBool(_keyRecordSoundEnabled) ?? _defaultRecordSoundEnabled;
  static set recordSoundEnabled(bool value) =>
      _prefs?.setBool(_keyRecordSoundEnabled, value);

  static bool get gSensorEnabled =>
      _prefs?.getBool(_keyGSensorEnabled) ?? _defaultGSensorEnabled;
  static set gSensorEnabled(bool value) =>
      _prefs?.setBool(_keyGSensorEnabled, value);

  // Storage settings getters and setters
  static int get recordLength =>
      _prefs?.getInt(_keyRecordLength) ?? _defaultRecordLength;
  static set recordLength(int value) => _prefs?.setInt(_keyRecordLength, value);

  static int get recordCount =>
      _prefs?.getInt(_keyRecordCount) ?? _defaultRecordCount;
  static set recordCount(int value) => _prefs?.setInt(_keyRecordCount, value);

  static String get recordLocation =>
      _prefs?.getString(_keyRecordLocation) ?? _defaultRecordLocation;
  static set recordLocation(String value) =>
      _prefs?.setString(_keyRecordLocation, value);

  static String get photoLocation =>
      _prefs?.getString(_keyPhotoLocation) ?? _defaultPhotoLocation;
  static set photoLocation(String value) =>
      _prefs?.setString(_keyPhotoLocation, value);
}

import 'package:flutter/material.dart';
import 'package:drive_camfy/utils/settings_manager.dart';

class SettingsListener {
  static void startListening(ValueChanged<String> onChanged) {
    SettingsManager.subscribeToSettingsChanges((String settingName) {
      onChanged(settingName);
    });
  }

  static void stopListening(ValueChanged<String> onChanged) {
    SettingsManager.unsubscribeFromSettingsChanges((String settingName) {
      onChanged(settingName);
    });
  }
}
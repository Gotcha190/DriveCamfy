import 'package:flutter/material.dart';
import 'package:drive_camfy/utils/settings_manager.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  late bool _rotationLocked;
  late bool _frontCameraEnabled;
  late bool _recordSoundEnabled;
  late bool _gSensorEnabled;

  @override
  void initState() {
    super.initState();
    _rotationLocked = SettingsManager.rotationLocked;
    _frontCameraEnabled = SettingsManager.frontCameraEnabled;
    _recordSoundEnabled = SettingsManager.recordSoundEnabled;
    _gSensorEnabled = SettingsManager.gSensorEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildCategoryHeader('App Settings'),
          _buildAppSettings(),
          _buildCategoryHeader('Camera Settings'),
          _buildCameraSettings(),
          _buildCategoryHeader('Storage'),
          _buildStorageSettings(),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[300],
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAppSettings() {
    return Column(
      children: [
        ListTile(
          title: const Text('Screen Rotation'),
          trailing: Switch(
            value: _rotationLocked,
            onChanged: (value) {
              setState(() {
                if (value) {
                  SettingsManager.rotationLock();
                } else {
                  SettingsManager.rotationUnlock();
                }
                _rotationLocked = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCameraSettings() {
    return Column(
      children: [
        ListTile(
          title: const Text('Camera Quality'),
          trailing: DropdownButton<String>(
            value: SettingsManager.cameraQuality,
            onChanged: (String? newValue) {
              setState(() {
                SettingsManager.cameraQuality = newValue!;
              });
            },
            items: <String>['Low', 'Medium', 'High']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('Front Camera'),
          trailing: Switch(
            value: _frontCameraEnabled,
            onChanged: (value) {
              setState(() {
                SettingsManager.frontCameraEnabled = value;
                _frontCameraEnabled = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Record Sound'),
          trailing: Switch(
            value: _recordSoundEnabled,
            onChanged: (value) {
              setState(() {
                SettingsManager.recordSoundEnabled = value;
                _recordSoundEnabled = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('G-Sensor'),
          trailing: Switch(
            value: _gSensorEnabled,
            onChanged: (value) {
              setState(() {
                SettingsManager.gSensorEnabled = value;
                _gSensorEnabled = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStorageSettings() {
    return Column(
      children: [
        ListTile(
          title: const Text('Record Length'),
          trailing: DropdownButton<int>(
            value: SettingsManager.recordLength,
            onChanged: (int? newValue) {
              setState(() {
                SettingsManager.recordLength = newValue!;
              });
            },
            items: <int>[1, 2, 3, 5, 10].map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('Max Record Size'),

          ///TODO: Record size by GB not count
          trailing: DropdownButton<int>(
            value: SettingsManager.recordCount,
            onChanged: (int? newValue) {
              setState(() {
                SettingsManager.recordCount = newValue!;
              });
            },
            items: <int>[5, 10, 15, 20].map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('Record Location'),
          trailing: DropdownButton<String>(
            value: SettingsManager.recordLocation,
            onChanged: (String? newValue) {
              setState(() {
                SettingsManager.recordLocation = newValue!;
              });
            },
            items: <String>['Internal', 'External']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('Photo Location'),
          trailing: DropdownButton<String>(
            value: SettingsManager.photoLocation,
            onChanged: (String? newValue) {
              setState(() {
                SettingsManager.photoLocation = newValue!;
              });
            },
            items: <String>['Internal', 'External']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

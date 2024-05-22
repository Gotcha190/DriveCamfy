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
  late String _cameraQuality;
  late int _recordLength;
  late int _recordCount;
  late String _recordLocation;
  late String _photoLocation;

  @override
  void initState() {
    super.initState();
    _rotationLocked = SettingsManager.rotationLocked;
    _frontCameraEnabled = SettingsManager.frontCameraEnabled;
    _recordSoundEnabled = SettingsManager.recordSoundEnabled;
    _gSensorEnabled = SettingsManager.gSensorEnabled;
    _cameraQuality = SettingsManager.cameraQuality;
    _recordLength = SettingsManager.recordLength;
    _recordCount = SettingsManager.recordCount;
    _recordLocation = SettingsManager.recordLocation;
    _photoLocation = SettingsManager.photoLocation;
  }

  @override
  void dispose() {
    // Apply the local settings to the SettingsManager when the view is disposed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_rotationLocked) {
        SettingsManager.rotationLock();
      } else {
        SettingsManager.rotationUnlock();
      }
      SettingsManager.frontCameraEnabled = _frontCameraEnabled;
      SettingsManager.recordSoundEnabled = _recordSoundEnabled;
      SettingsManager.gSensorEnabled = _gSensorEnabled;
    });
    super.dispose();
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
            value: _cameraQuality,
            onChanged: (String? newValue) {
              setState(() {
                _cameraQuality = newValue!;
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
            value: _recordLength,
            onChanged: (int? newValue) {
              setState(() {
                _recordLength = newValue!;
              });
            },
            items:
                <int>[1, 2, 3, 5, 10].map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('Max Record Size'),
          trailing: DropdownButton<int>(
            value: _recordCount,
            onChanged: (int? newValue) {
              setState(() {
                _recordCount = newValue!;
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
            value: _recordLocation,
            onChanged: (String? newValue) {
              setState(() {
                _recordLocation = newValue!;
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
            value: _photoLocation,
            onChanged: (String? newValue) {
              setState(() {
                _photoLocation = newValue!;
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

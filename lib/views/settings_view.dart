import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
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
            items: <String>['Low', 'Medium', 'High'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('Flash'),
          trailing: Switch(
            value: SettingsManager.flashEnabled,
            onChanged: (value) {
              setState(() {
                SettingsManager.flashEnabled = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Front Camera'),
          trailing: Switch(
            value:  SettingsManager.frontCameraEnabled,
            onChanged: (value) {
              setState(() {
                SettingsManager.frontCameraEnabled = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Record Sound'),
          trailing: Switch(
            value: SettingsManager.recordSoundEnabled,
            onChanged: (value) {
              setState(() {
                SettingsManager.recordSoundEnabled = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('G-Sensor'),
          trailing: Switch(
            value: SettingsManager.gSensorEnabled,
            onChanged: (value) {
              setState(() {
                SettingsManager.gSensorEnabled = value;
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
        // Dodaj ListTile dla opcji długości nagrania
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
                child: Text(value as String),
              );
            }).toList(),
          ),
        ),
        // Dodaj ListTile dla opcji maksymalnej wielkości nagrań
        ListTile(
          title: const Text('Max Record Size'),
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
                child: Text(value as String),
              );
            }).toList(),
          ),
        ),
        // Dodaj ListTile dla opcji lokalizacji nagrań
        ListTile(
          title: const Text('Record Location'),
          trailing: DropdownButton<String>(
            value: SettingsManager.recordLocation,
            onChanged: (String? newValue) {
              setState(() {
                SettingsManager.recordLocation = newValue!;
              });
            },
            items: <String>['Internal', 'External'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        // Dodaj ListTile dla opcji lokalizacji zdjęć
        ListTile(
          title: const Text('Photo Location'),
          trailing: DropdownButton<String>(
            value: SettingsManager.photoLocation,
            onChanged: (String? newValue) {
              setState(() {
                SettingsManager.photoLocation = newValue!;
              });
            },
            items: <String>['Internal', 'External'].map<DropdownMenuItem<String>>((String value) {
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

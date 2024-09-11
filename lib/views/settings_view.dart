import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:drive_camfy/utils/settings_manager.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  late TextEditingController _decelerationController;
  late TextEditingController _speedController;
  late bool _rotationLocked;
  late bool _recordSoundEnabled;
  late bool _emergencyDetectionEnabled;
  late double _decelerationThreshold;
  late double _speedThreshold;
  late ResolutionPreset _cameraQuality;
  late int _recordLength;
  late int _recordCount;
  late String _recordLocation;
  late String _photoLocation;

  @override
  void initState() {
    super.initState();
    _rotationLocked = SettingsManager.rotationLocked;
    _recordSoundEnabled = SettingsManager.recordSoundEnabled;
    _emergencyDetectionEnabled = SettingsManager.emergencyDetectionEnabled;
    _decelerationThreshold = SettingsManager.decelerationThreshold;
    _speedThreshold = SettingsManager.speedThreshold;
    _cameraQuality = SettingsManager.cameraQuality;
    _recordLength = SettingsManager.recordLength;
    _recordCount = SettingsManager.recordCount;
    _recordLocation = SettingsManager.recordLocation;
    _photoLocation = SettingsManager.photoLocation;
    _decelerationController =
        TextEditingController(text: _decelerationThreshold.toString());
    _speedController = TextEditingController(text: _speedThreshold.toString());
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
      SettingsManager.cameraQuality = _cameraQuality;
      SettingsManager.recordSoundEnabled = _recordSoundEnabled;
      SettingsManager.emergencyDetectionEnabled = _emergencyDetectionEnabled;
      SettingsManager.decelerationThreshold = _decelerationThreshold;
      SettingsManager.speedThreshold = _speedThreshold;
    });
    _decelerationController.dispose();
    _speedController.dispose();
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
          _buildCategoryHeader('App'),
          _buildAppSettings(),
          _buildCategoryHeader('Camera'),
          _buildCameraSettings(),
          _buildCategoryHeader('Emergency Detection'),
          _buildEmergencyDetection(),
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
          title: const Text('Screen Rotation Lock'),
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
          title: const Text('Select Camera'),
          trailing: DropdownButton<int>(
            value: SettingsManager.selectedCameraIndex,
            onChanged: (int? newCameraIndex) {
              setState(() {
                if (newCameraIndex != null) {
                  SettingsManager.selectedCameraIndex = newCameraIndex;
                }
              });
            },
            items: SettingsManager.availableCamerasList
                .asMap()
                .entries
                .map<DropdownMenuItem<int>>((entry) {
              int index = entry.key;
              CameraDescription camera = entry.value;
              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                    'Camera ${camera.name} (${camera.lensDirection.toString().split('.').last})'),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('Camera Quality'),
          trailing: DropdownButton<ResolutionPreset>(
            value: _cameraQuality,
            onChanged: (ResolutionPreset? newValue) {
              setState(() {
                _cameraQuality = newValue!;
              });
            },
            items: ResolutionPreset.values
                .map<DropdownMenuItem<ResolutionPreset>>(
                    (ResolutionPreset value) {
              return DropdownMenuItem<ResolutionPreset>(
                value: value,
                child: Text(SettingsManager.resolutionPresetReverseMap[value]!),
              );
            }).toList(),
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
      ],
    );
  }

  Widget _buildEmergencyDetection() {
    return Column(
      children: [
        ListTile(
          title: const Text('Automatic emergency detection'),
          trailing: Switch(
            value: _emergencyDetectionEnabled,
            onChanged: (value) {
              setState(() {
                _emergencyDetectionEnabled = value;
              });
            },
          ),
        ),
        ListTile(
          title: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Deceleration Threshold'),
                    content: const Text(
                      'Defines the minimum value of sudden deceleration (braking), below which the system detects a potentially dangerous situation. The lower the value, the more sensitive the system is to sudden braking.',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deceleration Threshold'),
                Icon(
                  Icons.help,
                  size: 12,
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 50,
                child: TextFormField(
                  controller: _decelerationController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Enter deceleration threshold',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _decelerationThreshold =
                          double.tryParse(value) ?? _decelerationThreshold;
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () {
                  setState(() {
                    _decelerationThreshold = SettingsManager
                        .defaultDecelerationThreshold; // Przywróć domyślną wartość progową przyspieszenia
                    _decelerationController.text = SettingsManager
                        .defaultDecelerationThreshold
                        .toString(); // Ustaw wartość pola tekstowego na domyślną
                  });
                },
              ),
            ],
          ),
        ),
        ListTile(
          title: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Speed Threshold'),
                    content: const Text(
                      'The speed limit below which the system recognizes an emergency after detecting sudden braking. If the vehicle’s speed drops below this value, the system will trigger an emergency alert.',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Speed Threshold'),
                Icon(
                  Icons.help,
                  size: 12,
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 50,
                child: TextFormField(
                  controller: _speedController, // Kontroler dla pola tekstowego
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true), // Ustaw typ klawiatury na numeryczną
                  decoration: const InputDecoration(
                    hintText:
                        'Enter speed threshold', // Opcjonalny tekst podpowiedzi
                  ),
                  onChanged: (value) {
                    setState(() {
                      _speedThreshold = double.tryParse(value) ??
                          _speedThreshold; // Aktualizacja wartości progowej prędkości
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () {
                  setState(() {
                    _speedThreshold = SettingsManager
                        .defaultSpeedThreshold; // Przywróć domyślną wartość progową prędkości
                    _speedController.text = SettingsManager
                        .defaultSpeedThreshold
                        .toString(); // Ustaw wartość pola tekstowego na domyślną
                  });
                },
              ),
            ],
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
          title: const Text('Max Record Count'),
          trailing: DropdownButton<int>(
            value: _recordCount,
            onChanged: (int? newValue) {
              setState(() {
                _recordCount = newValue!;
              });
            },
            items: <int>[5, 10, 15, 20, 30, 40, 50]
                .map<DropdownMenuItem<int>>((int value) {
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

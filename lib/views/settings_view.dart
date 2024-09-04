import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:drive_camfy/utils/settings_manager.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  late TextEditingController _accelerationController;
  late TextEditingController _speedController;
  late bool _rotationLocked;
  late bool _recordSoundEnabled;
  late bool _emergencyDetectionEnabled;
  late double _accelerationThreshold;
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
    _accelerationThreshold = SettingsManager.accelerationThreshold;
    _speedThreshold = SettingsManager.speedThreshold;
    _cameraQuality = SettingsManager.cameraQuality;
    _recordLength = SettingsManager.recordLength;
    _recordCount = SettingsManager.recordCount;
    _recordLocation = SettingsManager.recordLocation;
    _photoLocation = SettingsManager.photoLocation;
    _accelerationController = TextEditingController(text: _accelerationThreshold.toString());
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
      SettingsManager.accelerationThreshold = _accelerationThreshold;
      SettingsManager.speedThreshold = _speedThreshold;
    });
    _accelerationController.dispose();
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
                child: Text('Camera ${camera.name} (${camera.lensDirection.toString().split('.').last})'),
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
                .map<DropdownMenuItem<ResolutionPreset>>((ResolutionPreset value) {
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
          title: const Text('Acceleration Threshold'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: _accelerationController, // Kontroler dla pola tekstowego
                  keyboardType: const TextInputType.numberWithOptions(decimal: true), // Ustaw typ klawiatury na numeryczną
                  decoration: const InputDecoration(
                    hintText: 'Enter acceleration threshold', // Opcjonalny tekst podpowiedzi
                  ),
                  onChanged: (value) {
                    setState(() {
                      _accelerationThreshold = double.tryParse(value) ?? _accelerationThreshold; // Aktualizacja wartości _accelerationThreshold
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () {
                  setState(() {
                    _accelerationThreshold = SettingsManager.defaultAccelerationThreshold; // Przywróć domyślną wartość progową przyspieszenia
                    _accelerationController.text = SettingsManager.defaultAccelerationThreshold.toString(); // Ustaw wartość pola tekstowego na domyślną
                  });
                },
              ),
            ],
          ),
        ),
        ListTile(
          title: const Text('Speed Threshold'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: _speedController, // Kontroler dla pola tekstowego
                  keyboardType: const TextInputType.numberWithOptions(decimal: true), // Ustaw typ klawiatury na numeryczną
                  decoration: const InputDecoration(
                    hintText: 'Enter speed threshold', // Opcjonalny tekst podpowiedzi
                  ),
                  onChanged: (value) {
                    setState(() {
                      _speedThreshold = double.tryParse(value) ?? _speedThreshold; // Aktualizacja wartości progowej prędkości
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () {
                  setState(() {
                    _speedThreshold = SettingsManager.defaultSpeedThreshold; // Przywróć domyślną wartość progową prędkości
                    _speedController.text = SettingsManager.defaultSpeedThreshold.toString(); // Ustaw wartość pola tekstowego na domyślną
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
            items: <int>[5, 10, 15, 20, 30, 40, 50].map<DropdownMenuItem<int>>((int value) {
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

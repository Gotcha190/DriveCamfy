import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:drive_camfy/utils/settings_manager.dart';

class CameraSelectionDialog extends StatelessWidget {
  const CameraSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Camera"),
      content: SingleChildScrollView(
        child: Column(
          children: SettingsManager.availableCamerasList.asMap().entries.map((entry) {
            int index = entry.key;
            CameraDescription camera = entry.value;
            return RadioListTile<int>(
              title: Text('Camera ${camera.name} (${camera.lensDirection.toString().split('.').last})'),
              value: index,
              groupValue: SettingsManager.selectedCameraIndex,
              onChanged: (int? value) {
                if (value != null) {
                  SettingsManager.selectedCameraIndex = value;
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
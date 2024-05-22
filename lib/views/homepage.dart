import 'package:drive_camfy/utils/settings_listener.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:drive_camfy/widgets/interface_buttons/camera_button.dart';
import 'package:drive_camfy/widgets/interface_buttons/g_sensor_button.dart';
import 'package:drive_camfy/widgets/interface_buttons/rotation_button.dart';
import 'package:drive_camfy/widgets/interface_buttons/settings_button.dart';
import 'package:drive_camfy/widgets/interface_buttons/sound_button.dart';
import 'package:flutter/material.dart';
import 'package:drive_camfy/widgets/camera_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late String _text;
  late bool _isAuto;
  late bool _isMuted;
  late bool _isRotationLocked;

  @override
  void initState() {
    super.initState();
    _isMuted = !SettingsManager.recordSoundEnabled;
    _isRotationLocked = SettingsManager.rotationLocked;
    _isAuto = SettingsManager.gSensorEnabled;
    _text = _isAuto ? 'auto' : 'manual';
    SettingsListener.startListening(_onSettingsChanged);
  }

  @override
  void dispose() {
    SettingsListener.stopListening(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged(String settingName) {
    setState(() {
      // Update UI status based on changes in settings
      if (settingName == SettingsManager.keyRecordSoundEnabled) {
        _isMuted = !SettingsManager.recordSoundEnabled;
      } else if (settingName == SettingsManager.keyRotationLocked) {
        _isRotationLocked = SettingsManager.rotationLocked;
      } else if (settingName == SettingsManager.keyGSensorEnabled) {
        _isAuto = SettingsManager.gSensorEnabled;
        _text = _isAuto ? 'auto' : 'manual';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = 60;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // CameraWidget jako główny widok
          CameraWidget(key: cameraWidgetKey),
          // Przyciski nad CameraWidget
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Przyciski po lewej stronie
                  Column(
                    children: [
                      CameraButton(
                        onPressed: () {},
                        size: iconSize,
                      ),
                      SizedBox(height: iconSize / 4),
                      RotationButton(
                        isRotationLocked: _isRotationLocked,
                        size: iconSize,
                        onPressed: () {
                          setState(() {
                            _isRotationLocked = !_isRotationLocked;
                            if (_isRotationLocked) {
                              SettingsManager.rotationLock();
                            } else {
                              SettingsManager.rotationUnlock();
                            }
                          });
                        },
                      ),
                      SizedBox(height: iconSize / 4),
                      SizedBox(height: iconSize),
                    ],
                  ),
                  // Przyciski po prawej stronie
                  Column(
                    children: [
                      SettingsButton(size: iconSize),
                      SizedBox(height: iconSize / 4),
                      GSensorButton(
                          text: _text,
                          size: iconSize,
                          onPressed: () {
                            bool temp = !_isAuto;
                            _text = temp ? 'manual' : 'auto';
                            setState(() {
                              _isAuto = temp;
                              SettingsManager.gSensorEnabled = _isAuto;
                            });
                          }),
                      SizedBox(height: iconSize / 4),
                      SoundButton(
                        isMuted: _isMuted,
                        size: iconSize,
                        onPressed: () {
                          setState(() {
                            _isMuted = !_isMuted;
                            SettingsManager.recordSoundEnabled = !_isMuted;
                          });
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

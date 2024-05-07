import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:drive_camfy/widgets/camera_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String _text = 'auto';
  bool _isAuto = true;
  bool _isFlashOn = false;
  bool _isRotationLocked = false;

  @override
  Widget build(BuildContext context) {
    double iconSize = 60;
    return Scaffold(
      body: Stack(
        children: [
          // CameraWidget jako główny widok
          const CameraWidget(),
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
                      Container(
                        color: Colors.black26,
                        child: SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: IconButton(
                            icon: _isFlashOn
                                ? const Icon(Icons.flash_on)
                                : const Icon(Icons.flash_off),
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                _isFlashOn =
                                    !_isFlashOn; // Odwrócenie stanu flash
                                SettingsManager.flashEnabled = _isFlashOn;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: iconSize / 4,
                        height: iconSize / 4,
                      ),
                      Container(
                        color: Colors.black26,
                        child: SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: IconButton(
                            icon: const Icon(Icons.camera_front),
                            color: Colors.white,
                            onPressed: () {},
                          ),
                        ),
                      ),
                      SizedBox(
                        width: iconSize / 4,
                        height: iconSize / 4,
                      ),
                      Container(
                        color: Colors.black26,
                        child: SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: IconButton(
                            icon: _isRotationLocked
                                ? const Icon(Icons.screen_lock_rotation)
                                : const Icon(Icons.screen_rotation),
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                _isRotationLocked =
                                    !_isRotationLocked; // Toggle rotation lock state
                                if (_isRotationLocked) {
                                  SettingsManager
                                      .rotationLock(); // Lock rotation
                                } else {
                                  SettingsManager
                                      .rotationUnlock(); // Unlock rotation
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Przyciski po prawej stronie
                  Column(
                    children: [
                      Container(
                        color: Colors.black26,
                        child: SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: IconButton(
                            icon: const Icon(Icons.settings),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pushNamed('/settings');
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: iconSize / 4,
                        height: iconSize / 4,
                      ),
                      SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: Container(
                          color: Colors.black26,
                          child: Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.warning),
                                color: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    _text = _isAuto ? 'manual' : 'auto';
                                    _isAuto = !_isAuto;
                                  });
                                },
                              ),
                              Text(
                                _text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: iconSize / 4,
                        height: iconSize / 4,
                      ),
                      SizedBox(
                        width: iconSize,
                        height: iconSize,
                      ),
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

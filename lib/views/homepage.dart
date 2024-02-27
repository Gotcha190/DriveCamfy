import 'dart:io';

import 'package:flutter/material.dart';
import 'package:drive_camfy/widgets/camera_widget.dart';

class HomePage extends StatelessWidget {
  final Directory saveDir;
  const HomePage({Key? key, required this.saveDir}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraWidget(saveDir: saveDir),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:drive_camfy/widgets/camera_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CameraWidget(),
    );
  }
}

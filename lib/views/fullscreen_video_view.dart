import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class FullscreenVideoView extends StatelessWidget {
  final File image;

  const FullscreenVideoView({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    String fileName = path.basename(image.path);
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: Center(
        child: Text('wideo'),
      ),
    );
  }
}

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class FullscreenImageView extends StatelessWidget {
  final File image;

  const FullscreenImageView({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    String fileName = path.basename(image.path);
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: Center(
        child: Image.file(image),
      ),
    );
  }
}

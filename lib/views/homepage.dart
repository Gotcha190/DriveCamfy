import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CameraController _controller;
  late Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  Future<String> _saveImage(XFile image) async {
    // Utwórz ścieżkę do katalogu docelowego, gdzie zostanie zapisane zdjęcie
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Skopiuj plik zrobionego zdjęcia do katalogu docelowego
    final File newImage = File(image.path);
    await newImage.copy(imagePath);

    return imagePath;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            final String savedImagePath = await _saveImage(image);
            print('Zdjęcie zapisane pod ścieżką: $savedImagePath');
          } catch (e) {
            print('Błąd podczas robienia i zapisywania zdjęcia: $e');
          }
        },
      ),
    );
  }
}
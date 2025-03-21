import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:drive_camfy/utils/media_tools/thumbnail_generator.dart';
import 'package:drive_camfy/utils/media_tools/file_selection_manager.dart';

Widget buildGalleryMediaWidget(
  BuildContext context,
  SelectableFile file,
  Set<SelectableFile> selectedFiles,
) {
  if (!File(file.file.path).existsSync()) {
    return const Center(child: Text("File does not exist"));
  }
  return ValueListenableBuilder<bool>(
    valueListenable: file.isSelectedNotifier,
    builder: (context, isSelected, _) {
      return Stack(
        children: [
          Positioned.fill(
            child: file.file.path.endsWith('.mp4')
                ? FutureBuilder<Uint8List?>(
                    future: ThumbnailsGenerator.generateThumbnail(file.file),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushNamed(
                            context,
                            '/error',
                            arguments: {
                              'title': 'Błąd generowania miniaturki',
                              'message':
                                  'Wystąpił błąd podczas generowania miniaturki dla pliku ${file.file.path}: ${snapshot.error}',
                            },
                          );
                        });
                        return const Icon(Icons.error);
                      } else {
                        return snapshot.hasData
                            ? Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : const SizedBox();
                      }
                    },
                  )
                : Image.file(
                    file.file,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
          if (isSelected)
            const Positioned(
              top: 8,
              left: 8,
              child: Icon(
                Icons.check_circle,
                color: Colors.blueAccent,
                size: 24,
              ),
            ),
          if (!isSelected && selectedFiles.isNotEmpty)
            const Positioned(
              top: 8,
              left: 8,
              child: Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey,
                size: 24,
              ),
            ),
        ],
      );
    },
  );
}

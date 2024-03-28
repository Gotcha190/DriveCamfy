import 'dart:io';
import 'package:drive_camfy/utils/media_tools/gallery_helper.dart';
import 'package:flutter/material.dart';

class MediaOptionsHandler {
  static void handleOption(
    String option,
    File file,
    BuildContext context,
    Function() onVideoDeleted,
  ) {
    switch (option) {
      case 'delete':
        _delete(
          file,
          context,
          onVideoDeleted,
        );
        break;
      // Dodaj obsługę innych opcji, jeśli potrzebujesz
      default:
        print('Wybrano opcję: $option');
    }
  }

  static void _delete(
    File file,
    BuildContext context,
    Function() onDelete,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete"),
          content: Text(
              "Are you sure you want to delete this ${file.path.endsWith('.jpg') ? 'photo' : 'video'}?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                file.path.endsWith('.jpg')
                    ? file.deleteSync()
                    : GalleryHelper.deleteVideo(file);
                Navigator.of(context).pop();
                onDelete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("File deleted"),
                  ),
                );
                Navigator.pop(context);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child:
                  const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';

class MediaOptionsHandler {
  static void handleOption(
    String option,
    File video,
    BuildContext context,
    Function() onVideoDeleted,
  ) {
    switch (option) {
      case 'delete':
        _deleteVideo(
          video,
          context,
          onVideoDeleted,
        );
        break;
      // Dodaj obsługę innych opcji, jeśli potrzebujesz
      default:
        print('Wybrano opcję: $option');
    }
  }

  static void _deleteVideo(
    File video,
    BuildContext context,
    Function() onDelete,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete"),
          content: const Text("Are you sure you want to delete this video?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                video.deleteSync();
                Navigator.of(context).pop();
                onDelete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Video deleted"),
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

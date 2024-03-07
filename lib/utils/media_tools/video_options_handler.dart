import 'dart:io';
import 'package:flutter/material.dart';

class VideoOptionsHandler {
  static void handleOption(String option, File video, BuildContext context) {
    switch (option) {
      case 'delete':
        _deleteVideo(video, context);
        break;
    // Dodaj obsługę innych opcji, jeśli potrzebujesz
      default:
        print('Wybrano opcję: $option');
    }
  }

  static void _deleteVideo(File video, BuildContext context) {
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
                // Tutaj możesz napisać kod usuwający wideo
                video.deleteSync();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Video deleted"),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
import 'package:drive_camfy/utils/media_tools/file_manager.dart';
import 'package:drive_camfy/utils/media_tools/file_selection_manager.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';

class MediaOptionsHandler {
  static void handleOption({
    required String option,
    required List<SelectableFile> files,
    required BuildContext context,
    required Function() onFilesDeleted,
  }) {
    switch (option) {
      case 'delete':
        _delete(
          files,
          context,
          onFilesDeleted,
        );
        break;
      case 'share':
        _share(files, context);
        break;
      case 'save':
        _saveToGallery(files, context);
        break;
      default:
        _navigateToErrorPage(
          context,
          'Unknown Option Selected',
          'The selected option "$option" is not recognized.',
        );
    }
  }

  static void _delete(
    List<SelectableFile> files,
    BuildContext context,
    Function() onFilesDeleted,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete"),
          content: Text(
              "Are you sure you want to delete the selected ${files.length > 1 ? 'files' : 'file'}?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await FileManager.deleteFiles(files);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  onFilesDeleted();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${files.length} file(s) deleted"),
                    ),
                  );
                  Navigator.pop(context);
                }
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

  static void _share(List<SelectableFile> files, BuildContext context) {
    final xFiles = files.map((file) => XFile(file.file.path)).toList();

    if (xFiles.isNotEmpty) {
      Share.shareXFiles(xFiles);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No files selected for sharing."),
        ),
      );
    }
  }

  static void _saveToGallery(
      List<SelectableFile> files, BuildContext context) async {
    for (var file in files) {
      if (file.file.path.endsWith('.mp4')) {
        await GallerySaver.saveVideo(file.file.path, albumName: 'Camera');
      } else {
        await GallerySaver.saveImage(file.file.path, albumName: 'Camera');
      }
    }
    if(!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${files.length} file(s) saved to gallery"),
      ),
    );
  }

  static void _navigateToErrorPage(
    BuildContext context,
    String title,
    String error,
  ) {
    Navigator.pushReplacementNamed(
      context,
      '/error',
      arguments: {
        'title': title,
        'error': error,
      },
    );
  }
}

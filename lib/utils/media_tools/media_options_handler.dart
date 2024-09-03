import 'package:drive_camfy/utils/media_tools/file_selection_manager.dart';
import 'package:flutter/material.dart';

class MediaOptionsHandler {
  static void handleOption(
    String option,
    List<SelectableFile> files, // Lista SelectableFile
    BuildContext context,
    Function() onFilesDeleted,
  ) {
    switch (option) {
      case 'delete':
        _delete(
          files, // Lista SelectableFile
          context,
          onFilesDeleted,
        );
        break;
      // Dodaj obsługę innych opcji, jeśli potrzebujesz
      default:
        print('Wybrano opcję: $option');
    }
  }

  static void _delete(
    List<SelectableFile> files, // Lista SelectableFile
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
              onPressed: () {
                for (var file in files) {
                  file.file.deleteSync(); // Usuwamy File
                }
                Navigator.of(context).pop();
                onFilesDeleted();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${files.length} file(s) deleted"),
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

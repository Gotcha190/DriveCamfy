import 'dart:io';
import 'package:drive_camfy/widgets/options_popup_menu_button.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class FullscreenImageView extends StatelessWidget {
  final File image;
  final Function() onDelete;

  const FullscreenImageView({super.key, required this.image, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    String fileName = path.basename(image.path);
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: Column(children: [
        Expanded(
          child: Image.file(image),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 50),
            IconButton(
              onPressed: () {
                ///TODO: Loading previous and next photo
              },
              icon: const Icon(Icons.chevron_left),
              iconSize: 40,
            ),
            const SizedBox(width: 40),
            IconButton(
              onPressed: () {

              },
              icon: const Icon(Icons.chevron_right),
              iconSize: 40,
            ),
            OptionsPopupMenuButton(
              file: image,
              onDelete: onDelete,
            ),
          ],
        ),
      ]),
    );
  }
}

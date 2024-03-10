import 'dart:io';
import 'package:flutter/material.dart';
import 'package:drive_camfy/utils/media_tools/media_options_handler.dart';

class OptionsPopupMenuButton extends StatelessWidget {
  final File video;
  final Function() onDelete;

  const OptionsPopupMenuButton({
    super.key,
    required this.video,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      iconSize: 40,
      onSelected: (String result) {
        MediaOptionsHandler.handleOption(
          result,
          video,
          context,
          onDelete,
        );
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'option1',
          child: Text('Option 1'),
        ),
        const PopupMenuItem<String>(
          value: 'option2',
          child: Text('Option 2'),
        ),
        const PopupMenuItem<String>(
          value: 'option3',
          child: Text('Option 3'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          textStyle: TextStyle(color: Colors.red),
          child: Text('Delete video'),
        ),
      ],
    );
  }
}

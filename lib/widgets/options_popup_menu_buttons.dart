import 'package:drive_camfy/utils/media_tools/file_selection_manager.dart';
import 'package:flutter/material.dart';
import 'package:drive_camfy/utils/media_tools/media_options_handler.dart';

class OptionsMenu extends StatelessWidget {
  final List<SelectableFile> files;
  final Function() onDelete;
  final double iconSize;

  const OptionsMenu({
    super.key,
    required this.files,
    required this.onDelete,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      iconSize: iconSize,
      onSelected: (String result) {
        MediaOptionsHandler.handleOption(
          result,
          files,
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
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

class OptionsPopupMenuButton extends StatelessWidget {
  final List<SelectableFile> files;
  final Function() onDelete;

  const OptionsPopupMenuButton({
    super.key,
    required this.files,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return OptionsMenu(
      files: files,
      onDelete: onDelete,
      iconSize: 40,
    );
  }
}

class OptionsFloatingActionButton extends StatelessWidget {
  final List<SelectableFile> files;
  final Function() onDelete;

  const OptionsFloatingActionButton({
    super.key,
    required this.files,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return OptionsMenu(
      files: files,
      onDelete: onDelete,
      iconSize: 40,
    );
  }
}
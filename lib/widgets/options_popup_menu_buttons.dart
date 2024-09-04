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
          option: result,
          files: files,
          context: context,
          onFilesDeleted: onDelete,
        );
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'save',
          child: Row(
            children: [
              Icon(Icons.save_alt),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
            ],
          ),
        ),
      ],
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
      ),
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

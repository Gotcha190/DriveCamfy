import 'dart:io';
import 'package:flutter/material.dart';

class SelectableFile {
  final File file;
  final ValueNotifier<bool> isSelectedNotifier = ValueNotifier<bool>(false);

  SelectableFile(this.file);

  void toggleSelection() {
    isSelectedNotifier.value = !isSelectedNotifier.value;
  }

  void setSelection(bool isSelected) {
    isSelectedNotifier.value = isSelected;
  }
}

class FileSelectionManager {
  final ValueNotifier<Set<SelectableFile>> selectedFilesNotifier;
  final ValueNotifier<bool> anySelectedNotifier;

  FileSelectionManager()
      : selectedFilesNotifier = ValueNotifier<Set<SelectableFile>>({}),
        anySelectedNotifier = ValueNotifier<bool>(false);

  void resetSelection() {
    selectedFilesNotifier.value.clear();
    anySelectedNotifier.value = false;
  }

  void toggleFileSelection(
      SelectableFile file, List<SelectableFile> currentTabFiles,
      {bool? selectAll}) {
    if (selectAll != null) {
      for (var f in currentTabFiles) {
        f.setSelection(selectAll);
        if (selectAll) {
          selectedFilesNotifier.value.add(f);
        } else {
          selectedFilesNotifier.value.remove(f);
        }
      }
    } else {
      file.toggleSelection();
      if (file.isSelectedNotifier.value) {
        selectedFilesNotifier.value.add(file);
      } else {
        selectedFilesNotifier.value.remove(file);
      }
    }

    selectedFilesNotifier.notifyListeners();
    anySelectedNotifier.value = selectedFilesNotifier.value.isNotEmpty;
  }

  bool areAllFilesSelected(List<SelectableFile> currentFiles) {
    return currentFiles.isNotEmpty &&
        currentFiles.every((file) => file.isSelectedNotifier.value);
  }

  void dispose() {
    selectedFilesNotifier.dispose();
    anySelectedNotifier.dispose();
  }
}

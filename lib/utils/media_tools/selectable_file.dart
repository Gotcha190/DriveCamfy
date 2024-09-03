import 'package:flutter/material.dart';
import 'dart:io';

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
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AppDirectory {
  static AppDirectory? _instance;
  late Directory _saveDir;

  factory AppDirectory() {
    _instance ??= AppDirectory._();
    return _instance!;
  }

  AppDirectory._() {
    init();
  }

  Directory get directory => _saveDir;

  Future<void> init() async {
    _saveDir = await _getDirectory();
  }

  Future<Directory> _getDirectory() async {
    Directory? exportDir;

    if (Platform.isAndroid) {
      exportDir = Directory('/storage/emulated/0/Documents');
    }

    exportDir ??= await getExternalStorageDirectory();

    exportDir ??= await getApplicationDocumentsDirectory();

    exportDir = Directory('${exportDir.path}/DriveCamfy');
    await exportDir.create(recursive: true);

    await Directory('${exportDir.path}/images').create(recursive: true);
    await Directory('${exportDir.path}/videos').create(recursive: true);
    await Directory('${exportDir.path}/thumbnails').create(recursive: true);
    await Directory('${exportDir.path}/emergency').create(recursive: true);

    return exportDir;
  }

  String get images => path.join(_saveDir.path, 'images');
  String get videos => path.join(_saveDir.path, 'videos');
  String get thumbnails => path.join(_saveDir.path, 'thumbnails');
  String get emergency => path.join(_saveDir.path, 'emergency');
}

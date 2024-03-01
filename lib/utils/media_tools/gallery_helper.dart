import 'dart:io';
import 'package:drive_camfy/utils/app_directory.dart';

class GalleryHelper {
  static Future<List<File>> getImages() async {
    final List<File> images = [];

    try {
      final Directory imagesDirectory = Directory(AppDirectory().images);
      if (await imagesDirectory.exists()) {
        images.addAll(await imagesDirectory
            .list()
            .where((entity) => entity is File && entity.lengthSync() > 0)
            .map<File>((entity) => File(entity.path))
            .toList());
      }
    } catch (e) {
      print('Błąd podczas odczytu katalogu obrazów: $e');
    }
    return images;
  }

  static Future<List<File>> getVideos() async {
    final List<File> videos = [];

    try {
      final Directory videosDirectory = Directory(AppDirectory().videos);
      if (await videosDirectory.exists()) {
        videos.addAll(await videosDirectory
            .list()
            .where((entity) => entity is File && entity.lengthSync() > 0)
            .map<File>((entity) => File(entity.path))
            .toList());
      }
    } catch (e) {
      print('Błąd podczas odczytu katalogu filmów: $e');
    }
    return videos;
  }
}

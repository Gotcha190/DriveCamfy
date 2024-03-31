import 'dart:io';
import 'package:path/path.dart' as path;
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

  static Future<List<File>> getEmergency() async {
    final List<File> emergency = [];

    try {
      final Directory emergencyDirectory = Directory(AppDirectory().emergency);
      if (await emergencyDirectory.exists()) {
        emergency.addAll(await emergencyDirectory
            .list()
            .where((entity) => entity is File && entity.lengthSync() > 0)
            .map<File>((entity) => File(entity.path))
            .toList());
      }
    } catch (e) {
      print('Błąd podczas odczytu katalogu filmów: $e');
    }
    return emergency;
  }

  static Future<void> deleteVideo(File video) async {
    try {
      final String videoName = path.basenameWithoutExtension(video.path);

      // Delete video
      await video.delete();

      // Check if thumbnail exist
      final File thumbnailFile =
          File('${AppDirectory().thumbnails}/$videoName.jpg');
      if (await thumbnailFile.exists()) {
        // Delete thumbnail
        await thumbnailFile.delete();
      }
    } catch (e) {
      print('Błąd podczas usuwania filmu: $e');
    }
  }
}

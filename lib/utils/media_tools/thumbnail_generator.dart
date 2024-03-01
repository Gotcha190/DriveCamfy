import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:drive_camfy/utils/app_directory.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailsGenerator {
  static final Map<File, Future<Uint8List?>> thumbnails = {};

  static Future<Uint8List?> generateThumbnail(File videoFile) async {
    final String thumbnailPath = _getThumbnailPath(videoFile);

    if (await File(thumbnailPath).exists()) {
      return await File(thumbnailPath).readAsBytes();
    } else {
      thumbnails[videoFile] = _generateThumbnail(videoFile);
      return thumbnails[videoFile];
    }
  }

  static String _getThumbnailPath(File videoFile) {
    final thumbnailDir = AppDirectory().thumbnails;
    final videoFileName = path.basenameWithoutExtension(videoFile.path);
    return path.join(thumbnailDir, '$videoFileName.jpg');
  }

  static Future<Uint8List?> _generateThumbnail(File file) async {
    try {
      print("generating!!!");
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.JPEG,
        quality: 95,
        maxHeight: 100,
        maxWidth: 100,
      );

      // Save thumbnail to thumbnails directory
      if (thumbnail != null) {
        final thumbnailDir = AppDirectory().thumbnails;
        final thumbnailPath = path.join(
            thumbnailDir, '${path.basenameWithoutExtension(file.path)}.jpg');
        await File(thumbnailPath).writeAsBytes(thumbnail);
      }

      return thumbnail;
    } catch (e) {
      print("ERROR: Failed to generate thumbnail: $e");
      return null;
    }
  }
}

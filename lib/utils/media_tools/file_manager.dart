import 'dart:io';
import 'package:drive_camfy/utils/app_directory.dart';
import 'package:drive_camfy/utils/media_tools/file_selection_manager.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:drive_camfy/utils/media_tools/gallery_helper.dart';

class FileManager {

  /// Saves the image file to the specified directory with a formatted name.
  static Future<void> saveImage(XFile tempFile, DateTime startTime, String directory) async {
    String formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(startTime);
    final String imagePath = '$directory/image_$formattedDate.jpg';

    try {
      await tempFile.saveTo(imagePath);
      File(tempFile.path).delete();
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  /// Saves the video file to the specified directory with a formatted name.
  static Future<void> saveVideo(XFile tempFile, DateTime startTime, String directory) async {
    String formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(startTime);
    final String videoPath = '$directory/video_$formattedDate.mp4';

    try {
      await tempFile.saveTo(videoPath);
      // Optionally delete the temporary file after saving
      File(tempFile.path).delete();
    } catch (e) {
      print('Error saving video: $e');
    }
  }

  /// Deletes a single file. If it's a video file, also deletes its associated thumbnail.
  static Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();

        // Check if it's a video file
        if (file.path.endsWith('.mp4')) {
          // Remove the corresponding thumbnail
          String thumbnailPath = _getThumbnailPath(file);
          File thumbnailFile = File(thumbnailPath);

          if (await thumbnailFile.exists()) {
            await thumbnailFile.delete();
            print('Miniatura usunięta: $thumbnailPath');
          }
        }
      }
    } catch (e) {
      print('Błąd podczas usuwania pliku: $e');
    }
  }

  /// Delete List of SelectableFiles
  static Future<void> deleteFiles(List<SelectableFile> files) async {
    for (SelectableFile selectableFile in files) {
      await deleteFile(selectableFile.file);
    }
  }

  /// Deletes old recordings if they exceed the specified limit.
  static Future<void> deleteOldRecordings(int recordCount) async {
    List<File>? existingClips = await GalleryHelper.getVideos();

    if (existingClips.length > recordCount) {
      existingClips.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

      for (int i = 0; i < existingClips.length - recordCount; i++) {
        try {
          await existingClips[i].delete();
        } catch (e) {
          print('Error deleting old recording: $e');
        }
      }
    }
  }

  /// Generates the corresponding thumbnail path for a given video file.
  static String _getThumbnailPath(File videoFile) {
    String videoFileName = videoFile.uri.pathSegments.last;
    String thumbnailFileName = videoFileName.replaceAll('.mp4', '.jpg');
    return '${AppDirectory().thumbnails}/$thumbnailFileName';
  }
}

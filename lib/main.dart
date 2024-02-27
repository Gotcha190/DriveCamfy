import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:drive_camfy/views/fullscreen_image_view.dart';
import 'package:drive_camfy/views/gallery_view.dart';
import 'package:drive_camfy/views/homepage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory saveDir = await getDirectory();
  runApp(MyApp(saveDir: saveDir));
}

Future<Directory> getDirectory() async {
  Directory? exportDir;
  if (Platform.isAndroid &&
      (await DeviceInfoPlugin().androidInfo).version.sdkInt <= 29) {
    while (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
  }
  if (Platform.isAndroid) {
    exportDir = Directory('/storage/emulated/0/Documents');
    try {
      exportDir.existsSync();
    } catch (e) {
      exportDir = null;
    }
  }
  if (exportDir == null) {
    if (Platform.isAndroid) {
      exportDir = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      exportDir = await getApplicationDocumentsDirectory();
    } else {
      exportDir = await getDownloadsDirectory();
    }
  }
  exportDir =
      exportDir != null ? Directory('${exportDir.path}/DriveCamfy') : null;
  exportDir?.createSync(recursive: true);

  if (exportDir != null) {
    Directory('${exportDir.path}/images').createSync(recursive: true);
    Directory('${exportDir.path}/videos').createSync(recursive: true);
  }

  return exportDir!;
}

class MyApp extends StatelessWidget {
  final Directory saveDir;
  const MyApp({super.key, required this.saveDir});
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        title: 'DriveCamfy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
          useMaterial3: true,
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                  builder: (context) => HomePage(
                        saveDir: saveDir,
                      ));
            case '/gallery':
              final Map<String, List<File>>? arguments =
                  settings.arguments as Map<String, List<File>>?;
              final List<File> images = arguments?['images'] ?? [];
              final List<File> videos = arguments?['videos'] ?? [];
              return MaterialPageRoute(
                builder: (context) =>
                    GalleryView(images: images, videos: videos),
              );
            case '/fullscreenImage':
              final File? image = settings.arguments as File?;
              return MaterialPageRoute(
                builder: (context) => FullscreenImageView(image: image!),
              );
            default:

              ///TODO:Do PageNotFound
              return null;
          }
        },
      );
    });
  }
}

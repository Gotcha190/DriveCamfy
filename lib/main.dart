import 'dart:io';
import 'package:drive_camfy/utils/app_directory.dart';
import 'package:drive_camfy/utils/settings_manager.dart';
import 'package:drive_camfy/views/fullscreen_image_view.dart';
import 'package:drive_camfy/views/fullscreen_video_view.dart';
import 'package:drive_camfy/views/gallery_view.dart';
import 'package:drive_camfy/views/homepage.dart';
import 'package:drive_camfy/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDirectory().init();
  await SettingsManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
                builder: (context) => const HomePage(),
              );
            case '/settings':
              return MaterialPageRoute(
                builder: (context) => const SettingsView(),
              );
            case '/gallery':
              return MaterialPageRoute(
                builder: (context) => const GalleryView(),
              );
            case '/fullscreenImage':
              final Map<String, dynamic> arguments =
                  settings.arguments as Map<String, dynamic>;
              final List<File>? images = arguments['file'] as List<File>?;
              final int index = arguments['index'];
              final Function() onDelete = arguments['onDelete'] as Function();
              return MaterialPageRoute(
                builder: (context) => FullscreenImageView(
                  images: images!,
                  imgIndex: index,
                  onDelete: onDelete,
                ),
              );
            case '/fullscreenVideo':
              final Map<String, dynamic> arguments =
                  settings.arguments as Map<String, dynamic>;
              final List<File>? videos = arguments['file'] as List<File>?;
              final int index = arguments['index'];
              final Function() onDelete = arguments['onDelete'] as Function();
              return MaterialPageRoute(
                builder: (context) => FullscreenVideoView(
                  videos: videos!,
                  vidIndex: index,
                  onDelete: onDelete,
                ),
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

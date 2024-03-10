import 'dart:io';
import 'package:drive_camfy/utils/app_directory.dart';
import 'package:drive_camfy/views/fullscreen_image_view.dart';
import 'package:drive_camfy/views/fullscreen_video_view.dart';
import 'package:drive_camfy/views/gallery_view.dart';
import 'package:drive_camfy/views/homepage.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDirectory().init();
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
            case '/gallery':
              return MaterialPageRoute(
                builder: (context) => const GalleryView(),
              );
            case '/fullscreenImage':
              final Map<String, dynamic> arguments =
                  settings.arguments as Map<String, dynamic>;
              final File? image = arguments['file'] as File?;

              ///TODO: Add delete functionality
              final Function() onDelete = arguments['onDelete'] as Function();
              return MaterialPageRoute(
                builder: (context) => FullscreenImageView(image: image!),
              );
            case '/fullscreenVideo':
              final Map<String, dynamic> arguments =
                  settings.arguments as Map<String, dynamic>;
              final File? video = arguments['file'] as File?;
              final Function() onDelete = arguments['onDelete'] as Function();
              return MaterialPageRoute(
                builder: (context) => FullscreenVideoView(
                  video: video!,
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

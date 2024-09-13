// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController {
  final Set<Permission> _permissionsToRequest = {};
  final Set<Permission> _permissionsMissing = {};

  void _navigateTo(BuildContext context, String route,
      [Map<String, dynamic>? arguments]) {
    if (context.mounted) {
      Navigator.pushReplacementNamed(
        context,
        route,
        arguments: arguments,
      );
    }
  }

  Future<Set<Permission>> checkPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.location,
      if (Platform.isAndroid &&
          (await DeviceInfoPlugin().androidInfo).version.sdkInt <= 29)
        Permission.storage,
    ];

    _permissionsToRequest.clear();
    for (final permission in permissions) {
      final status = await permission.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        _permissionsToRequest.add(permission);
      }
    }
    return _permissionsToRequest;
  }

  Future<void> requestPermissions(
    BuildContext context,
    Set<Permission> permissionsToRequest,
  ) async {
    _permissionsMissing.clear();
    for (final permission in permissionsToRequest) {
      final status = await permission.request();
      if (status.isDenied) _permissionsMissing.add(permission);
      if (status.isPermanentlyDenied) {
        _navigateTo(
          context,
          '/error',
          {
            'title': 'Permission error',
            'error': 'The app needs certain permissions to function properly. '
                'Please grant them in the app settings. '
                'Missing permissions: ${permissionsToRequest.map((p) => p.toString()).join(', ')}',
          },
        );
        return;
      }
    }

    if (_permissionsMissing.isEmpty) {
      _navigateTo(context, '/home');
    } else {
      _navigateTo(context, '/');
    }
  }
}

class PermissionCheckPage extends StatelessWidget {
  PermissionCheckPage({super.key});

  final PermissionController _permissionController = PermissionController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<Permission>>(
      future: _permissionController.checkPermissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          final permissionsNeeded = snapshot.data!;
          if (permissionsNeeded.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/home');
            });
            return const SizedBox();
          } else {
            _permissionController.requestPermissions(
                context, permissionsNeeded);
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(
            context,
            '/error_page',
            arguments: {
              'title': 'Permission error',
              'error':
                  'Error occurred while checking permissions in $runtimeType',
            },
          );
        });
        return const SizedBox();
      },
    );
  }
}

import 'package:flutter/material.dart';

class CameraButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;

  const CameraButton({super.key, required this.onPressed, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          icon: const Icon(Icons.camera),
          color: Colors.white,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

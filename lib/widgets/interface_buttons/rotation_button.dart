import 'package:flutter/material.dart';

class RotationButton extends StatelessWidget {
  final bool isRotationLocked;
  final VoidCallback onPressed;
  final double size;

  const RotationButton({
    super.key,
    required this.isRotationLocked,
    required this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          icon: Icon(
            isRotationLocked
                ? Icons.screen_lock_rotation
                : Icons.screen_rotation,
          ),
          color: Colors.white,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

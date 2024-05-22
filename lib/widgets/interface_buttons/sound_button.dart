import 'package:flutter/material.dart';

class SoundButton extends StatelessWidget {
  final double size;
  final bool isMuted;
  final VoidCallback onPressed;

  const SoundButton({
    super.key,
    required this.size,
    required this.isMuted,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          icon: isMuted ? const Icon(Icons.mic_off) : const Icon(Icons.mic),
          color: Colors.white,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

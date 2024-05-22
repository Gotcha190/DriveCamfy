import 'package:flutter/material.dart';

class GSensorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double size;

  const GSensorButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        color: Colors.black26,
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.warning),
              color: Colors.white,
              onPressed: onPressed,
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  final double size;

  const SettingsButton({
    super.key,
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
          icon: const Icon(Icons.settings),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
      ),
    );
  }
}

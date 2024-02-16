import 'package:flutter/material.dart';

class CameraButtonsWidget extends StatelessWidget {
  const CameraButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Transform.translate(
              offset: const Offset(60, 0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerRight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(-60, 0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.filter,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(30),
              ),
              child: const Icon(
                Icons.circle,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

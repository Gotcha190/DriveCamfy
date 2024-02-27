import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';

class ConcaveButton extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final double arcHeight;
  final bool isRightButton;
  final VoidCallback onPressed;

  const ConcaveButton({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    required this.arcHeight,
    required this.isRightButton,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: isRightButton ? 1 : 3,
      child: Arc(
        arcType: ArcType.CONVEY,
        height: arcHeight,
        child: SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.5),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
            ),
            child:RotatedBox(quarterTurns: isRightButton ? 3 : 1, child: child),
          ),
        ),
      ),
    );
  }
}

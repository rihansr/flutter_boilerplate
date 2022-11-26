import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  const DashedLine({Key? key, this.spacing, this.dashColor})
      : super(key: key);

  final EdgeInsetsGeometry? spacing;
  final Color? dashColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: DashedLinePainter(
      color: dashColor ?? Theme.of(context).dividerColor,
    ));
  }
}

class DashedLinePainter extends CustomPainter {
  DashedLinePainter({required this.color});

  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 4, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

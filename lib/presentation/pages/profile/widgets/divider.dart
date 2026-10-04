import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomPaint(
        painter: MyPainter(),
        size: Size(MediaQuery.of(context).size.width, 1.2),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();

    // Path number 1

    paint.color = const Color(0xff707070);
    path = Path();
    path.lineTo(size.width * 0.1, size.height);
    path.cubicTo(size.width * 0.09, size.height, size.width * 0.08, size.height, size.width * 0.06,
        size.height * 0.97);
    path.cubicTo(size.width * 0.05, size.height * 0.94, size.width * 0.04, size.height * 0.9,
        size.width * 0.03, size.height * 0.86);
    path.cubicTo(size.width * 0.02, size.height * 0.81, size.width * 0.01, size.height * 0.76,
        size.width * 0.01, size.height * 0.69);
    path.cubicTo(0, size.height * 0.63, 0, size.height * 0.57, 0, size.height / 2);
    path.cubicTo(0, size.height * 0.43, 0, size.height * 0.37, size.width * 0.01, size.height * 0.31);
    path.cubicTo(size.width * 0.01, size.height * 0.24, size.width * 0.02, size.height * 0.19,
        size.width * 0.03, size.height * 0.14);
    path.cubicTo(size.width * 0.04, size.height * 0.1, size.width * 0.05, size.height * 0.06,
        size.width * 0.06, size.height * 0.03);
    path.cubicTo(size.width * 0.08, size.height * 0.01, size.width * 0.09, 0, size.width * 0.1, 0);
    path.cubicTo(size.width * 0.1, 0, size.width * 0.9, 0, size.width * 0.9, 0);
    path.cubicTo(
        size.width * 0.91, 0, size.width * 0.92, size.height * 0.01, size.width * 0.94, size.height * 0.03);
    path.cubicTo(size.width * 0.95, size.height * 0.06, size.width * 0.96, size.height * 0.1,
        size.width * 0.97, size.height * 0.14);
    path.cubicTo(size.width * 0.98, size.height * 0.19, size.width, size.height * 0.24, size.width,
        size.height * 0.31);
    path.cubicTo(size.width, size.height * 0.37, size.width, size.height * 0.43, size.width, size.height / 2);
    path.cubicTo(
        size.width, size.height * 0.57, size.width, size.height * 0.63, size.width, size.height * 0.69);
    path.cubicTo(size.width, size.height * 0.76, size.width * 0.98, size.height * 0.81, size.width * 0.97,
        size.height * 0.86);
    path.cubicTo(size.width * 0.96, size.height * 0.9, size.width * 0.95, size.height * 0.94,
        size.width * 0.94, size.height * 0.97);
    path.cubicTo(
        size.width * 0.92, size.height, size.width * 0.91, size.height, size.width * 0.9, size.height);
    path.cubicTo(size.width * 0.9, size.height, size.width * 0.1, size.height, size.width * 0.1, size.height);
    path.cubicTo(size.width * 0.1, size.height, size.width * 0.1, size.height, size.width * 0.1, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

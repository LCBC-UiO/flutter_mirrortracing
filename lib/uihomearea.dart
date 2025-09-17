


import 'package:flutter/material.dart';

class HomeArea extends StatelessWidget {
  final Color innerColor;
  final Color outerColor;
  final double innerRadius;
  final double outerRadius;

  HomeArea({
    Key? key,
    Color? innerColor,
    this.outerColor = Colors.transparent,
    required this.innerRadius,
    required this.outerRadius,
  }) : innerColor = innerColor ?? Colors.green.withAlpha(64), super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CustomPaint(painter: _FinishAreaCircle(width: innerRadius, color: innerColor)),
        CustomPaint(painter: _FinishAreaCircle(width: outerRadius, color: outerColor)),
      ],
    );
  }
}

class _FinishAreaCircle extends CustomPainter {
  final double width;
  final Color color;

  late final Paint _paint = Paint()
    ..color = color
    ..strokeWidth = 10.0
    ..style = PaintingStyle.fill;

  _FinishAreaCircle({required this.width, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
     canvas.drawCircle(Offset(0.0, 0.0), width, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

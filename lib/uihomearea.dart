


import 'package:flutter/cupertino.dart';

class PositionedHomeArea extends StatelessWidget {
  final double x;
  final double y;
  final Color color;
  final double radius;
  
  PositionedHomeArea({
    @required this.x,
    @required this.y,
    @required this.color,
    @required this.radius,
  });     

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: CustomPaint(painter: _FinishAreaCircle(width: radius, color: color)),
    );
  }}

class _FinishAreaCircle extends CustomPainter {
  final double width;
  final Color color;

  Paint _paint;

  _FinishAreaCircle({@required this.width, @required this.color}) {
    _paint = Paint()
      ..color = color
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
     canvas.drawCircle(Offset(0.0, 0.0), width, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
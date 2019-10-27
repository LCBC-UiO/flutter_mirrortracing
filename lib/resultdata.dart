import 'package:flutter/foundation.dart';
import 'package:mirrortask/imgevaluation.dart';
import 'package:mirrortask/pentrajectory.dart';

class ResultData {
  final String userId;
  final DateTime date;
  final ImgEvaluation imgEval;
  final PenTrajectory trajectory;
  final double canvasWidth;

  ResultData({
    @required this.userId,
    @required this.date,
    @required this.imgEval,
    @required this.trajectory,
    @required this.canvasWidth,
  });
}

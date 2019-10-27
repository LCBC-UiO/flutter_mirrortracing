import 'package:flutter/foundation.dart';

/*----------------------------------------------------------------------------*/

class PenTrajectory {
  List<List<_PenTrajectoryElement>> _t = [];
  DateTime _startTime;

  void newLine() => _t.add([]);

  void add(double x, double y) {
    final now = DateTime.now();
    _startTime ??= now;
    _t.last.add(
      _PenTrajectoryElement(
        posX: x.round(), 
        posY: y.round(), 
        timeMs: now.difference(_startTime).inMilliseconds,
      )
    );
  }

  List<List<_PenTrajectoryElement>> get trajectory => _t;

  int get numContinuousLines => _t.length;
  int get totalTime => _t.last.last.timeMs;
  int get drawingTime {
    int sum = 0;
    _t.forEach( (e) {
       sum += e.last.timeMs - e.first.timeMs;
    });
    return sum;
  }
  String toJsonStr() {
    var r = new StringBuffer();
    r.write("[");
    for (int i = 0; i < _t.length; i++) {
      i == 0 ? r.write("[") : r.write(",[");
      for (int j = 0; j < _t[i].length; j++) {
        if (j > 0) {
          r.write(",");
        }
        r.write("[${_t[i][j].posX},${_t[i][j].posY},${_t[i][j].timeMs}]");
      }
      r.write("]");
    }
    r.write("]");
    return r.toString();
  }
}

/*----------------------------------------------------------------------------*/

class _PenTrajectoryElement{
  final int posX;
  final int posY;
  final int timeMs;

  _PenTrajectoryElement({
    @required this.posX,
    @required this.posY,
    @required this.timeMs,
  });
}
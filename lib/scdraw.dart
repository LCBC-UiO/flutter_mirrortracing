
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirrortask/helper.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:mirrortask/settings.dart';

/*----------------------------------------------------------------------------*/

class DrawScreen extends StatefulWidget {
  final String userId;
  final int drawingWidth;

  DrawScreen({
    @required this.userId,
    @required this.drawingWidth,
  });

  @override
  State<StatefulWidget> createState() => _DrawScreenState();
}

class _ImgEvaluation {
  final img.Image drawing;
  final int numStrokes;
  final Duration time;

  _ImgEvaluation({
    @required this.drawing,
    @required this.numStrokes,
    @required this.time,
  });
}

enum _DrawState {
  Init,
  Recording,
  Finished,
}

/*----------------------------------------------------------------------------*/

class _DrawScreenState extends State<DrawScreen> {
  PainterController _controller;
  Image _finishedDrawing;
  img.Image _objMask;
  _DrawState _state;
  Future<Map<String, img.Image>> _fLoadImg; 

  static const String kStrObjMask = "ObjMask";
  static const String kStrObjBoundary = "ObjBoundary";


  @override
  void initState() {
    _state = _DrawState.Init;
    super.initState();
    _controller = _newController();
    _fLoadImg = _loadImg();
  }

  PainterController _newController() {
    PainterController controller = PainterController();

    controller.thickness = 2.0;
    controller.drawColor = Colors.blue;
    controller.backgroundColor = Colors.transparent;
    return controller;
  }
  Future<Map<String, img.Image>> _loadImg() async {
    final data = (await rootBundle.load('assets/star2.png'));
    final buffer = data.buffer;
    List<int> bytes = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    img.Image objectRaw = img.decodePng(bytes);
    // create big canvas  - we will scale later
    img.Image canvasUnscaled = (){
      final int cw = (objectRaw.width / LcSettings().getDouble(LcSettings.OBJECT_SIZE_DBL)).round();
      img.Image c = img.Image(cw, cw);
      // set transparent
      c.fill(0xff000000);
      return c;
    }();
    // paste object into canvas
    assert(canvasUnscaled.width >=  objectRaw.width);
    final inset = ((canvasUnscaled.width -  objectRaw.width) / 2).round();
    canvasUnscaled = img.copyInto(canvasUnscaled, objectRaw, dstX: inset, dstY: inset);
    // scale
    final img.Image canvasScaled = img.copyResize(canvasUnscaled, width: widget.drawingWidth, height: widget.drawingWidth, interpolation: img.Interpolation.cubic);
    // create mask - use whatever is in the green or blue channel
    img.Image objMask = img.Image(canvasScaled.width, canvasScaled.width);
    for (int j = 0; j < canvasScaled.height; j++) {
      for (int i = 0; i < canvasScaled.width; i++) {
        final bool hasBlue  = img.getBlue(canvasScaled.getPixelSafe(i, j)) > 0;
        final bool hasGreen = img.getGreen(canvasScaled.getPixelSafe(i, j)) > 0;
        // set to black
        objMask.setPixelSafe(i, j,  (hasBlue || hasGreen) ? 0xff000000 : 0);
      }
    }
    // create visualization of boundaries - use blue channel
    img.Image objBoundary = img.Image(canvasScaled.width, canvasScaled.width);
    for (int j = 0; j < canvasScaled.height; j++) {
      for (int i = 0; i < canvasScaled.width; i++) {
        final int alpha  = img.getBlue(canvasScaled.getPixelSafe(i, j));
        // convert blue channel to alpha - whole image has black color
        objBoundary.setPixelSafe(i, j,  img.getColor(0, 0, 0, alpha));
      }
    }
    return {
      kStrObjMask:     objMask,
      kStrObjBoundary: objBoundary,
    };
  }

  // Widget _getDrawArea(BuildContext context) {
  //   return Center(
  //     child: SizedBox(
  //           height: widget.drawingWidth.toDouble(),
  //           width: widget.drawingWidth.toDouble(),
  //           child: Stack(
  //             children: <Widget>[
  //               snapshot.data,
  //               Painter(_controller),
  //             ],
  //           ),
  //         );
  //       }
  //     )
  //   );
  // }

  Future<_ImgEvaluation> _getEvaluatedImage({
    @required int numStrokes,
    @required Duration time,
    @required img.Image objMask,
    @required img.Image drawing,
    }) async {
    return _ImgEvaluation(
      drawing: drawing,
      numStrokes: numStrokes,
      time: time,
    );
  }

  void _cbOnStrokeStart() {
    if (_state == _DrawState.Init) {
      setState(() {
        _state = _DrawState.Recording;
      });
    }
    // TODO: update numStrokes and timeend
  }

  void _cbOnStrokeEnd() {
    // TODO: update numStrokes and timeend
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> mstack = [];
    if (_state == _DrawState.Recording) {
      mstack.add(
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  color: Colors.red,
                ),
                Text(
                  "REC",
                  style: TextStyle(color: Colors.red),
                )
              ]
            ),
          )
        ),
      );
    }

    mstack.add(
      Align(
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CupertinoButton(
              //color: Theme.of(context).accentColor,
              onPressed: _state == _DrawState.Init ? null : _showRestartDialog,
              child: Text("Reset"),
            ),
            CupertinoButton(
              //color: Theme.of(context).accentColor,
              onPressed: () async {
                img.Image tmp = img.decodeImage(await _controller.finish().toPNG());
                _finishedDrawing = Image.memory(img.encodePng(tmp));
                  setState(() {
                    _state = _DrawState.Finished;
                });
              },
              child: Text("Done"),
            ),
          ]
        )
      ),
    );
    mstack.add(
      Center(
        child: FutureBuilder<Map<String, img.Image>>(
          future: _fLoadImg,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            _objMask = snapshot.data[kStrObjMask];
            return SizedBox(
              width: widget.drawingWidth.toDouble(),
              height: widget.drawingWidth.toDouble(),
              child: Stack(
                children: <Widget>[
                  Image.memory(img.encodePng(snapshot.data[kStrObjBoundary])),
                  Painter(
                    _controller,
                    onPanStart: _cbOnStrokeStart,
                    onPanEnd: _cbOnStrokeEnd,
                  ),
                ],
              )
            );
          }
        ),
      )
    );
    mstack.add(
      Align(
        alignment: Alignment.topLeft,
        child: _finishedDrawing != null ? FractionallySizedBox(widthFactor: 0.3, child: _finishedDrawing,) : Text(""),
      ),
    );

    return LcScaffold(
      actions: <Widget>[
        LcScaffold.getActionReset(context)
      ],
      body: Stack(
        children: mstack
      )
    );
  }


  _showRestartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text("Reset drawing?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true, 
            child: Text("Reset"),
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => DrawScreen(userId: widget.userId, drawingWidth: widget.drawingWidth),
                )
              );
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true, 
            child: Text("Back"),
            isDestructiveAction: false,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}




















class Painter extends StatefulWidget {
  final PainterController painterController;
  final Function onPanStart;
  final Function onPanEnd;

  Painter(PainterController painterController, {
    @required this.onPanStart,
    @required this.onPanEnd,
  })
      : this.painterController = painterController,
        super(key: new ValueKey<PainterController>(painterController));

  @override
  _PainterState createState() => new _PainterState();
}

class _PainterState extends State<Painter> {
  bool _finished;

  @override
  void initState() {
    super.initState();
    _finished = false;
    widget.painterController._widgetFinish = _finish;
  }

  Size _finish() {
    setState(() {
      _finished = true;
    });
    return context.size;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = new CustomPaint(
      willChange: true,
      painter: new _PainterPainter(widget.painterController._pathHistory,
          repaint: widget.painterController),
    );
    child = new ClipRect(child: child);
    if (!_finished) {
      child = new GestureDetector(
        child: child,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
      );
    }
    return new Container(
      child: child,
      width: double.infinity,
      height: double.infinity,
    );
  }

  void _onPanStart(DragStartDetails start) {
    Offset pos = (context.findRenderObject() as RenderBox)
        .globalToLocal(start.globalPosition);
    widget.painterController._pathHistory.add(pos);
    widget.painterController._notifyListeners();
    widget.onPanStart();
  }

  void _onPanUpdate(DragUpdateDetails update) {
    Offset pos = (context.findRenderObject() as RenderBox)
        .globalToLocal(update.globalPosition);
    widget.painterController._pathHistory.updateCurrent(pos);
    widget.painterController._notifyListeners();
  }

  void _onPanEnd(DragEndDetails end) {
    widget.painterController._pathHistory.endCurrent();
    widget.painterController._notifyListeners();
    widget.onPanEnd();
  }
}

class _PainterPainter extends CustomPainter {
  final _PathHistory _path;

  _PainterPainter(this._path, {Listenable repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    _path.draw(canvas, size);
  }

  @override
  bool shouldRepaint(_PainterPainter oldDelegate) {
    return true;
  }
}












class PictureDetails {
  final ui.Picture picture;
  final int width;
  final int height;

  const PictureDetails(this.picture, this.width, this.height);

  Future<ui.Image> toImage() async {
    return picture.toImage(width, height);
  }

  Future<Uint8List> toPNG() async {
    return (await (await toImage()).toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }
}


class _PathHistory {
  List<MapEntry<Path, Paint>> _paths;
  Paint currentPaint;
  Paint _backgroundPaint;
  bool _inDrag;


  _PathHistory() {
    _paths = new List<MapEntry<Path, Paint>>();
    _inDrag = false;
    _backgroundPaint = new Paint();
  }

  void setBackgroundColor(Color backgroundColor) {
    _backgroundPaint.color = backgroundColor;
  }

  void undo() {
    if (!_inDrag) {
      _paths.removeLast();
    }
  }

  void clear() {
    if (!_inDrag) {
      _paths.clear();
    }
  }

  void add(Offset startPoint) {
    if (!_inDrag) {
      _inDrag = true;
      Path path = new Path();
      path.moveTo(startPoint.dx, startPoint.dy);
      _paths.add(new MapEntry<Path, Paint>(path, currentPaint));
    }
  }

  void updateCurrent(Offset nextPoint) {
    if (_inDrag) {
      Path path = _paths.last.key;
      path.lineTo(nextPoint.dx, nextPoint.dy);
    }
  }

  void endCurrent() {
    _inDrag = false;
  }

  void draw(Canvas canvas, Size size) {
    canvas.drawRect(
        new Rect.fromLTWH(0.0, 0.0, size.width, size.height), _backgroundPaint);
    for (MapEntry<Path, Paint> path in _paths) {
      canvas.drawPath(path.key, path.value);
    }
  }
}

class PainterController extends ChangeNotifier {
  Color _drawColor = new Color.fromARGB(255, 0, 0, 0);
  Color _backgroundColor = new Color.fromARGB(255, 255, 255, 255);

  double _thickness = 1.0;
  PictureDetails _cached;
  _PathHistory _pathHistory;
  ValueGetter<Size> _widgetFinish;

  PainterController() {
    _pathHistory = new _PathHistory();
  }

  Color get drawColor => _drawColor;
  set drawColor(Color color) {
    _drawColor = color;
    _updatePaint();
  }

  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color color) {
    _backgroundColor = color;
    _updatePaint();
  }

  double get thickness => _thickness;
  set thickness(double t) {
    _thickness = t;
    _updatePaint();
  }

  void _updatePaint() {
    Paint paint = new Paint();
    paint.color = drawColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = thickness;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;
    _pathHistory.currentPaint = paint;
    _pathHistory.setBackgroundColor(backgroundColor);
    notifyListeners();
  }

  void undo() {
    if (!isFinished()) {
      _pathHistory.undo();
      notifyListeners();
    }
  }

  void _notifyListeners() {
    notifyListeners();
  }

  void clear() {
    if (!isFinished()) {
      _pathHistory.clear();
      notifyListeners();
    }
  }

  PictureDetails finish() {
    if (!isFinished()) {
      _cached = _render(_widgetFinish());
    }
    return _cached;
  }

  PictureDetails _render(Size size) {
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    Canvas canvas = new Canvas(recorder);
    _pathHistory.draw(canvas, size);
    return new PictureDetails(
        recorder.endRecording(), size.width.floor(), size.height.floor());
  }

  bool isFinished() {
    return _cached != null;
  }
}

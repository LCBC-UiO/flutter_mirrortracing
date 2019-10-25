
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/helper.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:mirrortask/objimgloader.dart';
import 'package:mirrortask/settings.dart';

/*----------------------------------------------------------------------------*/

class DrawScreen extends StatefulWidget {
  final String userId;
  final ObjImg objImg;

  DrawScreen({
    @required this.userId,
    @required this.objImg,
  });

  static Widget getDrawScreenLayout({
    final Widget top,
    final Widget center,
    final Widget bottom,
    final int centerSize,
  }) {
    return Column(
      children: [
        Expanded(
          child: top ?? Text(""),
        ), 
        Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1,
              )
            ),
            child: SizedBox(
              height: centerSize.toDouble(),
              width: centerSize.toDouble(),
              child: center,
            )
          ),
        ),
        Expanded(
          child: bottom ?? Text(""),
        )
      ]
    );
  }

  @override
  State<StatefulWidget> createState() => _DrawScreenState();
}

class _ImgEvaluation {
  final img.Image drawing;
  final int numStrokes;
  final Duration time;
  final int numTotalPixels;
  final int numOutsidePixels;

  _ImgEvaluation({
    @required this.drawing,
    @required this.numStrokes,
    @required this.time,
    @required this.numTotalPixels,
    @required this.numOutsidePixels,
  });
}



enum _DrawState {
  Init,
  Recording,
  Finishing,
  Finished,
}

/*----------------------------------------------------------------------------*/

class _DrawScreenState extends State<DrawScreen> {
  PainterController _controller;
  _DrawState _state;

  DateTime _startTime;
  DateTime _endTime;
  int _numStrokes;
  Duration _drawingTime;
  DateTime _strokeStart;

  _ImgEvaluation _imgEval;

  Image _imgBoundary;

  @override
  void initState() {
    _state = _DrawState.Init;
    super.initState();
    _controller = _newController();
    _numStrokes = 0;
    _imgEval = null;
    _imgBoundary = Image.memory(img.encodePng(widget.objImg.boundary));
    _drawingTime = Duration();
  }

  PainterController _newController() {
    PainterController controller = PainterController();

    controller.thickness = 2.0;
    controller.drawColor = Color(0xffff0000);
    controller.backgroundColor = Colors.transparent;
    return controller;
  }

  Future<_ImgEvaluation> _getEvaluatedImage({
    @required int numStrokes,
    @required Duration time,
    @required img.Image objMask,
    @required PictureDetails drawing,
    }) async {
    final dbytes = (await (await drawing.toImage()).toByteData());
    final List<int> bytes = (dbytes.buffer).asUint8List(dbytes.offsetInBytes, dbytes.lengthInBytes);
    img.Image dimg = img.Image.fromBytes(
      drawing.width,
      drawing.height,
      bytes,
    );
    assert(objMask.width == dimg.width);
    assert(objMask.height == dimg.height);
    int numTotalPixels = 0;
    int numOutsidePixels = 0;
    for (int j = 0; j < dimg.height; j++) {
      for (int i = 0; i < dimg.width; i++) {
        // transfer mask
        final bool isInside = img.getAlpha(objMask.getPixel(i, j)) > 0;
        final bool hasPaint = img.getRed(dimg.getPixel(i, j)) > 0;
        // pixel contains paint?
        final r = hasPaint && ! isInside ? 255 : 0;
        final g = hasPaint && isInside   ? 255 : 0;
        final b = ! hasPaint && isInside ? 255 : 0;
        final a = hasPaint || isInside   ? 255 : 0;
        dimg.setPixelSafe(i, j, img.getColor(r, g, b, a));
        numTotalPixels   += hasPaint ? 1 : 0;
        numOutsidePixels += hasPaint && ! isInside ? 1 : 0;
      }
    }

    return _ImgEvaluation(
      drawing: dimg,
      numStrokes: numStrokes,
      time: time,
      numTotalPixels: numTotalPixels,
      numOutsidePixels: numOutsidePixels,
    );
  }

  void _cbOnStrokeStart() {
    _strokeStart = DateTime.now();
    if (_state == _DrawState.Init) {
      setState(() {
        _state = _DrawState.Recording;
        _startTime = DateTime.now();
        _numStrokes = 0;
      });
    }
    _numStrokes++;
    _endTime = DateTime.now();
  }

  void _cbOnStrokeEnd() {
    _endTime = DateTime.now();
    // add time of last stroke to total drawing time
    Duration strokeDuration = _endTime.difference(_strokeStart);
    _drawingTime = Duration(milliseconds: _drawingTime.inMilliseconds + strokeDuration.inMilliseconds);
  }

  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      actions: <Widget>[
        LcScaffold.getActionReset(context)
      ],
      body: DrawScreen.getDrawScreenLayout(
        top: _getTop(),
        center: _getCenter(),
        bottom: _getBottom(),
        centerSize: widget.objImg.boundary.width,
      )
    );
  }

  Widget _getTop() {
    List<Widget> l = [];
   if (_state == _DrawState.Recording) {
      l.add(
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
    l.add(
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CupertinoButton(
              onPressed: _state == _DrawState.Init ? null : _showRestartDialog,
              child: Text("Reset"),
            ),
            CupertinoButton(
              onPressed: _state != _DrawState.Recording ? null : () async {
                setState(() {
                  _state = _DrawState.Finishing;
                });
                _imgEval = await _getEvaluatedImage(
                  drawing: _controller.finish(),
                  numStrokes: _numStrokes,
                  objMask: widget.objImg.mask,
                  time: _endTime.difference(_startTime),
                );
                setState(() {
                  _state = _DrawState.Finished;
                });
              },
              child: Text("Done"),
            ),
          ]
        )
      )
    );
    return Stack(
      children: l,
    );
  }

  Widget _getBottom() {
    if (_state != _DrawState.Finished) {
      return null;
    }
    final double inside = (_imgEval.numTotalPixels - _imgEval.numOutsidePixels) / _imgEval.numTotalPixels * 100;
    final double outside = _imgEval.numOutsidePixels / _imgEval.numTotalPixels * 100;
    final double screenWidth = LcSettings().getDouble(LcSettings.SCREEN_WIDTH_CM_DBL);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("${DateTime.now().toString().split(".")[0]}"),
            Text("size on display (cm): ${screenWidth.toStringAsFixed(1)}"),
            Text("num. strokes: ${_imgEval.numStrokes}"),
            Text("total time (ms): ${_imgEval.time.inMilliseconds}"),
            Text("drawing time (ms): ${_drawingTime.inMilliseconds}"),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(""),
            Text("user ID: ${widget.userId}"),
            Text("num. pixel: ${_imgEval.numTotalPixels}"),
            Text("inside object: ${inside.toStringAsFixed(1)}%"),
            Text("outside object: ${outside.toStringAsFixed(1)}%"),
          ],
        ),
      ],
    );
  }

  

  Widget _getCenter() {
    if (_state == _DrawState.Finishing) {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }
    if (_state == _DrawState.Finished) {
      return Center(
        child: Image.memory(img.encodePng(_imgEval.drawing)) //TODO: cache
      );
    }
    return Stack(
      children: <Widget>[
        _imgBoundary,
        Painter(
          _controller,
          onPanStart: _cbOnStrokeStart,
          onPanEnd: _cbOnStrokeEnd,
        ),
      ],
    );
  }

  void _showRestartDialog() {
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
                  builder: (context) => DrawScreen(userId: widget.userId, objImg: widget.objImg,),
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

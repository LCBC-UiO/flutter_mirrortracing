
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/helper.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:mirrortask/objimgloader.dart';
import 'package:mirrortask/settings.dart';
import 'package:provider/provider.dart';
import 'imgevaluation.dart';
import 'pentrajectory.dart';
import 'resultdata.dart';
import 'uihomearea.dart';

/*----------------------------------------------------------------------------*/

class DrawScreen extends StatelessWidget {
  final String userId;
  final ObjImg objImg;

  DrawScreen({
    @required this.userId,
    @required this.objImg,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        builder: (context) => _ExperimentState(),
        child: LcScaffold(
        actions: <Widget>[
          LcScaffold.getActionReset(context)
        ],
        body: ExperimentMain(
          userId: userId,
          objImg: objImg,
        )
      )
    );
  }
}

/*----------------------------------------------------------------------------*/

class ExperimentMain extends StatefulWidget {
  final String userId;
  final ObjImg objImg;

  ExperimentMain({
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
  State<StatefulWidget> createState() => _ExperimentMainState();
}
/*----------------------------------------------------------------------------*/

class _ExperimentMainState extends State<ExperimentMain> {
  PainterController _controller;

  ResultData _resultData;
  Image _resultImg;

  Image _imgBoundary;
  _HomeAreaHelper _homeArea= _HomeAreaHelper();
  PenTrajectory _penTrajectory;

  _ActionState _dataSaved;
  _ActionState _dataUploaded;


  @override
  void initState() {
    super.initState();
    _controller = _newController();
    _resultData = null;
    _imgBoundary = Image.memory(img.encodePng(widget.objImg.boundary));
    _penTrajectory = PenTrajectory();
    _homeArea = _HomeAreaHelper();
    _homeArea.state = _HomeAreaHelper.stateInit;
    _dataSaved = _ActionState.init;
    _dataUploaded = _ActionState.init;
  }

  PainterController _newController() {
    PainterController controller = PainterController();

    controller.thickness = 2.0;
    controller.drawColor = Color(0xffff0000);
    controller.backgroundColor = Colors.transparent;
    return controller;
  }


  void _cbOnStrokeStart(Offset o) {
    final expState = Provider.of<_ExperimentState>(context);
    if (expState.state == _ExperimentState.init && _homeArea.isInner(o)) {
      setState(() {
        expState.state = _ExperimentState.recording;
        _homeArea.state = _HomeAreaHelper.stateStarted;
        _penTrajectory.newLine();
        _penTrajectory.add(o.dx, o.dy);
      });
    } else if (expState.state == _ExperimentState.recording) {
      _penTrajectory.newLine();
      _penTrajectory.add(o.dx, o.dy);
    }
  }

  void _cbOnStrokeUpdate(Offset o) {
    if (Provider.of<_ExperimentState>(context).state == _ExperimentState.recording) {
      _penTrajectory.add(o.dx, o.dy);
    }
    if (_homeArea.state == _HomeAreaHelper.stateStarted && ! _homeArea.isOuter(o)) {
      setState(() {
        _homeArea.state = _HomeAreaHelper.stateCompletable;
      });
    } else if (_homeArea.state == _HomeAreaHelper.stateCompletable && _homeArea.isInner(o)) {
      _cbOnStrokeEnd();
      _actionDone();
    }
  }

  void _cbOnStrokeEnd() {
  }

  @override
  Widget build(BuildContext context) {
    return ExperimentMain.getDrawScreenLayout(
      top: _getTop(context),
      center: AnimatedSwitcher(
        switchInCurve: Curves.easeInOutSine,
        switchOutCurve: Curves.easeInOutSine,
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(child: child, scale: animation);
        },
        child: _getCenter(),
      ),
      bottom: _getBottom(),
      centerSize: widget.objImg.boundary.width,
    );
  }

  Widget _getTop(context) {
    List<Widget> l = [];
    if (Provider.of<_ExperimentState>(context).state == _ExperimentState.recording) {
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(child: child, position: Tween<Offset>(begin: Offset(1,0), end: Offset(0,0)).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutSine)));
          },
          child: _getButtonRow()
        )
      )
    );
    return Stack(
      children: l,
    );
  }

  Widget _getBottom() {
    if (Provider.of<_ExperimentState>(context).state != _ExperimentState.finished) {
      return null;
    }
    final double inside = (_resultData.imgEval.numTotalSamples - _resultData.imgEval.numOutsideSamples) / _resultData.imgEval.numTotalSamples * 100;
    final double outside = _resultData.imgEval.numOutsideSamples / _resultData.imgEval.numTotalSamples * 100;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("${_resultData.date.toString().split(".")[0]}"),
            Text("user ID: ${_resultData.userId}"),
            Text("num. continuous lines: ${_resultData.trajectory.numContinuousLines}"),
            Text("total time (ms): ${_resultData.trajectory.totalTime}"),
            Text("pen drawing time (ms): ${_resultData.trajectory.drawingTime}"),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("number of samples: ${_resultData.imgEval.numTotalSamples}"),
            Text("inside object: ${inside.toStringAsFixed(1)}%"),
            Text("outside object: ${outside.toStringAsFixed(1)}%"),
            Text("num. boundary crossings ${_resultData.imgEval.numBoundaryCrossings}"),
            Text("displ. canvas width (cm): ${_resultData.canvasWidth.toStringAsFixed(1)}"),
          ],
        ),
      ],
    );
  }

  

  Widget _getCenter() {
    final expState = Provider.of<_ExperimentState>(context);
    if (expState.state == _ExperimentState.finishing) {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }
    if (expState.state == _ExperimentState.finished) {
      return Center(
        child: _resultImg //TODO: cache
      );
    }
    return Stack(
      children: <Widget>[
        _imgBoundary,
        Painter(
          _controller,
          onPanStart: _cbOnStrokeStart,
          onPanUpdate: _cbOnStrokeUpdate,
          onPanEnd: _cbOnStrokeEnd,
        ),
        _homeArea.getVis(),
      ],
    );
  }

  Widget _getButtonRow() {
    final expState = Provider.of<_ExperimentState>(context);
    if (expState.state != _ExperimentState.finished) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CupertinoButton(
            onPressed: expState.state == _ExperimentState.init ? null : _actionReset,
            child: Text("Reset"),
          ),
          CupertinoButton(
            onPressed: expState.state != _ExperimentState.recording ? null : _actionDone,
            child: Text("Done"),
          ),
        ]
      );
    } else 
    return Center(child: Row(
      children: [
        Expanded(
          child: CupertinoButton(
            onPressed: expState.state == _ExperimentState.init ? null : _actionReset,
            child: Text("Reset"),
          )
        ),
        Expanded(
            child: CupertinoButton(
            onPressed: _dataSaved != _ActionState.init ? null : _actionSave,
            child: () {
              switch (_dataSaved) {
                case _ActionState.init:
                  return Text("Save");
                  break;
                case _ActionState.inprogress:
                  return Text("Saving");
                  break;
                case _ActionState.done:
                  return Text("Saved");
                  break;
              }
              throw "err";
            }()
          ),
        ),
        Expanded(
            child: CupertinoButton(
            onPressed: _dataUploaded != _ActionState.init ? null : _actionUpload,
            child: () {
              switch (_dataUploaded) {
                case _ActionState.init:
                  return Text("Upload");
                  break;
                case _ActionState.inprogress:
                  return Text("Uploading");
                  break;
                case _ActionState.done:
                  return Text("Uploaded");
                  break;
              }
              throw "err";
            }()
          ),
        ),
      ]
    ));
  }

  void _actionDone() async {
    final expState = Provider.of<_ExperimentState>(context);
    setState(() {
      expState.state = _ExperimentState.finishing;
    });
    _resultData = ResultData(
      userId: widget.userId,
      imgEval: await ImgEvaluation.calculate(
        drawing: _controller.finish(),
        objMask: widget.objImg.mask,
        objBoudary: widget.objImg.boundary,
        trajectory: _penTrajectory,
      ),
      date: DateTime.now(),
      trajectory: _penTrajectory,
      canvasWidth: LcSettings().getDouble(LcSettings.SCREEN_WIDTH_CM_DBL)
        * LcSettings().getDouble(LcSettings.RELATIVE_BOX_SIZE_DBL),
    );
    _resultImg = Image.memory(img.encodePng(_resultData.imgEval.drawing));
    setState(() {
      expState.state = _ExperimentState.finished;
    });
  }

  void _actionReset() {
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

  Future<void> _actionSave() async {
    setState(() {
      _dataSaved = _ActionState.inprogress;
    });
    try {
      await _resultData.saveLocally(context);
      setState(() {
        _dataSaved = _ActionState.done;
      });
      final snackBar = SnackBar(content: Text("Data saved"));
      Scaffold.of(context).showSnackBar(snackBar);
    } catch (e) {
      setState(() {
        _dataSaved = _ActionState.init;
      });
      final snackBar = SnackBar(content: Text("Error: data not saved!"));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _actionUpload() async {
    setState(() {
      _dataUploaded = _ActionState.init;
    });
    try {
      await _resultData.uploadNettskjema();
      setState(() {
        _dataUploaded = _ActionState.done;
      });
      final snackBar = SnackBar(content: Text("Data uploaded"));
      Scaffold.of(context).showSnackBar(snackBar);
    } catch (e) {
      setState(() {
        _dataUploaded = _ActionState.init;
      });
      final snackBar = SnackBar(content: Text("Error: ${e.toString()}"));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }
}

enum _ExpState {
  Init,
  Recording,
  Finishing,
  Finished,
}
class _ExperimentState with ChangeNotifier {
  _ExpState _state = _ExpState.Init;

  _ExpState get state => _state;

  set state(_ExpState n) {
    _state = n;
    notifyListeners();
  }

  static const _ExpState init      = _ExpState.Init;
  static const _ExpState recording = _ExpState.Recording;
  static const _ExpState finishing = _ExpState.Finishing;
  static const _ExpState finished  = _ExpState.Finished;
}


enum _ActionState {
  init,
  inprogress,
  done
}






class _HomeAreaHelper {
  final Offset pos = Offset(
     LcSettings().getInt(LcSettings.HOME_POS_X_INT).toDouble(),
     LcSettings().getInt(LcSettings.HOME_POS_Y_INT).toDouble(),
  );
  final double innerRadius = LcSettings().getInt(LcSettings.HOME_INNER_RADIUS_INT).toDouble();
  final double outerRadius = LcSettings().getInt(LcSettings.HOME_OUTER_RADIUS_INT).toDouble();

  static const int stateInit = 0;
  static const int stateStarted = 1;
  static const int stateCompletable = 2;

  int state = stateInit;

  Widget getVis() {
    final color = () {
      if (state == stateInit)        return Colors.red.withAlpha(64);
      if (state == stateCompletable) return Colors.green.withAlpha(64);
      return Colors.transparent;
    }();
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeInOutSine,
        switchOutCurve: Curves.easeInOutSine,
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(child: child, scale: animation);
        },
        child: HomeArea(
          key: ValueKey(state),
          innerColor: color,
          innerRadius: innerRadius,
          outerRadius: outerRadius,
        )
      )
    );
  }

  bool isInner(final Offset o) {
    return ((pos - o).distance < innerRadius);
  }

  bool isOuter(final Offset o) {
    return ((pos - o).distance < outerRadius);
  }

}


/*----------------------------------------------------------------------------*/



class Painter extends StatefulWidget {
  final PainterController painterController;
  final Function onPanStart;
  final Function onPanUpdate;
  final Function onPanEnd;

  Painter(PainterController painterController, {
    @required this.onPanStart,
    @required this.onPanUpdate,
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
    widget.onPanStart(pos);
    if (Provider.of<_ExperimentState>(context).state == _ExperimentState.recording) {
      widget.painterController._pathHistory.add(pos);
      widget.painterController._notifyListeners();
    }
  }

  void _onPanUpdate(DragUpdateDetails update) {
    Offset pos = (context.findRenderObject() as RenderBox)
        .globalToLocal(update.globalPosition);
    widget.painterController._pathHistory.updateCurrent(pos);
    widget.painterController._notifyListeners();
    widget.onPanUpdate(pos);
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

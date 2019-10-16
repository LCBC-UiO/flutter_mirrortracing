import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

const coldef_lcbcgreen1 = Color(0xffC6DA85);
const coldef_lcbcgreen2 = Color(0xff95C21A);
const coldef_lcbcblue2  = Color(0xFF00A0E4);
const coldef_lcbcblue1  = Color(0xFF00B2EC);

void main() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MyApp()
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MirrorTask',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  PainterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _newController();
  }

  PainterController _newController() {
    PainterController controller = PainterController();

    controller.thickness = 2.0;
    controller.drawColor = Colors.blue;
    controller.backgroundColor = Colors.transparent;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final starimg = Image.asset(
      "assets/star.png"
    );

    Widget _doPadding(Widget w) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: w,
      );
    }


    return Scaffold(
      appBar: CustomAppBar(
        actions: <Widget>[
          Icon(Icons.refresh),
          Icon(Icons.clear),
          IconButton(
            onPressed: () {
              _controller.clear();
            },
            icon: Icon(Icons.check_circle)
          )
        ],
      ),
      body: Center(
        child:
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey)
            ),
            child: Stack(
            alignment: Alignment(0, 0.06),
            children: [
              // CustomPaint(
              //   painter: StarPainter(),
              // ),
              // Positioned.fill(
              //   child: Icon(Icons.star_border),
              // ),
              _doPadding(starimg),
              _doPadding(FractionallySizedBox(
                widthFactor: 0.9,
                child: starimg
              )),
              Painter(_controller),
            ]
          )
        ))
        ),
      ),
    );
  }
}


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  final List<Widget> actions;

  CustomAppBar({
    this.actions
  });


  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

   @override
  Widget build(BuildContext context) {
    return  Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [coldef_lcbcgreen1, coldef_lcbcgreen2, coldef_lcbcblue2, coldef_lcbcblue1],
              stops: [0.0, 0.25, 0.75, 1],
              )
            ),
        child: AppBar(
          actions: actions,
          title: Text("MirrorTracingTask"),
          backgroundColor: Color(0x00000000),
          centerTitle: true,
        ),
    );
  }

}





// class StarPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint();
//     // set the paint color to be white
//     paint.color = Colors.white;
    
//     // Create a rectangle with size and width same as the canvas
//     //var rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     // draw the rectangle using the paint
//     //canvas.drawRect(rect, paint);
//     // set the color property of the paint
//     paint.color = Colors.deepOrange;
//     // center of the canvas is (x,y) => (width/2, height/2)
//     var center = Offset(size.width/2, size.height/2);
//     // draw the circle with center having radius 75.0
//     canvas.drawCircle(center, 75, paint);

//     paint.color = Colors.yellow;
//     // create a path
//     var path = Path();
//     path.lineTo(0, size.height);
//     path.lineTo(size.width, 0);
//     // close the path to form a bounded shape
//     path.close();

//   }
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }





class Painter extends StatefulWidget {
  final PainterController painterController;

  Painter(PainterController painterController)
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

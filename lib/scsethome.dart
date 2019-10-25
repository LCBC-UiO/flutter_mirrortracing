import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'helper.dart';
import 'scdraw.dart';
import 'settings.dart';
import 'scsettings.dart';
import 'uihomearea.dart';

/*----------------------------------------------------------------------------*/

class SetHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetHomeScreenState();
}

/*----------------------------------------------------------------------------*/

class _SetHomeScreenState extends State<SetHomeScreen> {
  final double _boxSize = LcSettings().getDouble(LcSettings.RELATIVE_BOX_SIZE_DBL);
  final double _objSize = LcSettings().getDouble(LcSettings.RELATIVE_OBJECT_SIZE_DBL);

  double _homeX;
  double _homeY;
  double _homeRadius;

  @override
  void initState() {
    super.initState();
    _homeX = LcSettings().getInt(LcSettings.HOME_POS_X_INT).toDouble();
    _homeY = LcSettings().getInt(LcSettings.HOME_POS_Y_INT).toDouble();
    _homeRadius = LcSettings().getInt(LcSettings.HOME_RADIUS_INT).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    return LcScaffold(
      iconNext: Icon(Icons.done),
      onNext: () async {
        await LcSettings().setInt(LcSettings.HOME_POS_X_INT, _homeX.round());
        await LcSettings().setInt(LcSettings.HOME_POS_Y_INT, _homeY.round());
        await LcSettings().setInt(LcSettings.HOME_RADIUS_INT, _homeRadius.round());
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SettingsScreen(),
          )
        );
      },
      iconPrev: Icon(Icons.close),
      onPrev: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SettingsScreen(),
          )
        );
      },
      body: Stack(
        children: <Widget>[
          DrawScreen.getDrawScreenLayout(
            centerSize: (w * _boxSize).round(),
            center: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (e) {
                setState(() {
                  _homeX = e.localPosition.dx;
                  _homeY = e.localPosition.dy;
                });
              },
              child: Stack( 
                children: [
                  Center(
                    child: SizedBox(
                      width:  w * _boxSize * _objSize,
                      height: w * _boxSize * _objSize,
                      child: Image.asset("assets/star2.png"),
                    )
                  ),
                  PositionedHomeArea(
                    x: _homeX,
                    y: _homeY,
                    color: Colors.red.withAlpha(64),
                    radius: _homeRadius,
                  ),
                ]
              )
            ),
            bottom: Center(child: Text("Tap screen to change position")),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _getCard(w),
          )
        ]
      )
    );
  }

  Widget _getCard(double w) {
    return Card(
      color: Theme.of(context).canvasColor.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Home area position: ${_homeX.toStringAsFixed(1)}, ${_homeY.toStringAsFixed(1)}"),
            divy_1,
            Text("Home area size: ${_homeRadius.toStringAsFixed(1)}"),
            SizedBox(
              height: 50,
              child: Slider(
                min: 0 * w,
                max: 1 * w * _boxSize / 2,
                onChanged: (v) {
                  setState(() {
                    _homeRadius = v;
                  });
                },
                value: _homeRadius,
              ),
            ),
          ],
        ),
      )
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mirrortask/scsethomesize.dart';
import 'helper.dart';
import 'scdraw.dart';
import 'settings.dart';
import 'scsettings.dart';
import 'uihomearea.dart';

/*----------------------------------------------------------------------------*/

class SetHomeAreaPositionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetHomeAreaPositionScreenState();
}

/*----------------------------------------------------------------------------*/

class _SetHomeAreaPositionScreenState extends State<SetHomeAreaPositionScreen> {
  final double _boxSize = LcSettings().getDouble(LcSettings.RELATIVE_BOX_SIZE_DBL);
  final double _objSize = LcSettings().getDouble(LcSettings.RELATIVE_OBJECT_SIZE_DBL);

  double _homeX;
  double _homeY;
  double _homeInnerRadius;
  double _homeOuterRadius;

  @override
  void initState() {
    super.initState();
    _homeX = LcSettings().getInt(LcSettings.HOME_POS_X_INT).toDouble();
    _homeY = LcSettings().getInt(LcSettings.HOME_POS_Y_INT).toDouble();
    _homeInnerRadius = LcSettings().getInt(LcSettings.HOME_INNER_RADIUS_INT).toDouble();
    _homeOuterRadius = LcSettings().getInt(LcSettings.HOME_OUTER_RADIUS_INT).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    return LcScaffold(
      iconNext: Icon(Icons.done),
      onNext: () async {
        await LcSettings().setInt(LcSettings.HOME_POS_X_INT, _homeX.round());
        await LcSettings().setInt(LcSettings.HOME_POS_Y_INT, _homeY.round());
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SetHomeAreaSizeScreen(),
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
          ExperimentMain.getDrawScreenLayout(
            top: Center(child: Text("Home area position:\n${_homeX.toStringAsFixed(1)}, ${_homeY.toStringAsFixed(1)}", textAlign: TextAlign.center,)),
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
                      child: Image.asset("assets/star.png"),
                    )
                  ),
                  PositionedHomeArea(
                    x: _homeX,
                    y: _homeY,
                    innerColor: Colors.red.withAlpha(64),
                    outerColor: Colors.grey.withAlpha(64),
                    innerRadius: _homeInnerRadius,
                    outerRadius: _homeOuterRadius,
                  ),
                ]
              )
            ),
            bottom: Center(child: Text("Tap screen to change position")),
          ),
        ]
      )
    );
  }
}
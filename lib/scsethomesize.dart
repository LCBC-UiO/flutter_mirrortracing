import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'helper.dart';
import 'scdraw.dart';
import 'scstart.dart';
import 'settings.dart';
import 'uihomearea.dart';

/*----------------------------------------------------------------------------*/

class SetHomeAreaSizeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetHomeAreaSizeScreenState();
}

/*----------------------------------------------------------------------------*/

class _SetHomeAreaSizeScreenState extends State<SetHomeAreaSizeScreen> {
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
        await LcSettings().setInt(LcSettings.HOME_INNER_RADIUS_INT, _homeInnerRadius.round());
        await LcSettings().setInt(LcSettings.HOME_OUTER_RADIUS_INT, _homeOuterRadius.round());
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => StartScreen(),
          )
        );
      },
      iconPrev: Icon(Icons.close),
      onPrev: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => StartScreen(),
          )
        );
      },
      body: Stack(
        children: <Widget>[
          ExperimentMain.getDrawScreenLayout(
            centerSize: (w * _boxSize).round(),
            center: Stack( 
              children: [
                Center(
                  child: SizedBox(
                    width:  w * _boxSize * _objSize,
                    height: w * _boxSize * _objSize,
                    child: Image.asset("assets/star.png"),
                  )
                ),
                Positioned(
                  left: _homeX,
                  top: _homeY,
                  child:HomeArea(
                    innerColor: Colors.red.withAlpha(64),
                    outerColor: Colors.grey.withAlpha(64),
                    innerRadius: _homeInnerRadius,
                    outerRadius: _homeOuterRadius,
                  ),
                )
              ]
            ),
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
            Text("Home area size: ${_homeInnerRadius.toStringAsFixed(1)}"),
            SizedBox(
              height: 50,
              child: Slider(
                min: 0 * w,
                max: 1 * w * _boxSize / 2,
                onChanged: (v) {
                  setState(() {
                    _homeInnerRadius = v;
                    _homeOuterRadius = max(_homeOuterRadius, _homeInnerRadius);
                  });
                },
                value: _homeInnerRadius,
              ),
            ),
            divy_1,
            Text("Start zone size: ${_homeOuterRadius.toStringAsFixed(1)}"),
            SizedBox(
              height: 50,
              child: Slider(
                min: _homeInnerRadius,
                max: 1 * w * _boxSize,
                onChanged: (v) {
                  setState(() {
                    _homeOuterRadius = v;
                  });
                },
                value: max(_homeOuterRadius, _homeInnerRadius),
              ),
            ),
          ],
        ),
      )
    );
  }
}
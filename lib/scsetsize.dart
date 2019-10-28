import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'helper.dart';
import 'scdraw.dart';
import 'scsethomepos.dart';
import 'scstart.dart';
import 'settings.dart';

/*----------------------------------------------------------------------------*/

class SetSizeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetSizeScreenState();
}

/*----------------------------------------------------------------------------*/

class _SetSizeScreenState extends State<SetSizeScreen> {
  double _boxSize;
  double _objSize;

  @override
  void initState() {
    super.initState();
    _boxSize = LcSettings().getDouble(LcSettings.RELATIVE_BOX_SIZE_DBL);
    _objSize = LcSettings().getDouble(LcSettings.RELATIVE_OBJECT_SIZE_DBL);
  }

  @override
  Widget build(BuildContext context) {
    final String objFn = LcSettings().getStr(LcSettings.OBJECT_PATH_STR);
    final double w = MediaQuery.of(context).size.width;
    return LcScaffold(
      iconNext: Icon(Icons.done),
      onNext: () async {
        await LcSettings().setDouble(LcSettings.RELATIVE_BOX_SIZE_DBL,    _boxSize);
        await LcSettings().setDouble(LcSettings.RELATIVE_OBJECT_SIZE_DBL, _objSize);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SetHomeAreaPositionScreen(),
          )
        );
      },
      iconPrev: Icon(Icons.close),
      onPrev: Navigator.of(context).canPop() ? () {
        Navigator.of(context).pop();
      } : null,
      body: Stack(
        children: <Widget>[
          ExperimentMain.getDrawScreenLayout(
            center: Center(
              child: SizedBox(
                width:  w * _boxSize * _objSize,
                height: w * _boxSize * _objSize,
                child: Image.asset(objFn),
              )
            ),
            centerSize: (w * _boxSize).round(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _getCard(),
          )
        ]
      )
    );
  }

  Widget _getCard() {
    return Card(
      color: Theme.of(context).canvasColor.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Box size: ${_boxSize.toStringAsFixed(3)}"),
            SizedBox(
              height: 50,
              child: Slider(
                min: 0,
                max: 1,
                onChanged: (v) {
                  setState(() {
                    _boxSize = v;
                  });
                },
                value: _boxSize,
              )
            ),
            Text("Object size: ${_objSize.toStringAsFixed(3)}"),
            SizedBox(
              height: 50,
              child: Slider(
                min: 0,
                max: 1,
                onChanged: (v) {
                  setState(() {
                    _objSize = v;
                  });
                },
                value: _objSize,
              )
            )
          ],
        ),
      )
    );
  }
}
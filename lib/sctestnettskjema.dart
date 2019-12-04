/*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mirrortask/scgetid.dart';
import 'package:mirrortask/scstart.dart';
import 'helper.dart';
import 'resultdata.dart';
import 'settings.dart';

class TestNettskjemaScreen extends StatefulWidget {
  final double screenWidth;

  TestNettskjemaScreen({
    @required this.screenWidth
  });

  // forward to next screen if no id is configured
  static Widget getRoute({@required double screenWidth}) {
    if (LcSettings().getInt(LcSettings.NETTSKJEMA_ID_INT) < 0) {
      return GetIdScreen( screenWidth: screenWidth );
    }
    return TestNettskjemaScreen( screenWidth: screenWidth ); 
  }

  @override
  _TestNettskjemaScreenState createState() => _TestNettskjemaScreenState();
}

enum _Status {
  na,
  ok,
  err,
}

class _TestNettskjemaScreenState extends State<TestNettskjemaScreen> {
  _Status status;
  String msg;

  @override
  void initState() {
    super.initState();
    status = _Status.na;
    msg = "testing...";
  }

  @override
  Widget build(BuildContext context) {
    final int nettskjemaId = LcSettings().getInt(LcSettings.NETTSKJEMA_ID_INT);
    return LcScaffold(
      iconPrev: Icon(Icons.close),
      onPrev: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => StartScreen()
          )
        );
      },
      onNext: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GetIdScreen( screenWidth: widget.screenWidth )
          )
        );
      },
      body: Padding(
        padding: EdgeInsets.all(16),
         child: FutureBuilder(
              future: () async {
                try {
                  await ResultData.testNettskjema(nettskjemaId);
                  status = _Status.ok;
                  msg = "OK";
                } catch (e) {
                  status = _Status.err;
                  msg = "Cannot upload to nettskjema '$nettskjemaId'.\n\n" 
                        "Make sure you are connected to the internet and restart experiment.\n\n"
                        "Deatils:\n"
                        "${e.toString()}";
                }
              }(),
              builder: (context, snapshot) {
                return Center( 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Nettskjema/Internet status"),
                      divy_2,
                      () {
                        switch (status) {
                          case _Status.na:
                            return _getIcon(Icons.file_upload, Colors.yellow);
                            break;
                          case _Status.err:
                            return _getIcon(Icons.warning, Colors.red);
                            break;
                          case _Status.ok:
                            return _getIcon(Icons.check, Colors.green);
                            break;
                        }
                        return null;
                      }(),
                      divy_2,
                      Text(msg)
                    ],
                  )
                );
              },
            ),
      )
    );
  }


  Widget _getIcon(iconData, color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Icon(iconData, size: 60, color: Theme.of(context).canvasColor)
      ),
    );
  }
}
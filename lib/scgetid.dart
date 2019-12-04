import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/objimgloader.dart';
import 'package:mirrortask/scgetprojectid.dart';
import 'helper.dart';
import 'scstart.dart';
import 'settings.dart';
import 'visitdata.dart';

/*----------------------------------------------------------------------------*/

class GetIdScreen extends StatefulWidget {
  final double screenWidth;
  final Future<ObjImg> _fLoadObjImg;

  GetIdScreen({
    @required this.screenWidth
  }) : _fLoadObjImg = _getFLoadObjImg(screenWidth);


  static _getFLoadObjImg(double w) {
    final double boxWidth = LcSettings().getDouble(LcSettings.RELATIVE_BOX_SIZE_DBL);
    final double objWidth = LcSettings().getDouble(LcSettings.RELATIVE_OBJECT_SIZE_DBL);
    return loadObjImg(
      boxWidth: (w * boxWidth).round(),
      objWidth: (w * boxWidth * objWidth).round(),
    );
  }

  @override
  State<StatefulWidget> createState() => _GetIdScreenState();
}

/*----------------------------------------------------------------------------*/

class _GetIdScreenState extends State<GetIdScreen> {
  Function _onNext;
  bool _showTextField;
  String _userId = "";
  final validUserIdChars = RegExp(LcSettings().getStr(LcSettings.USER_ID_REGEX_STR));

  @override
  void initState() {
    super.initState();
    _showTextField = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String hint = LcSettings().getStr(LcSettings.USER_ID_HINT_STR);
    return LcScaffold(
      onNext: _onNext,
      iconPrev: Icon(Icons.close),
      onPrev: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => StartScreen()
          )
        );
      },
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(child: child, scale: animation);
          },
          child: _showTextField ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (
                  "Enter participant ID\n"
                  "${hint != "" ? "(" + hint + ")" : ""}"
                ), 
                style:  Theme.of(context).textTheme.subhead,
                textAlign: TextAlign.center,
              ),
              divy_1,
              _getUserIdTextField(),
              divy_3,
            ]
          ) : CupertinoActivityIndicator()
        )
      )
    );
  }

  Widget _getUserIdTextField() {
    return CupertinoTextField(
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.display1,
      autofocus: true,
      onChanged: (v) async {
        if (!validUserIdChars.hasMatch(v)) {
          setState(() {
            _onNext = null;
          });
          return;
        }
        if (v == "") {
          return;
        }
        setState(() {
          _userId = v;
          _onNext = () async {
            setState(() {
              _onNext = null;
              _showTextField = false;
            });
            final ObjImg objImg = await widget._fLoadObjImg;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => GetProjectIdScreen.getRoute(
                  visitData: VisitData(userId: _userId), 
                  objImg: objImg, 
                  trialId: 1,
                ),
              )
            );
          };
        });
      },
    );
  }
}

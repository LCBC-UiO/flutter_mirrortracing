import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/objimgloader.dart';
import 'package:mirrortask/scdraw.dart';
import 'helper.dart';
import 'settings.dart';

/*----------------------------------------------------------------------------*/

class GetIdScreen extends StatefulWidget {
  final double screenWidth;
  final Future<ObjImg> _fLoadObjImg;

  GetIdScreen({
    this.screenWidth
  }) : _fLoadObjImg = _getFLoadObjImg(screenWidth);


  static _getFLoadObjImg(double w) {
    final double boxWidth = LcSettings().getDouble(LcSettings.BOX_SIZE_DBL);
    final double objWidth = LcSettings().getDouble(LcSettings.OBJECT_SIZE_DBL);
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
    return LcScaffold(
      onNext: _onNext,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(child: child, scale: animation);
          },
          child: _showTextField ? _getTextField() : CupertinoActivityIndicator(),
        )
      )
    );
  }

  Widget _getTextField() {
    return TextField(
      decoration: InputDecoration(
        hintText:  "enter user ID",
      ),
      textAlign: TextAlign.center,
      //maxLengthEnforced: true,
      style: Theme.of(context).textTheme.display1,
      autofocus: true,
      onSubmitted: (v) async {
        setState(() {
          _onNext = () async {
            setState(() {
              _onNext = null;
              _showTextField = false;
            });
            final ObjImg objImg = await widget._fLoadObjImg;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DrawScreen(userId: v, objImg: objImg),
              )
            );
          };
        });
      },
      onTap: () {
        setState(() {
          _onNext = null;
        });
      },
    );
  }
}




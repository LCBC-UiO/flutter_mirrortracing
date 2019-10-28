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
  String _comment = "";
  static final validUserIdChars = RegExp(r'^[a-zA-Z0-9]+$');

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
          child: _showTextField ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter participant ID:", style:  Theme.of(context).textTheme.subhead,),
              divy_1,
              _getUserIdTextField(),
              divy_2,
              Text("Comment:", style:  Theme.of(context).textTheme.subhead,),
              divy_1,
              _getCommentTextField(),
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
      onSubmitted: (v) async {
        if (!validUserIdChars.hasMatch(v)) {
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
                builder: (context) => DrawScreen(userId: _userId, comment: _comment, objImg: objImg),
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

  Widget _getCommentTextField() {
    return CupertinoTextField(
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.display1,
      autofocus: true,
      onSubmitted: (v) async {
        v = v.replaceAll("\t", " ");
        v = v.replaceAll(";", " ");
        v = v.replaceAll("/", " ");
        v = v.replaceAll("\\", " ");
        _comment = v;
      },
    );
  }
}



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/scstart.dart';
import 'helper.dart';
import 'settings.dart';

/*----------------------------------------------------------------------------*/

class InitScreen extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() => _InitScreenState();
}

/*----------------------------------------------------------------------------*/

class _InitScreenState extends State<InitScreen> {
  Function _onNext;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      onNext: _onNext,
      body: Column( 
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Enter the width of the screens visible area (in cm):", style:  Theme.of(context).textTheme.subhead,),
          divy_2,
          _getTextField(),
          divy_3,
        ]
      )
    );
  }

  Widget _getTextField() {
    return CupertinoTextField(
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.display1,
      autofocus: true,
      onSubmitted: (v) async {
        final double value = double.tryParse(v);
        bool ok = true;
        ok = ok && (value != null);
        ok = ok && (value >= 5);
        ok = ok && (value <= 50);
        if (!ok) {
          return;
        }
        setState(() {
          _onNext = () async {
            await LcSettings().setDouble(LcSettings.SCREEN_WIDTH_CM_DBL, value);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => StartScreen(),
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




import 'package:flutter/material.dart';
import 'package:mirrortask/scdraw.dart';
import 'helper.dart';
import 'settings.dart';

/*----------------------------------------------------------------------------*/

class GetIdScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GetIdScreenState();
}

class _GetIdScreenState extends State<GetIdScreen> {
  Function _onNext;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int drawingWidth = (MediaQuery.of(context).size.width * LcSettings().getDouble(LcSettings.BOX_SIZE_DBL)).round();
    return LcScaffold(
      onNext: _onNext,
      body: Center(
        child: TextField(
          decoration: InputDecoration(
            hintText:  "enter user ID",
          ),
          textAlign: TextAlign.center,
          //maxLengthEnforced: true,
          style: Theme.of(context).textTheme.display1,
          autofocus: true,
          onSubmitted: (v) async {
            setState(() {
              _onNext = () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DrawScreen(userId: v, drawingWidth: drawingWidth),
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
        ),
      )
    );
  }
}
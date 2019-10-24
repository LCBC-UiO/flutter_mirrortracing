import 'package:flutter/material.dart';
import 'package:mirrortask/helper.dart';

import 'scgetid.dart';

/*----------------------------------------------------------------------------*/

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      actions: [ LcScaffold.getActionSettings(context) ],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.play_circle_filled,
              ),
              color: Theme.of(context).primaryColor,
              iconSize: 80,
              onPressed: () {
                  Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GetIdScreen(screenWidth: MediaQuery.of(context).size.width),
                  )
                );
              },
            ),
          ],
        )
      )
    );
  }
}

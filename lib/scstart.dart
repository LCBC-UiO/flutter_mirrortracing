import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/helper.dart';
import 'package:mirrortask/scselectcfg.dart';
import 'package:mirrortask/settings.dart';

import 'scgetid.dart';
import 'scsettings.dart';

/*----------------------------------------------------------------------------*/

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      onPrev: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SelectConfigScreen(),
          )
        );
      },
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text("Profile: ${LcSettings().activeConfigName}"),
              )
            )
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CupertinoButton(
                    child: Text("Change profile"),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => SelectConfigScreen(),
                        )
                      );
                    }
                  ),
                  CupertinoButton(
                    child: Text("Settings"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: Text("Warning!"),
                          content: Text("Changes in the settings might make new results uncomparable with previous ones."),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: false, 
                              child: Text("Back"),
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                            ),
                            CupertinoDialogAction(
                              isDefaultAction: true, 
                              child: Text("Ok"),
                              isDestructiveAction: false,
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SettingsScreen(),
                                  )
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  CupertinoButton(
                    child: Text("Start experiment"),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => GetIdScreen( screenWidth: MediaQuery.of(context).size.width ),
                        )
                      );
                    }
                  ),
                ],
              ),
            ),
            flex: 4,
          ),
          Expanded(
            child: divx_0,
            flex: 1,
          ),
        ],
      )
    );
  }
}

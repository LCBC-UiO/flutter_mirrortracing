import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mirrortask/db.dart';
import 'package:mirrortask/helper.dart';
import 'package:mirrortask/scsetscrw.dart';
import 'package:mirrortask/settings.dart';
import 'package:crypto/crypto.dart';

import 'scstart.dart';

/*----------------------------------------------------------------------------*/

class SelectConfigScreen extends StatefulWidget {
  @override
  _SelectConfigScreenState createState() => _SelectConfigScreenState();
}

/*----------------------------------------------------------------------------*/

class _SelectConfigScreenState extends State<SelectConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      onNext: () async {
        String configName = await showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text("Profile name:"),
            content: CupertinoTextField(
              autofocus: true,
              onSubmitted: (v) async {
                Navigator.of(context).pop(v);
              },
            ),
          )
        );
        if (configName != null) {
          await LcSettings().init(configName);
          setState(() {});
        }
      },
      iconNext: Icon(Icons.add),
      body: FutureBuilder<List<String>>(
        future: LcSettings().getConfigs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CupertinoActivityIndicator());
          }
          return Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text("Select a profile",)
                  )
                )
              ),
              Expanded(
                flex: 4,
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 2/3,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) {
                        final String profileName = snapshot.data[index];
                        final List<int> bytes = md5.convert(utf8.encode(profileName)).bytes.sublist(0, 4);
                        final int sum = bytes.fold(0, (p, c) => (p + c));
                        return Dismissible(
                          confirmDismiss: _getConfirmDelete(profileName),
                          onDismissed: (e) async {
                            await LcSettings().delete(profileName);
                            snapshot.data.remove(profileName);
                            setState(() {
                            });
                          },
                          key: Key(profileName),
                          child: Card(
                            color: Colors.accents[sum % Colors.accents.length],
                            child: ListTile(
                              title: Text(profileName, textAlign: TextAlign.center,),
                              onTap: () async {
                                await LcSettings().init(profileName);
                                final bool hasInit = LcSettings().isDef(LcSettings.SCREEN_WIDTH_CM_DBL);
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => hasInit ? StartScreen() : SetScreenWidthScreen(),
                                  )
                                );
                              }
                            )
                          )
                        );
                      },
                    ),
                  )
                ),
              ),
              Expanded(
                flex: 1,
                child: divx_0,
              ),
            ],
         );
        }
      )
    );
  }


  Function _getConfirmDelete(String profileName) {
    return (DismissDirection direction) async {
      final bool res = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Are you sure you wish to delete profile '$profileName'?"),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: false, 
                child: Text("Delete"),
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              CupertinoDialogAction(
                isDefaultAction: true, 
                child: Text("Back"),
                isDestructiveAction: false,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ]
          );
        },
      );
      return res;
    };
  }
}

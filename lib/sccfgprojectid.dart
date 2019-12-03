import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mirrortask/helper.dart';
import 'package:mirrortask/settings.dart';
import 'package:crypto/crypto.dart';

/*----------------------------------------------------------------------------*/

class ConfigurePjojectIdsScreen extends StatefulWidget {
  @override
  _ConfigurePjojectIdsScreenState createState() => _ConfigurePjojectIdsScreenState();
}

/*----------------------------------------------------------------------------*/

class _ConfigurePjojectIdsScreenState extends State<ConfigurePjojectIdsScreen> {
  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      onNext: () async {
        String projectName = await showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text("Project name:"),
            content: CupertinoTextField(
              autofocus: true,
              onSubmitted: (v) async {
                Navigator.of(context).pop(v);
              },
            ),
          )
        );
        if (projectName != null) {
          Set<String> projects = LcSettings().getStrList(LcSettings.PROJECT_IDS_STRLIST).toSet();
          projects.add(projectName);
          await LcSettings().setStrList(LcSettings.PROJECT_IDS_STRLIST, projects.toList());
          setState(() {
          });
        }
      },
      iconNext: Icon(Icons.add),
      body: FutureBuilder<List<String>>(
        future: () async {
          List<String> r = LcSettings().getStrList(LcSettings.PROJECT_IDS_STRLIST);
          r.sort();
          return r;
        }(),
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
                    child: Text("Configured project names:",)
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
                        final String projectName = snapshot.data[index];
                        final List<int> bytes = md5.convert(utf8.encode(projectName)).bytes.sublist(0, 4);
                        final int sum = bytes.fold(0, (p, c) => (p + c));
                        return Dismissible(
                          confirmDismiss: _getConfirmDelete(projectName),
                          onDismissed: (e) async {
                            Set<String> projects = LcSettings().getStrList(LcSettings.PROJECT_IDS_STRLIST).toSet();
                            projects.remove(projectName);
                            snapshot.data.remove(projectName);
                            await LcSettings().setStrList(LcSettings.PROJECT_IDS_STRLIST, projects.toList());
                            setState(() {
                            });
                          },
                          key: Key(projectName),
                          child: Card(
                            color: Colors.accents[sum % Colors.accents.length],
                            child: ListTile(
                              title: Text(projectName, textAlign: TextAlign.center,),
                              enabled: false,
                            ),
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


  Function _getConfirmDelete(String projName) {
    return (DismissDirection direction) async {
      final bool res = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Are you sure you wish to delete the project name '$projName'?"),
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

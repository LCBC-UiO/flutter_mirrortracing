import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mirrortask/helper.dart';
import 'package:mirrortask/settings.dart';
import 'package:crypto/crypto.dart';
import 'package:mirrortask/visitdata.dart';
import 'objimgloader.dart';
import 'scgetwaveid.dart';
import 'scstart.dart';

/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/

class GetProjectIdScreen extends StatefulWidget {
  final VisitData visitData;
  final ObjImg objImg;
  final int trialId;

  GetProjectIdScreen({
    @required this.visitData,
    @required this.objImg,
    @required this.trialId,
  });

  // skip this page if no projects are configured
  static Widget getRoute({
    @required VisitData visitData,
    @required ObjImg objImg,
    @required int trialId,
  }) {
    if (LcSettings().getStrList(LcSettings.PROJECT_IDS_STRLIST).isEmpty) {
      visitData.projectId = "NA";
      return GetWaveIdScreen.getRoute(
        objImg: objImg,
        trialId: trialId,
        visitData: visitData,
      );
    }
    return GetProjectIdScreen(
      objImg: objImg,
      trialId: trialId,
      visitData: visitData,
    );
  }

  @override
  _GetProjectIdScreenState createState() => _GetProjectIdScreenState();
}

/*----------------------------------------------------------------------------*/

class _GetProjectIdScreenState extends State<GetProjectIdScreen> {
  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      iconPrev: Icon(Icons.close),
      onPrev: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => StartScreen()
          )
        );
      },
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
                    child: Text("Select a project ID",)
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
                        return Card(
                          color: Colors.accents[sum % Colors.accents.length],
                          child: ListTile(
                            title: Text(projectName, textAlign: TextAlign.center,),
                            onTap: () async {
                              widget.visitData.projectId = projectName;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => GetWaveIdScreen.getRoute(
                                    objImg:    widget.objImg,
                                    trialId:   widget.trialId,
                                    visitData: widget.visitData,
                                  ),
                                )
                              );
                            }
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

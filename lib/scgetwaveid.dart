import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mirrortask/helper.dart';
import 'package:mirrortask/scdraw.dart';
import 'package:mirrortask/settings.dart';
import 'package:crypto/crypto.dart';
import 'package:mirrortask/visitdata.dart';
import 'objimgloader.dart';
import 'scstart.dart';

/*----------------------------------------------------------------------------*/

class GetWaveIdScreen extends StatefulWidget {
  final VisitData visitData;
  final ObjImg objImg;
  final int trialId;

  GetWaveIdScreen({
    @required this.visitData,
    @required this.objImg,
    @required this.trialId,
  });

  // skip this page if no wave IDs are configured
  static Widget getRoute({
    @required VisitData visitData,
    @required ObjImg objImg,
    @required int trialId,
  }) {
    if (LcSettings().getStrList(LcSettings.WAVE_IDS_STRLIST).isEmpty) {
      visitData.waveId = "NA";
      return DrawScreen(
        objImg: objImg,
        trialId: trialId,
        visitData: visitData,
      );
    }
    return GetWaveIdScreen(
      objImg: objImg,
      trialId: trialId,
      visitData: visitData,
    );
  }

  @override
  _GetWaveIdScreenState createState() => _GetWaveIdScreenState();
}

/*----------------------------------------------------------------------------*/

class _GetWaveIdScreenState extends State<GetWaveIdScreen> {
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
          List<String> r = LcSettings().getStrList(LcSettings.WAVE_IDS_STRLIST);
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
                    child: Text("Select a wave ID",)
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
                        final String waveId = snapshot.data[index];
                        final List<int> bytes = md5.convert(utf8.encode(waveId)).bytes.sublist(0, 4);
                        final int sum = bytes.fold(0, (p, c) => (p + c));
                        return Card(
                          color: Colors.accents[sum % Colors.accents.length],
                          child: ListTile(
                            title: Text(waveId, textAlign: TextAlign.center,),
                            onTap: () async {
                              widget.visitData.waveId = waveId;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => DrawScreen(
                                    visitData: widget.visitData,
                                    objImg: widget.objImg,
                                    trialId: widget.trialId,
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
}

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mirrortask/helper.dart';
import 'package:mirrortask/settings.dart';
import 'package:crypto/crypto.dart';

/*----------------------------------------------------------------------------*/

class ConfigureWaveIdsScreen extends StatefulWidget {
  @override
  _ConfigureWaveIdsScreenState createState() => _ConfigureWaveIdsScreenState();
}

/*----------------------------------------------------------------------------*/

class _ConfigureWaveIdsScreenState extends State<ConfigureWaveIdsScreen> {
  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      onNext: () async {
        String waveId = await showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text("new wave ID:"),
            content: CupertinoTextField(
              autofocus: true,
              onSubmitted: (v) async {
                Navigator.of(context).pop(v);
              },
            ),
          )
        );
        if (waveId != null) {
          Set<String> waveIds = LcSettings().getStrList(LcSettings.WAVE_IDS_STRLIST).toSet();
          waveIds.add(waveId);
          await LcSettings().setStrList(LcSettings.WAVE_IDS_STRLIST, waveIds.toList());
          setState(() {
          });
        }
      },
      iconNext: Icon(Icons.add),
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
                    child: Text("Configured wave IDs:",)
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
                        return Dismissible(
                          confirmDismiss: _getConfirmDelete(waveId),
                          onDismissed: (e) async {
                            Set<String> waveIds = LcSettings().getStrList(LcSettings.WAVE_IDS_STRLIST).toSet();
                            waveIds.remove(waveId);
                            snapshot.data.remove(waveId);
                            await LcSettings().setStrList(LcSettings.WAVE_IDS_STRLIST, waveIds.toList());
                            setState(() {
                            });
                          },
                          key: Key(waveId),
                          child: Card(
                            color: Colors.accents[sum % Colors.accents.length],
                            child: ListTile(
                              title: Text(waveId, textAlign: TextAlign.center,),
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


  Function _getConfirmDelete(String waveId) {
    return (DismissDirection direction) async {
      final bool res = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Are you sure you wish to delete the wave ID '$waveId'?"),
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

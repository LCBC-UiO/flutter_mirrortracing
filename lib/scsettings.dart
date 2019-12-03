import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/helper.dart';
import 'package:mirrortask/sccfgprojectid.dart';
import 'package:mirrortask/scsethomepos.dart';
import 'package:mirrortask/settings.dart';

import 'resultdata.dart';
import 'sccfgwaveid.dart';
import 'scsetsize.dart';

/*----------------------------------------------------------------------------*/

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

/*----------------------------------------------------------------------------*/

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return LcScaffold(
      body:  DefaultTextStyle(
        style: theme.primaryTextTheme.subhead,
        child: _SettingsList(),
      )
    );
  }
}

class _SettingsList  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 124.0),
      children: <Widget>[
        const _Heading('Options'),
        _ActionItem(
          "Configure project IDs",
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ConfigureProjectIdsScreen(),
              )
            );
          }
        ),
        _ActionItem(
          "Configure wave IDs",
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ConfigureWaveIdsScreen(),
              )
            );
          }
        ),
        _ActionItem(
          "Configure size of shape",
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SetSizeScreen(),
              )
            );
          }
        ),
        _ActionItem(
          "Configure home area",
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SetHomeAreaPositionScreen(),
              )
            );
          }
        ),
        _ActionItem(
          "Set nettskjema ID (public form)",
          () async {
            String msg = "Nettskjema ID tested successfully";
            await showDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text("Nettskjema ID"),
                content: CupertinoTextField(
                  controller: TextEditingController(text: LcSettings().getInt(LcSettings.NETTSKJEMA_ID_INT).toString()),
                  autofocus: true,
                  onSubmitted: (v) async {
                    final nettskjemaId = int.tryParse(v);
                    try {
                      await ResultData.testNettskjema(nettskjemaId);
                    } catch (e) {
                      msg = "Error: ${e.toString()}";
                    }
                    await LcSettings().setInt(LcSettings.NETTSKJEMA_ID_INT, int.tryParse(v));
                    Navigator.pop(context);
                  },
                ),
              )
            );
            final snackBar = SnackBar(content: Text(msg));
            Scaffold.of(context).showSnackBar(snackBar);
            print(msg);
          }
        ),
        _ActionItem(
          "Set subject ID input regular expression",
          () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text("subject ID regex"),
                content: CupertinoTextField(
                  controller: TextEditingController(text: LcSettings().getStr(LcSettings.USER_ID_REGEX_STR)),
                  autofocus: true,
                  onSubmitted: (v) async {
                    await LcSettings().setStr(LcSettings.USER_ID_REGEX_STR, v);
                    Navigator.pop(context);
                  },
                ),
              )
            );
          }
        ),
        _ActionItem(
          "Set subject ID input hint",
          () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text("subject ID input hint"),
                content: CupertinoTextField(
                  controller: TextEditingController(text: LcSettings().getStr(LcSettings.USER_ID_HINT_STR)),
                  autofocus: true,
                  onSubmitted: (v) async {
                    await LcSettings().setStr(LcSettings.USER_ID_HINT_STR, v);
                    Navigator.pop(context);
                  },
                ),
              )
            );
          }
        ),
      ]
    );
  }
}

/*----------------------------------------------------------------------------*/

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return _OptionsItem(
      child: DefaultTextStyle(
        style: theme.textTheme.body1.copyWith(
          fontFamily: 'GoogleSans',
          color: theme.accentColor,
        ),
        child: Semantics(
          child: Text(text),
          header: true,
        ),
      ),
    );
  }
}


const double _kItemHeight = 48.0;
const EdgeInsetsDirectional _kItemPadding = EdgeInsetsDirectional.only(start: 56.0);

class _OptionsItem extends StatelessWidget {
  const _OptionsItem({ Key key, this.child }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return MergeSemantics(
      child: Container(
        constraints: BoxConstraints(minHeight: _kItemHeight * textScaleFactor),
        padding: _kItemPadding,
        alignment: AlignmentDirectional.centerStart,
        child: DefaultTextStyle(
          style: DefaultTextStyle.of(context).style,
          maxLines: 2,
          overflow: TextOverflow.fade,
          child: IconTheme(
            data: Theme.of(context).primaryIconTheme,
            child: child,
          ),
        ),
      ),
    );
  }
}


class _ActionItem extends StatelessWidget {
  const _ActionItem(this.text, this.onTap);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _OptionsItem(
      child: _FlatButton(
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}

class _FlatButton extends StatelessWidget {
  const _FlatButton({ Key key, this.onPressed, this.child }) : super(key: key);

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.subhead,
        child: child,
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/helper.dart';
import 'package:mirrortask/settings.dart';

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
        child: ListView(
          padding: const EdgeInsets.only(bottom: 124.0),
          children: <Widget>[
            const _Heading('Options'),
            _ActionItem(
              "Configure display size",
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SetSizeScreen(),
                  )
                );
              }
            ),
            _ActionItem(
              "Set nettskjema ID (public form)",
              () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text("Nettskjema ID"),
                    content: CupertinoTextField(
                      controller: TextEditingController(text: LcSettings().getInt(LcSettings.NETTSKJEMA_ID_INT).toString()),
                      autofocus: true,
                      onSubmitted: (v) async {
                        await LcSettings().setInt(LcSettings.NETTSKJEMA_ID_INT, int.tryParse(v));
                        Navigator.pop(context);
                      },
                    ),
                  )
                );
              }
            )
            //const Divider(),
          ]
        )
      )
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
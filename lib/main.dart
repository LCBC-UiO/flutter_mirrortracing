import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/scselectcfg.dart';
import 'package:mirrortask/settings.dart';
import 'db.dart';

/*----------------------------------------------------------------------------*/

void main() async {
  LcDb().addListener(LcSettings());
  await LcDb().init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MirrorTracingApp()
  );
}

/*----------------------------------------------------------------------------*/

class MirrorTracingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LCBC Mirror Tracing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SelectConfigScreen(),
    );
  }
}
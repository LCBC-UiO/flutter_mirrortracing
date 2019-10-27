import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/scinit.dart';
import 'package:mirrortask/settings.dart';
import 'db.dart';
import 'scstart.dart';

/*----------------------------------------------------------------------------*/

void main() async {
  LcDb().addListener(LcSettings());
  await LcDb().init();
  await LcSettings().init("Test");
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
    final bool hasInit = LcSettings().isDef(LcSettings.SCREEN_WIDTH_CM_DBL);
    return MaterialApp(
      title: 'LCBC Mirror Tracing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: hasInit ? StartScreen() : InitScreen(),
    );
  }
}
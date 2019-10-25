import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/scinit.dart';
import 'package:mirrortask/settings.dart';
import 'scstart.dart';

/*----------------------------------------------------------------------------*/

// start
// - paint
// - config

// config
// - box/obj sizes
// - nettskjema

// paint
// - paint-done
// - reset -> confirm -> start

// paint-done
// - reset -> confirm -> start
// - upload
// - save

/*----------------------------------------------------------------------------*/

void main() async {
  await LcSettings().init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MyApp()
  );
}

/*----------------------------------------------------------------------------*/

class MyApp extends StatelessWidget {
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
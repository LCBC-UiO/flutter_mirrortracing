import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:mirrortask/db.dart';
import 'package:mirrortask/scselectcfg.dart';
import 'package:mirrortask/settings.dart';

/*----------------------------------------------------------------------------*/

class InitScreen extends StatefulWidget {

  @override
  InitScreenState createState() => InitScreenState();
}

class InitScreenState extends State<InitScreen> {

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // init stuff, that need the app to be started
      LcDb().addListener(LcSettings());
      await LcDb().init();
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectConfigScreen()));
    });
    return Scaffold(
      backgroundColor: Colors.white,
    );
  }
}

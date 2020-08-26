import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/scinit.dart';

/*----------------------------------------------------------------------------*/

void main() async { 
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
      home: InitScreen(),
    );
  }
}
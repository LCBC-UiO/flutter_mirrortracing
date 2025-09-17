import 'package:flutter/material.dart';
import 'package:mirrortask/scinit.dart';

/*----------------------------------------------------------------------------*/

void main() { 
  runApp(
    const MirrorTracingApp()
  );
}

/*----------------------------------------------------------------------------*/

class MirrorTracingApp extends StatelessWidget {
  const MirrorTracingApp({super.key});
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

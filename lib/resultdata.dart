import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/imgevaluation.dart';
import 'package:mirrortask/pentrajectory.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

/*----------------------------------------------------------------------------*/

class ResultData {
  final String userId;
  final DateTime date;
  final ImgEvaluation imgEval;
  final PenTrajectory trajectory;
  final double canvasWidth;

  ResultData({
    @required this.userId,
    @required this.date,
    @required this.imgEval,
    @required this.trajectory,
    @required this.canvasWidth,
  });

  Map<String,String> toNettskjemaMap() {
    return {
      "user_id": userId,
      "date": date.toIso8601String(),
      "total_time_ms": trajectory.totalTime.toString(),
      "num_continuous_lines": trajectory.numContinuousLines.toString(),
      "num_samples": imgEval.numTotalSamples.toString(),
      "num_samples_outside": imgEval.numOutsideSamples.toString(),
      "num_boundary_crossings": imgEval.numBoundaryCrossings.toString(),
      "image_width_cm": canvasWidth.toString(),
      "image_png": base64Encode(img.encodePng(imgEval.drawing, level: 1)),
      "trajectory": trajectory.toJsonStr(),
    };
  }

  get _fnPrefix {
    final datestr = date.toString().split(".")[0].replaceAll(" ", "_").replaceAll(":", "-");
    return "${datestr}_$userId";
  }
  

  Future<void> saveLocally(context) async {
    print(_fnPrefix);
    final dir = Theme.of(context).platform == TargetPlatform.iOS 
      ? await getApplicationDocumentsDirectory()
      : await getExternalStorageDirectory();
    File f;
    f = File("${dir.path}/mirrortrace_${_fnPrefix}_image.png");
    await f.writeAsBytes(img.encodePng(imgEval.drawing, level: 1));
    f = File("${dir.path}/mirrortrace_${_fnPrefix}_info.txt");
    await f.writeAsString(
      '"total_time_ms: ${trajectory.totalTime.toString()}\n'
      '"num_continuous_lines: ${trajectory.numContinuousLines.toString()}\n'
      '"num_samples: ${imgEval.numTotalSamples.toString()}\n'
      '"num_samples_outside: ${imgEval.numOutsideSamples.toString()}\n'
      '"num_boundary_crossings: ${imgEval.numBoundaryCrossings.toString()}\n'
      '"image_width_cm: ${canvasWidth.toString()}\n'
    );
    f = File("${dir.path}/mirrortrace_${_fnPrefix}_trajectory.json");
    await f.writeAsString(trajectory.toJsonStr());
  }
}

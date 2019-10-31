import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirrortask/imgevaluation.dart';
import 'package:mirrortask/pentrajectory.dart';
import 'package:mirrortask/settings.dart';
import 'package:nettskjema/nettskjema.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'helper.dart';

/*----------------------------------------------------------------------------*/

class ResultData {
  final String userId;
  final DateTime date;
  final String comment;
  final ImgEvaluation imgEval;
  final PenTrajectory trajectory;
  final double canvasWidth;

  ResultData({
    @required this.userId,
    @required this.date,
    @required this.comment,
    @required this.imgEval,
    @required this.trajectory,
    @required this.canvasWidth,
  });

  Map<String,String> _toNettskjemaMap() {
    return {
      enumToString(_NettskjemaFieldNames.profile_id): LcSettings().getStr(LcSettings.RANDOM_32_STR),
      enumToString(_NettskjemaFieldNames.user_id): userId,
      enumToString(_NettskjemaFieldNames.date): date.toIso8601String(),
      enumToString(_NettskjemaFieldNames.comment): comment,
      enumToString(_NettskjemaFieldNames.total_time_ms): trajectory.totalTime.toString(),
      enumToString(_NettskjemaFieldNames.num_continuous_lines): trajectory.numContinuousLines.toString(),
      enumToString(_NettskjemaFieldNames.num_samples): imgEval.numTotalSamples.toString(),
      enumToString(_NettskjemaFieldNames.num_samples_outside): imgEval.numOutsideSamples.toString(),
      enumToString(_NettskjemaFieldNames.num_boundary_crossings): imgEval.numBoundaryCrossings.toString(),
      enumToString(_NettskjemaFieldNames.image_width_cm): canvasWidth.toStringAsFixed(1),
      enumToString(_NettskjemaFieldNames.image_png): base64Encode(img.encodePng(imgEval.drawing, level: 1)),
      enumToString(_NettskjemaFieldNames.trajectory): trajectory.toJsonStr(),
    };
  }

  get _fnPrefix {
    final datestr = date.toString().split(".")[0].replaceAll(" ", "_").replaceAll(":", "-");
    return "${datestr}_$userId";
  }

  Future<void> uploadNettskjema() async {
    final int nettskjemaId = LcSettings().getInt(LcSettings.NETTSKJEMA_ID_INT);
    NettskjemaPublic n = NettskjemaPublic(nettskjemaId: nettskjemaId);
    await n.upload(_toNettskjemaMap());
  }

  static Future<void> testNettskjema(nettskjemaId) async {
    final Map<String, int> f = await getSchemaFieldsPub(nettskjemaId);
    final List<String> e = _NettskjemaFieldNames.values.map( (e) => enumToString(e) ).toList();
    matchesExpectedSchemaFieldsPub(
      nettskjemaFields: f.keys.toList(),
      expectedFields: e
    );
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
      'total_time_ms: ${trajectory.totalTime.toString()}\n'
      'num_continuous_lines: ${trajectory.numContinuousLines.toString()}\n'
      'num_samples: ${imgEval.numTotalSamples.toString()}\n'
      'num_samples_outside: ${imgEval.numOutsideSamples.toString()}\n'
      'num_boundary_crossings: ${imgEval.numBoundaryCrossings.toString()}\n'
      'image_width_cm: ${canvasWidth.toStringAsFixed(1)}\n'
      'comment: $comment\n'
    );
    f = File("${dir.path}/mirrortrace_${_fnPrefix}_trajectory.json");
    await f.writeAsString(trajectory.toJsonStr());
  }


  static bool nettskjemaConfigured() {
    return LcSettings().getInt(LcSettings.NETTSKJEMA_ID_INT) > 0;
  }
}

/*----------------------------------------------------------------------------*/

enum _NettskjemaFieldNames {
  profile_id,
  user_id,
  date,
  comment,
  total_time_ms,
  num_continuous_lines,
  num_samples,
  num_samples_outside,
  num_boundary_crossings,
  image_width_cm,
  image_png,
  trajectory,
}
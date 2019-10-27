import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:mirrortask/scdraw.dart';

import 'pentrajectory.dart';

/*----------------------------------------------------------------------------*/

class ImgEvaluation {
  final img.Image drawing;
  final int numTotalSamples;
  final int numOutsideSamples;
  final int numBoundaryCrossings;

  ImgEvaluation({
    @required this.drawing,
    @required this.numTotalSamples,
    @required this.numOutsideSamples,
    @required this.numBoundaryCrossings,
  });

  static Future<ImgEvaluation> calculate({
    @required img.Image objMask,
    @required img.Image objBoudary,
    @required PictureDetails drawing,
    @required PenTrajectory trajectory,
    }) async {
      ReceivePort receivePort = ReceivePort();
      final ByteData drawingBytes = (await (await drawing.toImage()).toByteData());
      final param = _IsolateParam(
        receivePort.sendPort,
        drawingBytes,
        drawing.width,
        objMask,
        objBoudary,
        trajectory,
      );
      await Isolate.spawn(_calcResultImage, param);
      final r = await receivePort.first as ImgEvaluation;
      return r;
  }
}

/*----------------------------------------------------------------------------*/

class _IsolateParam {
  final ByteData drawingBytes;
  final int drawingWidth;
  final img.Image objMask;
  final img.Image objBoudary;
  final SendPort sendPort;
  final PenTrajectory trajectory;
  _IsolateParam(this.sendPort, this.drawingBytes, this.drawingWidth, this.objMask, this.objBoudary, this.trajectory);
}

/*----------------------------------------------------------------------------*/

void _calcResultImage(_IsolateParam param) {
  final List<int> bytes = (param.drawingBytes.buffer).asUint8List(
    param.drawingBytes.offsetInBytes, 
    param.drawingBytes.lengthInBytes
  );
  img.Image dimg = img.Image.fromBytes(
    param.drawingWidth,
    param.drawingWidth,
    bytes,
  );
  assert(param.objMask.width == dimg.width);
  assert(param.objMask.height == dimg.height);
  assert(param.objMask.width == param.objBoudary.width);
  assert(param.objMask.height == param.objBoudary.height);
  for (int j = 0; j < dimg.height; j++) {
    for (int i = 0; i < dimg.width; i++) {
      final bool isInside   = img.getAlpha(param.objMask.getPixel(i, j)) > 0;
      final bool isBoundary = img.getAlpha(param.objBoudary.getPixel(i, j)) > 0;
      final bool hasPaint   = img.getRed(dimg.getPixel(i, j)) > 0;
      final r = hasPaint ? 255 : 0;
      final g = isInside && ! isBoundary  ? 255 : 0;
      final b = isBoundary ? 255 : 0;
      final a = hasPaint || isInside || isBoundary  ? 255 : 0;
      dimg.setPixelSafe(i, j, img.getColor(r, g, b, a));
    }
  }
  final t = param.trajectory.trajectory;
  int numTotalSamples = 0;
  int numOutsideSamples = 0;
  int numBoundaryCrossings = 0;
  bool lastIsInside;
  for (int k = 0; k < t.length; k++) {
    for (int l = 0; l < t[k].length; l++) {
      final i = t[k][l].posX;
      final j = t[k][l].posY;
      final bool isInside   = img.getAlpha(param.objMask.getPixel(i, j)) > 0;
      final bool isBoundary = img.getAlpha(param.objBoudary.getPixel(i, j)) > 0;
      numTotalSamples++;
      numOutsideSamples += isInside || isBoundary ? 0 : 1;
      // calc boundary crossing only when not on boundary
      if (! isBoundary) {
        if (lastIsInside != null && lastIsInside != isInside) {
          numBoundaryCrossings++;
        }
        lastIsInside = isInside;
      }
    }
  }
  param.sendPort.send(
    ImgEvaluation(
      drawing: dimg,
      numOutsideSamples: numOutsideSamples,
      numTotalSamples: numTotalSamples,
      numBoundaryCrossings: numBoundaryCrossings,
    )
  );
}
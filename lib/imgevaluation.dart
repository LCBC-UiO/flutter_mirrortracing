import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:mirrortask/scdraw.dart';

/*----------------------------------------------------------------------------*/

class ImgEvaluation {
  final img.Image drawing;
  final int numTotalPixels;
  final int numOutsidePixels;

  ImgEvaluation({
    @required this.drawing,
    @required this.numTotalPixels,
    @required this.numOutsidePixels,
  });

  static Future<ImgEvaluation> calculate({
    @required img.Image objMask,
    @required img.Image objBoudary,
    @required PictureDetails drawing,
    }) async {
      ReceivePort receivePort = ReceivePort();
      final ByteData drawingBytes = (await (await drawing.toImage()).toByteData());
      final param = _IsolateParam(
        receivePort.sendPort,
        drawingBytes,
        drawing.width,
        objMask,
        objBoudary,
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
  _IsolateParam(this.sendPort, this.drawingBytes, this.drawingWidth, this.objMask, this.objBoudary);
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
  int numTotalPixels = 0;
  int numOutsidePixels = 0;
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
      numTotalPixels   += hasPaint ? 1 : 0;
      numOutsidePixels += hasPaint && ! isInside ? 1 : 0;
    }
  }
  param.sendPort.send(
    ImgEvaluation(
      drawing: dimg,
      numOutsidePixels: numOutsidePixels,
      numTotalPixels: numTotalPixels,
    )
  );
}
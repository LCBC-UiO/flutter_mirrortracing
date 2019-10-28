import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:mirrortask/settings.dart';

/*----------------------------------------------------------------------------*/

class ObjImg {
  final img.Image mask;
  final img.Image boundary;
  ObjImg({
    @required this.mask,
    @required this.boundary,
  });
}

/*----------------------------------------------------------------------------*/

Future<ObjImg> loadObjImg({int boxWidth, int objWidth}) async {
  final String objFn = LcSettings().getStr(LcSettings.OBJECT_PATH_STR);
  final ByteData assetBytes = (await rootBundle.load(objFn));
  ReceivePort receivePort = ReceivePort();
  final param = _IsolateParam(
    receivePort.sendPort,
    assetBytes,
    boxWidth,
    objWidth,
  );
  await Isolate.spawn(_loadObjImg, param);
  final ObjImg r = await receivePort.first as ObjImg;
  return r;
}

/*----------------------------------------------------------------------------*/

class _IsolateParam {
  final ByteData assetBytes;
  final SendPort sendPort;
  final int objWidth;
  final int boxWidth;
  _IsolateParam(this.sendPort, this.assetBytes, this.boxWidth, this.objWidth);
}

/*----------------------------------------------------------------------------*/

void _loadObjImg(_IsolateParam param) {
  final buffer = param.assetBytes.buffer;
  List<int> bytes = buffer.asUint8List(param.assetBytes.offsetInBytes, param.assetBytes.lengthInBytes);
  img.Image objectRaw = img.decodePng(bytes);
  // create big canvas  - we will scale later
  img.Image canvasUnscaled = (){
    //final int cw = (objectRaw.width / LcSettings().getDouble(LcSettings.OBJECT_SIZE_DBL)).round();
    final int cw = (objectRaw.width * (param.boxWidth/param.objWidth)).round();
    img.Image c = img.Image(cw, cw);
    // set transparent
    c.fill(0xff000000);
    return c;
  }();
  // paste object into canvas
  assert(canvasUnscaled.width >=  objectRaw.width);
  final insetX = ((canvasUnscaled.width  - objectRaw.width ) / 2).round();
  final insetY = ((canvasUnscaled.height - objectRaw.height) / 2).round();
  canvasUnscaled = img.copyInto(canvasUnscaled, objectRaw, dstX: insetX, dstY: insetY);
  // scale
  final img.Image canvasScaled = img.copyResize(canvasUnscaled, width: param.boxWidth, height: param.boxWidth, interpolation: img.Interpolation.cubic);
  // create mask - use whatever is in the green or blue channel
  img.Image objMask = img.Image(canvasScaled.width, canvasScaled.width);
  for (int j = 0; j < canvasScaled.height; j++) {
    for (int i = 0; i < canvasScaled.width; i++) {
      final bool hasBlue  = img.getBlue(canvasScaled.getPixelSafe(i, j)) > 0;
      final bool hasGreen = img.getGreen(canvasScaled.getPixelSafe(i, j)) > 0;
      // set to black - transparent outside ok-area
      objMask.setPixelSafe(i, j,  (hasBlue || hasGreen) ?  0xff000000 : 0x00);
    }
  }
  // create visualization of boundaries - use blue channel
  img.Image objBoundary = img.Image(canvasScaled.width, canvasScaled.width);
  for (int j = 0; j < canvasScaled.height; j++) {
    for (int i = 0; i < canvasScaled.width; i++) {
      final int alpha  = img.getBlue(canvasScaled.getPixelSafe(i, j));
      // convert blue channel to alpha - whole image has black color
      objBoundary.setPixelSafe(i, j,  img.getColor(127, 127, 127, alpha));
    }
  }
  param.sendPort.send(
    ObjImg(
      mask: objMask,
      boundary: objBoundary,
    )
  );
}

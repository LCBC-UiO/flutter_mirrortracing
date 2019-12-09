import 'dart:convert';
import 'dart:io';
import 'package:nettskjema/nettskjema.dart';
import 'package:path/path.dart';
import 'package:args/args.dart';
import 'package:intl/intl.dart';


/// Usage: dart test/upload_saved_files.dart [nettskjema_id] [path] [filename_prefix]
///
///
///
///

ArgResults argResults;

enum NettskjemaFieldNames {
  subj_id,
  date,
  project_id,
  wave_id,
  image_png,
  image_width_cm,
  trajectory,
  profile_id,
  comment,
}
String enumToString(final o) => o.toString().split('.').last;


void main(List<String> arguments) async {
  exitCode = 0;
  final parser = ArgParser();

  argResults = parser.parse(arguments);

  final int nettskjemaId  = int.tryParse(argResults.rest[0]);
  final String path       = argResults.rest[1];
  final String fnprefix   = argResults.rest[2]; // mirrortrace_2019-12-09_13-34-07_bob


  print("$path $fnprefix");
  Map<String,String> nmap = {
    enumToString(NettskjemaFieldNames.subj_id): fnprefix.replaceAll(RegExp(r'.*_'),''),
    enumToString(NettskjemaFieldNames.date): () {
      DateFormat dateFormat = new DateFormat("'mirrortrace_'yyyy-MM-dd_HH-mm-ss");
      return dateFormat.parse(fnprefix);
    }().toIso8601String(),
    enumToString(NettskjemaFieldNames.project_id): _parseInfo('project_id',  path, fnprefix + '_info.txt' ),
    enumToString(NettskjemaFieldNames.wave_id): _parseInfo('wave_id',  path, fnprefix + '_info.txt' ),
    enumToString(NettskjemaFieldNames.image_png): base64Encode(File(join(path, fnprefix + '_image.png')).readAsBytesSync()),
    enumToString(NettskjemaFieldNames.image_width_cm): _parseInfo('image_width_cm',  path, fnprefix + '_info.txt' ),
    enumToString(NettskjemaFieldNames.trajectory): File(join(path, fnprefix + '_trajectory.json')).readAsStringSync(),
    enumToString(NettskjemaFieldNames.profile_id): 'command-line',
    enumToString(NettskjemaFieldNames.comment): _parseInfo('comment',  path, fnprefix + '_info.txt' ),
  };
  print(nmap);
  NettskjemaPublic n = NettskjemaPublic(nettskjemaId: nettskjemaId);
  print("upoloading to $nettskjemaId");
  await n.upload(nmap);
}

Future dcat(List<String> paths, bool showLineNumbers) async {
  if (paths.isEmpty) {
    // No files provided as arguments. Read from stdin and print each line.
    await stdin.pipe(stdout);
  } else {
    for (var path in paths) {
      var lineNumber = 1;
      final lines = utf8.decoder
          .bind(File(path).openRead())
          .transform(const LineSplitter());
      try {
        await for (var line in lines) {
          if (showLineNumbers) {
            stdout.write('${lineNumber++} ');
          }
          stdout.writeln(line);
        }
      } catch (_) {
        await _handleError(path);
      }
    }
  }
}

String _parseInfo(String key, String dir, String fn) {
  File f = File(join(dir,fn));
  List<String> lines = f.readAsLinesSync();
  for (String l in lines) {
    if (l.startsWith(key)) {
      return (l.replaceAll("$key: ", ''));
    }
  }
  return null;
}

Future _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('error: $path is a directory');
  } else {
    exitCode = 2;
  }
}
import 'dart:convert';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'db.dart';

/*----------------------------------------------------------------------------*/

class LcSettings implements DbListener {
  Set<String> _keys = Set();
  String _projectName;
  Map<String, String> _projectSettings;

  static const String RANDOM_32_STR            = "RANDOM_32_STR";
  static const String OBJECT_PATH_STR          = "OBJECT_PATH_STR";
  static const String RELATIVE_OBJECT_SIZE_DBL = "RELATIVE_OBJECT_SIZE_DBL";
  static const String RELATIVE_BOX_SIZE_DBL    = "RELATIVE_BOX_SIZE_DBL";
  static const String NETTSKJEMA_ID_INT        = "NETTSKJEMA_ID_INT";
  static const String SCREEN_WIDTH_CM_DBL      = "SCREEN_SIZE_CM_DBL";
  static const String HOME_POS_X_INT           = "HOME_POS_X_INT";
  static const String HOME_POS_Y_INT           = "HOME_POS_Y_INT";
  static const String HOME_INNER_RADIUS_INT    = "HOME_INNER_RADIUS_INT";
  static const String HOME_OUTER_RADIUS_INT    = "HOME_OUTER_RADIUS_INT";
  static const String PROJECT_IDS_STRLIST      = "PROJECT_IDS_STRLIST";
  static const String WAVE_IDS_STRLIST         = "WAVE_IDS_STRLIST";

  Future<void> init(String projectName) async {
    this._projectName = projectName;
    _keys.clear();
    _projectSettings = await _readFromDb(projectName);
    await _initValueStr(RANDOM_32_STR, await _generateRandom32());
    await _initValueStr(OBJECT_PATH_STR, "assets/star.png");
    await _initValueDouble(RELATIVE_OBJECT_SIZE_DBL, 0.9);
    await _initValueDouble(RELATIVE_BOX_SIZE_DBL,    0.9);
    await _initValueInt(NETTSKJEMA_ID_INT,   -1);
    await _initValueInt(HOME_POS_X_INT,   100);
    await _initValueInt(HOME_POS_Y_INT,   100);
    await _initValueInt(HOME_INNER_RADIUS_INT,  20);
    await _initValueInt(HOME_OUTER_RADIUS_INT,  50);
    await _initValueStrList(PROJECT_IDS_STRLIST,  List<String>());
    await _initValueStrList(WAVE_IDS_STRLIST,     List<String>());
    _keys.add(RANDOM_32_STR);
    _keys.add(SCREEN_WIDTH_CM_DBL);
  }

  @override
  Future<void> onInit() async {
    await LcDb().db().rawQuery(_kCreateTableSettings);
  }


  bool isDef(key) => _projectSettings.containsKey(key);

  Future<void> _initValueStr(String key, String v) async {
    _keys.add(key);
    if (isDef(key)) {
      return;
    }
    await setStr(key, v);
  }

  Future<void> _initValueInt(String key, int v) async {
    _keys.add(key);
    if (isDef(key)) {
      return;
    }
    await setInt(key, v);
  }

  Future<void> _initValueDouble(String key, double v) async {
    _keys.add(key);
    if (isDef(key)) {
      return;
    }
    await setDouble(key, v);
  }

  Future<void> _initValueStrList(String key, List<String> v) async {
    _keys.add(key);
    if (isDef(key)) {
      return;
    }
    await setStr(key, jsonEncode(v));
  }

  Future<int> setStr(String key, String v) async {
    final int r = await LcDb().db().insert(
      _kTableNameSettings,
      {
        "profile": _projectName,
        "key": key,
        "value": v,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // update cache
    _projectSettings = await _readFromDb(_projectName);
    return r;
  }

  Future<int> setInt(String key, int v) async {
    return setStr(key, v.toString());
  }
  Future<int> setDouble(String key, double v) async {
    return setStr(key, v.toString());
  }
  Future<int> setStrList(String key, List<String> v) async {
    return setStr(key, jsonEncode(v));
  }  

  String getStr(String key) {
    return _projectSettings[key];
  }
  int getInt(String key) {
    return int.tryParse(_projectSettings[key]);
  }
  double getDouble(String key) {
    return double.tryParse(_projectSettings[key]);
  }
  List<String> getStrList(String key) {
    return jsonDecode(_projectSettings[key]).cast<String>();
  }

  static Future<Map<String, String>> _readFromDb(String projectName) async {
    List<Map> q = await LcDb().db().query(
      _kTableNameSettings,
      columns: ["key","value"],
      where: "profile = ?",
      whereArgs: [ projectName ],
      orderBy: "profile",
    );
    Map<String, String> r = {};
    q.forEach((e) => r[e["key"]] = e["value"] );
    return r;
  }

  Future<List<String>> getConfigs()  async {
    List<Map> q = await LcDb().db().rawQuery(
      'SELECT DISTINCT profile FROM $_kTableNameSettings;'
    );
    List<String> c = [];
    q.forEach( (e) => c.add(e["profile"]) );
    return c;
  }

  Future<int> delete(String projectName) async {
    return await LcDb().db().delete(
      _kTableNameSettings,
      where: "profile = ?",
      whereArgs: [ projectName ],
    );
  }

  get activeConfigName => _projectName;

  static final LcSettings _singleton = new LcSettings._internal();

  factory LcSettings() {
    return _singleton;
  }

  LcSettings._internal();

  static Future<String> _generateRandom32() async {
    Random rand = Random();
    final rBytes = List<int>.generate(32, (i) => rand.nextInt(256));
    return base64Encode(rBytes);
  }
}

/*----------------------------------------------------------------------------*/

const String _kTableNameSettings = "settings";

/*----------------------------------------------------------------------------*/

const String _kCreateTableSettings = """
-- DROP TABLE IF EXISTS $_kTableNameSettings;
CREATE TABLE IF NOT EXISTS $_kTableNameSettings(
  profile TEXT,
  key     TEXT,
  value   TEXT,
  PRIMARY KEY (profile, key)
);
""";

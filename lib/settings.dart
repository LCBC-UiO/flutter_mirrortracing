import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*----------------------------------------------------------------------------*/

class LcSettings {
  static const String RANDOM_32_STR     = "RANDOM_32_STR";
  static const String OBJECT_SIZE_DBL   = "OBJECT_SIZE_DBL";
  static const String BOX_SIZE_DBL      = "BOX_SIZE_DBL";
  static const String NETTSKJEMA_ID_INT = "NETTSKJEMA_ID_INT";
  

  SharedPreferences _prefs;

  Set<String> _keys = Set();

  Future<void> init() async {
    _keys.clear();
    _prefs = await SharedPreferences.getInstance();
    await _initValueStr(RANDOM_32_STR, await _generateRAndom32());
    await _initValueDouble(OBJECT_SIZE_DBL, 0.9);
    await _initValueDouble(BOX_SIZE_DBL,    0.9);
    await _initValueInt(NETTSKJEMA_ID_INT,   -1);
  }

  Future<void> clear() async {
    for (var key in _keys) {
      await _prefs.remove(key);
    }
  }

  Future<void> _initValueInt(String key, int v) async {
    _keys.add(key);
    if (isDef(key)) {
      return;
    }
    await setInt(key, v);
  }

  Future<void> _initValueBool(String key, bool v) async {
    _keys.add(key);
    if (isDef(key)) {
      return;
    }
    await setBool(key, v);
  }

  Future<void> _initValueDouble(String key, double v) async {
    _keys.add(key);
    if (isDef(key)) {
      return;
    }
    await setDouble(key, v);
  }
  
  Future<void> _initValueStr(String key, String v) async {
    _keys.add(key);
    if (isDef(key)) {
      return;
    }
    await setStr(key, v);
  }

  bool isDef(key) => _prefs.containsKey(key);

  dynamic get(key) => _prefs.get(key);

  int getInt(String key) {
    return _prefs.getInt(key);
  }

  bool getBool(String key) {
    return _prefs.getBool(key);
  }

  double getDouble(String key) {
    return _prefs.getDouble(key);
  }

  String getStr(String key) {
    return _prefs.getString(key);
  }
  TimeOfDay getTimeOfDay(String key) {
    return _str2Tod(_prefs.getString(key));
  }

  DateTime getDateTime(String key) {
    return DateTime.parse(_prefs.getString(key));
  }

  Map<String, String> getAll() {
    Map<String, String> r = {};
    _prefs.getKeys().forEach((k){
      r[k] = _prefs.get(k).toString();
    });
    return r;
  }

  Future<bool> setInt(String key, int v) async {
    return _prefs.setInt(key, v);
  }
  Future<bool> setBool(String key, bool v) async {
    return _prefs.setBool(key, v);
  }
  Future<bool> setStr(String key, String v) async {
    return _prefs.setString(key, v);
  }
  Future<bool> setDouble(String key, double v) async {
    return _prefs.setDouble(key, v);
  }  
  Future<bool> setTimeofDay(String key, final TimeOfDay v) async {
    return _prefs.setString(key, _tod2Str(v));
  }

  Future<bool> setDatetime(String key, final DateTime v) async {
    return _prefs.setString(key, v.toIso8601String());
  }

  String _tod2Str(final TimeOfDay t) {
    return t.hour.toString().padLeft(2, "0") + ":" + t.minute.toString().padLeft(2, "0");
  }

  TimeOfDay _str2Tod(String s, {String del = ":"}) {
    List<String> l = s.split(":");
    return TimeOfDay(hour:int.parse(l[0]), minute: int.parse(l[1]));
  }

  static Future<String> _generateRAndom32() async {
    Random rand = Random();
    final rBytes = List<int>.generate(32, (i) => rand.nextInt(256));
    return base64Encode(rBytes);
  }

  static final LcSettings _singleton = new LcSettings._internal();

  factory LcSettings() {
    return _singleton;
  }

  LcSettings._internal();
}
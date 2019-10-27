import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/*----------------------------------------------------------------------------*/

class LcDb {
  Database _db;
  Set<DbListener> _listeners = Set<DbListener>();

  void addListener(final DbListener l) {
    _listeners.add(l);
  }

  Future<void> init() async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), 'sqlite.db'),
      version: 1,
    );
    for (var e in _listeners) {
      await e.onInit();
    }
  }

  Database db() => this._db;

  static final LcDb _singleton = new LcDb._internal();

  factory LcDb() {
    return _singleton;
  }

  LcDb._internal();
}

/*----------------------------------------------------------------------------*/

abstract class DbListener {
  Future<void> onInit();
}

/*----------------------------------------------------------------------------*/

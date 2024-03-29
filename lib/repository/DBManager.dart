import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:financial_systems_coursework/model/Stock.dart';

import 'package:meta/meta.dart';

/// This objects gets stored in the Database.
/// Each StockDBEntry holds a record for a series of datapoints
/// for a certain ticker
class StockDBEntry {
  int id;
  String ticker;
  int fromTimestamp;
  int toTimestamp;
  String values;

  StockDBEntry(
      {this.id = -1,
      this.ticker,
      this.fromTimestamp,
      this.toTimestamp,
      this.values});

  StockDBEntry.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.ticker = map['ticker'];
    this.fromTimestamp = map['fromTimestamp'];
    this.toTimestamp = map['toTimestamp'];
    this.values = map['jsonValues'];
  }

  Map<String, dynamic> get map {
    final Map<String, dynamic> res = {
      'ticker': this.ticker,
      'fromTimestamp': this.fromTimestamp,
      'toTimestamp': this.toTimestamp,
      'jsonValues': this.values
    };
    if (this.id != -1) {
      res['id'] = this.id;
    }
    return res;
  }

  @override
  String toString() {
    return 'Stock DB Entry{ ticker: $ticker, id: $id, from: $fromTimestamp, to: $toTimestamp}\n';
  }
}

class DBManager {
  static final String _createDBSQL = '''CREATE TABLE STOCKS(
            id INTEGER PRIMARY KEY,
            ticker TEXT,
            fromTimestamp INTEGER,
            toTimestamp INTEGER,
            jsonValues TEXT
          )''';
  static final _stocksTable = 'STOCKS';
  static final int _oneDay = 86400000;

  static final DBManager _instance = DBManager._init();
  Future<Database> _db;
  final String _dbName = 'stocksApp.db';

  DBManager._init() {
    WidgetsFlutterBinding.ensureInitialized();
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _db = _initDB();
    } else {
      debugPrint('Testing!');
    }
  }

  factory DBManager() {
    return _instance;
  }

  Future<Database> _initDB() async {
    Database db = await openDatabase(join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) async {
      await db.execute(_createDBSQL);
    }, version: 1);
    debugPrint('Database has been created!');
    return db;
  }

  Future<void> deleteDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    await deleteDatabase(join(await getDatabasesPath(), _dbName));
    debugPrint('DB has been deleted!');
  }

  Future<Database> get db {
    return _db;
  }

  @visibleForTesting
  set testDB(Database db) {
    _db = Future<Database>.value(db);
  }

  /// Check if there's a cache entry for a certain ticker
  /// between two timestamps
  Future<bool> isCached(String ticker, int from, int to) async {
    StockDBEntry _entry = await _getByTicker(ticker);
    return _entry != null &&
        from >= _entry.fromTimestamp &&
        to <= _entry.toTimestamp &&
        ticker == _entry.ticker;
  }

  Future<StockDBEntry> _getByTicker(String ticker) async {
    Database db = await _db;
    return await db.transaction((txn) async {
      List<Map<String, dynamic>> maps =
          await txn.query(_stocksTable, where: 'ticker = \'$ticker\'');
      if (maps.isEmpty) {
        return null;
      } else {
        return StockDBEntry.fromMap(maps.first);
      }
    });
  }

  /// Get a List of Stocks representing a timeseries of Stock data points
  /// Warning! This method makes no assumptions! It should only be called
  /// if you are sure that the cached values exist in the DB!
  Future<List<Stock>> _unsafeGetFromDB(String ticker, int from, int to) async {
    StockDBEntry _entry = await _getByTicker(ticker);
    List<Stock> _stocks = Stock.jsonToStocks(ticker, jsonDecode(_entry.values));
    List<Stock> res = _stocks
        .where((s) =>
            s.timestamp ~/ 1000 >= from - _oneDay && s.timestamp ~/ 1000 <= to)
        .toList();
    debugPrint(
        'Found: ${res.length.toString()} stocks. Initially ${_stocks.length.toString()} stocks.');
    return res;
  }

  Future<List<Stock>> getFromDBOrNull(String ticker, int from, int to) async {
    bool _isCached = await isCached(ticker, from, to);
    if (!_isCached) {
      debugPrint('Cache miss for: $ticker');
      return null;
    } else {
      debugPrint('Cache hit for: $ticker');
      return _unsafeGetFromDB(ticker, from, to);
    }
  }

  /// Delete old cache entries for this ticker, if they exist,
  /// and update the cache with new entries.
  /// 'values' is expected to be a JSON-like object encoded as
  /// a string, representing the body of the request returned
  /// by a call to Yahoo! Finance.
  Future<void> refreshCache(
      String ticker, int from, int to, String values) async {
    Database db = await _db;
    await db.transaction((txn) async {
      await txn.delete(_stocksTable, where: 'ticker = \'$ticker\'');
      return;
    });
    StockDBEntry entry = StockDBEntry(
        ticker: ticker, fromTimestamp: from, toTimestamp: to, values: values);
    await db.transaction((txn) async {
      await txn.insert(_stocksTable, entry.map);
      return true;
    });
    debugPrint('Cache for $ticker has been refreshed.');
  }

  Future<void> printCache() async {
    Database db = await _db;
    List<Map<String, dynamic>> maps = await db.transaction((txn) async {
      return await txn.query(_stocksTable);
    });
    debugPrint(maps.toString());
  }
}

/// Helper main used for testing the db. Shouldn't be used.
void main() async {
  Database db = await DBManager().db;
  List<Map<String, dynamic>> maps = await db.transaction((txn) async {
    return await txn.query('STOCKS');
  });
  debugPrint(maps.toString());
  await DBManager().deleteDB();
}

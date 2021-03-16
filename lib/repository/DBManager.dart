import 'dart:convert';

import 'package:financial_systems_coursework/shared/interval.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:financial_systems_coursework/model/Stock.dart';

class StockDBEntry {
  int id;
  String ticker;
  int fromTimestamp;
  int toTimestamp;
  StockInterval interval;
  String values;

  StockDBEntry(
      {this.id = -1,
      this.fromTimestamp,
      this.toTimestamp,
      this.interval,
      this.values});

  StockDBEntry.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.ticker = map['ticker'];
    this.fromTimestamp = map['fromTimestamp'];
    this.toTimestamp = map['toTimestamp'];
    this.interval = IntervalMapping.fromString(map['interval']);
    this.values = map['values'];
  }

  Map<String, dynamic> get map {
    final Map<String, dynamic> res = {
      'ticker': this.ticker,
      'fromTimestamp': this.fromTimestamp,
      'toTimestamp': this.toTimestamp,
      'interval': this.interval.name,
      'values': this.values
    };
    if (this.id == -1) {
      res['id'] = this.id;
    }
    return res;
  }
}

class DBManager {
  static final DBManager _instance = DBManager._init();
  Future<Database> _db;

  DBManager._init() {
    WidgetsFlutterBinding.ensureInitialized();
    _db = _initDB();
  }

  factory DBManager() {
    return _instance;
  }

  Future<Database> _initDB() async {
    Database db =
        await openDatabase(join(await getDatabasesPath(), 'stocksApp.db'),
            onCreate: (db, version) async {
      await db.execute('''CREATE TABLE STOCKS(
            id INTEGER PRIMARY KEY,
            ticker TEXT,
            fromTimestamp INTEGER,
            toTimestamp INTEGER,
            interval TEXT,
            values TEXT
          )''');
    }, version: 1);
    debugPrint('Database has been created!');
    return db;
  }

  Future<Database> get db {
    return _db;
  }

  Future<bool> isCached(
      String ticker, int from, int to, StockInterval interval) async {
    StockDBEntry _entry = await getByTicker(ticker);
    return _entry != null &&
        from >= _entry.fromTimestamp &&
        to <= _entry.toTimestamp &&
        interval == _entry.interval;
  }

  Future<StockDBEntry> getByTicker(String ticker) async {
    Database db = await _db;
    return await db.transaction((txn) async {
      List<Map<String, dynamic>> maps =
          await txn.query('STOCKS', where: 'ticker = $ticker');
      if (maps.isEmpty) {
        return null;
      } else {
        return StockDBEntry.fromMap(maps.first);
      }
    });
  }

  Future<List<Stock>> unsafeGetFromDB(String ticker, int from, int to) async {
    StockDBEntry _entry = await getByTicker(ticker);
    List<Stock> _stocks = Stock.jsonToStocks(ticker, jsonDecode(_entry.values));
    return _stocks.where((s) => s.timestamp >= from && s.timestamp <= to);
  }

  Future<List<Stock>> getFromDBOrNull(
      String ticker, int from, int to, StockInterval interval) async {
    bool _isCached = await isCached(ticker, from, to, interval);
    if (!_isCached) {
      debugPrint('Cache miss for: $ticker');
      return null;
    } else {
      debugPrint('Cache hit for: $ticker');
      return unsafeGetFromDB(ticker, from, to);
    }
  }

  Future<void> refreshCache(String ticker, int from, int to,
      StockInterval interval, String values) async {
    Database db = await _db;
    await db.transaction((txn) async {
      await txn.delete('STOCKS', where: 'ticker = $ticker');
    });
    StockDBEntry entry = StockDBEntry(
        fromTimestamp: from,
        toTimestamp: to,
        interval: interval,
        values: values);
    await db.transaction((txn) async {
      await txn.insert('STOCKS', entry.map);
    });
    debugPrint('Cache for $ticker has been refreshed.');
  }
}

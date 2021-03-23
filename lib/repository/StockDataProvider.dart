import 'dart:convert';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/repository/DBManager.dart';
import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:flutter/widgets.dart';

class StockDataProvider {
  static final StockDataProvider _instance = StockDataProvider._internal();
  DBManager _db;
  StockDataCollector _collector;
  StockDataProvider._internal() {
    _db = DBManager();
    _collector = StockDataCollector();
  }

  factory StockDataProvider() {
    return _instance;
  }

  @visibleForTesting
  set testDB(DBManager newDB) {
    _db = newDB;
  }

  @visibleForTesting
  set testCollector(StockDataCollector newCollector) {
    _collector = newCollector;
  }

  /// Try to get timeseries data from the DB cache.
  /// If this fails, get fresh data from Yahoo! Finance and
  /// update the cache.
  Future<List<Stock>> getPrices(String ticker, int from, int to) async {
    List<Stock> _fromDB = await _db.getFromDBOrNull(ticker, from, to);
    if (_fromDB == null) {
      String stocksJSON = await _collector.getPricesAsJSON(
          ticker, from.toString(), to.toString());
      await _db.refreshCache(ticker, from, to, stocksJSON);
      return Stock.jsonToStocks(ticker, jsonDecode(stocksJSON));
    } else {
      return _fromDB;
    }
  }
}

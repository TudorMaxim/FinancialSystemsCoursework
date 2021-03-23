import 'dart:io';

import 'package:financial_systems_coursework/repository/DBManager.dart';

class DummyData {
  final _values = File('./test_resources/DummyData.json').readAsString();
  final ticker = 'AAPL';
  final from = 1614895200;
  final to = 1615327200;

  Future<String> get values async {
    return await _values;
  }

  Future<StockDBEntry> get entry async {
    return StockDBEntry(
        ticker: ticker,
        fromTimestamp: from,
        toTimestamp: to,
        values: await _values);
  }
}

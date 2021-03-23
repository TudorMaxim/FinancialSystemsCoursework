import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:financial_systems_coursework/repository/DBManager.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../DummyDataProvider.dart';
import 'DBManager_test.mocks.dart';

@GenerateMocks([Database])
void main() async {
  final _mockDB = MockDatabase();
  DBManager().testDB = _mockDB;
  final _dummy = DummyData();

  group('Negative test Cache', () {
    test('No Cache', () {
      when(_mockDB.transaction(any)).thenAnswer((_) async => null);
      DBManager().isCached('AAPL', 0, 1).then((value) => expect(value, false));
    });
    test('Wrong timestamp', () {
      final _t = 'AAPL';
      final _from = 100;
      final _to = 1000;

      when(_mockDB.transaction(any)).thenAnswer((_) async => StockDBEntry(
          ticker: _t, fromTimestamp: _from, toTimestamp: _to, values: ''));
      DBManager()
          .isCached(_t, _from - 1, _to)
          .then((value) => expect(value, false));
      DBManager()
          .isCached(_t, _from, _to + 1)
          .then((value) => expect(value, false));
    });

    test('Wrong ticker', () {
      final _t1 = 'AAPL';
      final _t2 = 'MSFT';
      final _from = 0;
      final _to = 0;

      when(_mockDB.transaction(any)).thenAnswer((_) async => StockDBEntry(
          ticker: _t1, fromTimestamp: _from, toTimestamp: _to, values: ''));

      DBManager()
          .isCached(_t2, _from, _to)
          .then((value) => expect(value, false));
    });
  });
  group('Positive Test Cache', () {
    test('Get Record with same time range', () {
      when(_mockDB.transaction(any))
          .thenAnswer((_) async => await _dummy.entry);
      DBManager()
          .isCached(_dummy.ticker, _dummy.from, _dummy.to)
          .then((value) => expect(value, true));
      DBManager()
          .isCached(_dummy.ticker, _dummy.from + 1, _dummy.to - 1)
          .then((value) => expect(value, true));

      DBManager()
          .getFromDBOrNull(_dummy.ticker, _dummy.from, _dummy.to)
          .then((actual) async {
        List<Stock> expected =
            Stock.jsonToStocks(_dummy.ticker, jsonDecode(await _dummy.values));
        expect(actual.length, expected.length);
        for (int i = 0; i < expected.length; i++) {
          Stock e = expected[i];
          Stock a = actual[i];
          if (e.currentMarketPrice != a.currentMarketPrice ||
              e.ticker != a.ticker ||
              e.timestamp != a.timestamp) {
            fail('DBManager returned wrong number of stocks!');
          }
        }
      });
    });
  });
}

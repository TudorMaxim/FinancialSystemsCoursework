import 'dart:convert';

import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:financial_systems_coursework/repository/DBManager.dart';
import 'package:financial_systems_coursework/repository/StockDataProvider.dart';

import '../DummyDataProvider.dart';
import 'StockDataProvider_test.mocks.dart';

@GenerateMocks([StockDataCollector, DBManager])
void main() async {
  final _mockManager = MockDBManager();
  final _mockCollector = MockStockDataCollector();
  final _dummy = DummyData();
  StockDataProvider().testCollector = _mockCollector;
  StockDataProvider().testDB = _mockManager;

  group('Test StockDataProvider', () {
    test('Test Cache Hit', () async {
      when(_mockManager.getFromDBOrNull(any, any, any)).thenAnswer(
          (realInvocation) async => Stock.jsonToStocks(
              _dummy.ticker, jsonDecode(await _dummy.values)));

      List<Stock> expected =
          Stock.jsonToStocks(_dummy.ticker, jsonDecode(await _dummy.values));
      StockDataProvider()
          .getPrices(_dummy.ticker, _dummy.from, _dummy.to)
          .then((actual) async {
        expect(actual.length, expected.length);
        for (int i = 0; i < expected.length; i++) {
          Stock e = expected[i];
          Stock a = actual[i];
          if (e.timestamp != a.timestamp ||
              e.ticker != a.ticker ||
              e.currentMarketPrice != a.currentMarketPrice) {
            fail('StockDataProvider provided incorrect Stock data!');
          }
          verifyNever(_mockManager.refreshCache(any, any, any, any));
          verifyNever(_mockCollector.getPricesAsJSON(any, any, any));
        }
      });
    });

    test('Test Cache Miss', () async {
      when(_mockManager.getFromDBOrNull(any, any, any))
          .thenAnswer((realInvocation) => null);
      when(_mockCollector.getPricesAsJSON(any, any, any))
          .thenAnswer((realInvocation) async => await _dummy.values);
      when(_mockManager.refreshCache(
              _dummy.ticker, _dummy.from, _dummy.to, any))
          .thenAnswer((realInvocation) => null);

      List<Stock> expected =
          Stock.jsonToStocks(_dummy.ticker, jsonDecode(await _dummy.values));
      StockDataProvider()
          .getPrices(_dummy.ticker, _dummy.from, _dummy.to)
          .then((actual) async {
        expect(actual.length, expected.length);
        for (int i = 0; i < expected.length; i++) {
          Stock a = actual[i];
          Stock e = expected[i];
          if (a.timestamp != e.timestamp ||
              a.ticker != e.ticker ||
              a.currentMarketPrice != e.currentMarketPrice) {
            fail('StockDataProvider provided incorrect stock data!');
          }
        }
      });
    });
  });
}

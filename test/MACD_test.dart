import 'dart:convert';

import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/MACD.dart';
import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  List<Stock> stocks;
  MACD macd;

  setUp(() async {
    String stocksJSON = await StockDataCollector().getPricesAsJSON(
        "MSFT", "1569853800", "1616337000");

    /// Get list of stocks to compute MACD
    stocks = Stock.jsonToStocks("MSFT", jsonDecode(stocksJSON));

    macd = new MACD();
  });

  test("MACD test", () async {
    List<Point> actualMACDValues = macd.compute(stocks, 0, 318);

    List<Point> expectedMACDValues = [
    new Point(2.06, 1609770600000),
    new Point(1.7, 1609857000000),
    new Point(0.94, 1609943400000),
    new Point(0.82, 1610029800000),
    new Point(0.83, 1610116200000),
    new Point(0.65, 1610375400000),
    new Point(0.3, 1610461800000),
    new Point(0.14, 1610548200000),
    new Point(-0.26, 1610634600000),
    new Point(-0.6, 1610721000000),
    new Point(-0.55, 1611066600000),
    new Point(0.12, 1611153000000),
    new Point(0.7, 1611239400000),
    new Point(1.22, 1611325800000),
    new Point(1.9, 1611585000000),
    new Point(2.63, 1611671400000),
    new Point(3.22, 1611757800000),
    new Point(4.13, 1611844200000),
    new Point(4.24, 1611930600000),
    new Point(4.89, 1612189800000),
    new Point(5.33, 1612276200000),
    new Point(5.89, 1612362600000),
    new Point(6.19, 1612449000000),
    new Point(6.36, 1612535400000),
    new Point(6.45, 1612794600000),
    new Point(6.55, 1612881000000),
    new Point(6.48, 1612967400000),
    new Point(6.48, 1613053800000),
    new Point(6.45, 1613140200000),
    new Point(6.25, 1613485800000),
    new Point(6.06, 1613572200000),
    new Point(5.81, 1613658600000),
    new Point(5.32, 1613745000000),
    new Point(4.36, 1614004200000),
    new Point(3.46, 1614090600000),
    new Point(2.82, 1614177000000),
    new Point(1.84, 1614263400000),
    new Point(1.33, 1614349800000),
    new Point(1.27, 1614609000000),
    new Point(0.97, 1614695400000),
    new Point(0.21, 1614781800000),
    new Point(-0.44, 1614868200000),
    new Point(-0.57, 1614954600000),
    new Point(-0.99, 1615213800000),
    new Point(-0.8, 1615300200000),
    new Point(-0.76, 1615386600000),
    new Point(-0.33, 1615473000000),
    new Point(-0.11, 1615559400000),
    new Point(-0.01, 1615815000000),
    new Point(0.3, 1615901400000),
    new Point(0.49, 1615987800000),
    new Point(0.13, 1616074200000),
    new Point(-0.19, 1616160600000)
    ];

    expect(actualMACDValues.length, expectedMACDValues.length);

    /// Expect equal approximate content
    for (int i = 0 ; i < actualMACDValues.length ; ++i) {
      /// Round actual values to 2 decimal places doubles (for comparison)
      double roundedPointValue = double.parse(actualMACDValues[i].value.toStringAsFixed(2));

      expect(roundedPointValue, expectedMACDValues[i].value);
      expect(actualMACDValues[i].timestamp, expectedMACDValues[i].timestamp);
    }
  });
}
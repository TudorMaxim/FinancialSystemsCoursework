import 'dart:convert';

import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/EMA.dart';
import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  List<Stock> stocks;
  EMA ema;

  setUp(() async {
    String stocksJSON = await StockDataCollector().getPricesAsJSON(
        "MSFT", "1569853800", "1616337000");

    /// Get list of stocks to compute EMA
    stocks = Stock.jsonToStocks("MSFT", jsonDecode(stocksJSON));

    ema = new EMA();
  });

  test("EMA test", () async {
    List<Point> actualEMAValues = ema.compute(stocks, 50, 318);

    List<Point> expectedEMAValuesFor50P = [
    new Point(216.29, 1609770600000),
    new Point(216.35, 1609857000000),
    new Point(216.19, 1609943400000),
    new Point(216.27, 1610029800000),
    new Point(216.4, 1610116200000),
    new Point(216.45, 1610375400000),
    new Point(216.39, 1610461800000),
    new Point(216.39, 1610548200000),
    new Point(216.25, 1610634600000),
    new Point(216.11, 1610721000000),
    new Point(216.13, 1611066600000),
    new Point(216.45, 1611153000000),
    new Point(216.78, 1611239400000),
    new Point(217.14, 1611325800000),
    new Point(217.63, 1611585000000),
    new Point(218.2, 1611671400000),
    new Point(218.78, 1611757800000),
    new Point(219.57, 1611844200000),
    new Point(220.06, 1611930600000),
    new Point(220.82, 1612189800000),
    new Point(221.56, 1612276200000),
    new Point(222.4, 1612362600000),
    new Point(223.17, 1612449000000),
    new Point(223.91, 1612535400000),
    new Point(224.64, 1612794600000),
    new Point(225.39, 1612881000000),
    new Point(226.07, 1612967400000),
    new Point(226.8, 1613053800000),
    new Point(227.51, 1613140200000),
    new Point(228.15, 1613485800000),
    new Point(228.77, 1613572200000),
    new Point(229.36, 1613658600000),
    new Point(229.82, 1613745000000),
    new Point(230.0, 1614004200000),
    new Point(230.13, 1614090600000),
    new Point(230.3, 1614177000000),
    new Point(230.25, 1614263400000),
    new Point(230.34, 1614349800000),
    new Point(230.6, 1614609000000),
    new Point(230.72, 1614695400000),
    new Point(230.6, 1614781800000),
    new Point(230.45, 1614868200000),
    new Point(230.49, 1614954600000),
    new Point(230.37, 1615213800000),
    new Point(230.5, 1615300200000),
    new Point(230.58, 1615386600000),
    new Point(230.84, 1615473000000),
    new Point(231.03, 1615559400000),
    new Point(231.18, 1615815000000),
    new Point(231.43, 1615901400000),
    new Point(231.65, 1615987800000),
    new Point(231.62, 1616074200000),
    new Point(231.57, 1616160600000)
    ];

    debugPrint(actualEMAValues.toString());

    /// Expect actual points have same length as expected points
    expect(actualEMAValues.length, expectedEMAValuesFor50P.length);

    /// Expect equal approximate content
    for (int i = 0 ; i < actualEMAValues.length ; ++i) {
      /// Round actual values to 2 decimal places doubles (for comparison)
      double roundedPointValue = double.parse(actualEMAValues[i].value.toStringAsFixed(2));

      expect(roundedPointValue, expectedEMAValuesFor50P[i].value);
      expect(actualEMAValues[i].timestamp, expectedEMAValuesFor50P[i].timestamp);
    }
  });

  test("EMA test with period = 12d", () async {
    List<Point> actualEMAValues = ema.compute(stocks, 12, 318);


    // expected EMA values for 12d period have been taken from here: https://www.bullkhan.com/nasdaq/stock/MSFT
    List<Point> expectedEMAValuesFor12P = [
      new Point(234.41, 1615901400000),
      new Point(234.82, 1615987800000),
      new Point(234.19, 1616074200000),
      new Point(233.6, 1616160600000),
    ];

    debugPrint(actualEMAValues.toString());

    for (int i = 0 ; i < expectedEMAValuesFor12P.length ; ++i) {
      /// Round actual values to 2 decimal places doubles (for comparison)
      int expectedEMAIndex = actualEMAValues.length - expectedEMAValuesFor12P.length + i;
      double roundedPointValue = double.parse(actualEMAValues[expectedEMAIndex].value.toStringAsFixed(2));

      expect(roundedPointValue, expectedEMAValuesFor12P[i].value);
      expect(actualEMAValues[expectedEMAIndex].timestamp, expectedEMAValuesFor12P[i].timestamp);
    }
  });

  test("EMA test with period = 35d", () async {
    List<Point> actualEMAValues = ema.compute(stocks, 35, 318);


    // expected EMA values for 35d period have been taken from here: https://www.bullkhan.com/nasdaq/stock/MSFT
    List<Point> expectedEMAValuesFor35P = [
      new Point(233.28, 1615901400000),
      new Point(233.49, 1615987800000),
      new Point(233.33, 1616074200000),
      new Point(233.17, 1616160600000),
    ];


    for (int i = 0 ; i < expectedEMAValuesFor35P.length ; ++i) {
      /// Round actual values to 2 decimal places doubles (for comparison)
      int expectedEMAIndex = actualEMAValues.length - expectedEMAValuesFor35P.length + i;
      double roundedPointValue = double.parse(actualEMAValues[expectedEMAIndex].value.toStringAsFixed(2));

      expect(roundedPointValue, expectedEMAValuesFor35P[i].value);
      expect(actualEMAValues[expectedEMAIndex].timestamp, expectedEMAValuesFor35P[i].timestamp);
    }
  });
}
import 'dart:convert';

import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/EMA.dart';
import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  List<Stock> stocks;
  EMA ema;

  setUp(() async {
    String stocksJSON = await StockDataCollector().getPricesAsJSON(
        "MSFT", "1609459200", "1614556800");

    /// Get list of stocks to compute EMA
    stocks = Stock.jsonToStocks("MSFT", jsonDecode(stocksJSON));

    ema = new EMA();
  });

  test("EMA test", () async {
    List<Point> actualEMAValues = ema.compute(stocks, 50, 65);

    List<Point> expectedEMAValuesFor50P = [
      new Point(216.40, 1609770600000),
      new Point(216.46, 1609857000000),
      new Point(216.30, 1609943400000),
      new Point(216.37, 1610029800000),
      new Point(216.50, 1610116200000),
      new Point(216.54, 1610375400000),
      new Point(216.48, 1610461800000),
      new Point(216.47, 1610548200000),
      new Point(216.34, 1610634600000),
      new Point(216.19, 1610721000000),
      new Point(216.20, 1611066600000),
      new Point(216.52, 1611153000000),
      new Point(216.85, 1611239400000),
      new Point(217.21, 1611325800000),
      new Point(217.69, 1611585000000),
      new Point(218.27, 1611671400000),
      new Point(218.84, 1611757800000),
      new Point(219.63, 1611844200000),
      new Point(220.11, 1611930600000),
      new Point(220.88, 1612189800000),
      new Point(221.61, 1612276200000),
      new Point(222.45, 1612362600000),
      new Point(223.21, 1612449000000),
      new Point(223.96, 1612535400000),
      new Point(224.68, 1612794600000),
      new Point(225.43, 1612881000000),
      new Point(226.12, 1612967400000),
      new Point(226.84, 1613053800000),
      new Point(227.55, 1613140200000),
      new Point(228.18, 1613485800000),
      new Point(228.81, 1613572200000),
      new Point(229.40, 1613658600000),
      new Point(229.85, 1613745000000),
      new Point(230.03, 1614004200000),
      new Point(230.16, 1614090600000),
      new Point(230.33, 1614177000000),
      new Point(230.28, 1614263400000),
      new Point(230.36, 1614349800000),
      new Point(230.62, 1614609000000),
      new Point(230.75, 1614695400000),
      new Point(230.62, 1614781800000),
      new Point(230.47, 1614868200000),
      new Point(230.51, 1614954600000),
      new Point(230.39, 1615213800000),
      new Point(230.52, 1615300200000),
      new Point(230.60, 1615386600000),
      new Point(230.86, 1615473000000),
      new Point(231.05, 1615559400000),
      new Point(231.19, 1615815000000),
      new Point(231.45, 1615901400000),
      new Point(231.67, 1615987800000),
      new Point(231.63, 1616074200000),
      new Point(231.58, 1616160600000)
    ];

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
    List<Point> actualEMAValues = ema.compute(stocks, 12, 37);


    // expected EMA values for 12d period have been taken from here: https://www.bullkhan.com/nasdaq/stock/MSFT
    List<Point> expectedEMAValuesFor12P = [
      new Point(234.41, 1615901400000),
      new Point(234.82, 1615987800000),
      new Point(234.19, 1616074200000),
      new Point(233.6, 1616160600000),
    ];


    for (int i = 0 ; i < expectedEMAValuesFor12P.length ; ++i) {
      /// Round actual values to 2 decimal places doubles (for comparison)
      int expectedSMAIndex = actualEMAValues.length - expectedEMAValuesFor12P.length + i;
      double roundedPointValue = double.parse(actualEMAValues[expectedSMAIndex].value.toStringAsFixed(2));

      expect(roundedPointValue, expectedEMAValuesFor12P[i].value);
      expect(actualEMAValues[i].timestamp, expectedEMAValuesFor12P[i].timestamp);
    }
  });

  test("EMA test with period = 35d", () async {
    List<Point> actualEMAValues = ema.compute(stocks, 35, 54);


    // expected EMA values for 35d period have been taken from here: https://www.bullkhan.com/nasdaq/stock/MSFT
    List<Point> expectedEMAValuesFor35P = [
      new Point(233.28, 1615901400000),
      new Point(233.49, 1615987800000),
      new Point(233.34, 1616074200000),
      new Point(233.17, 1616160600000),
    ];


    for (int i = 0 ; i < expectedEMAValuesFor35P.length ; ++i) {
      /// Round actual values to 2 decimal places doubles (for comparison)
      int expectedSMAIndex = actualEMAValues.length - expectedEMAValuesFor35P.length + i;
      double roundedPointValue = double.parse(actualEMAValues[expectedSMAIndex].value.toStringAsFixed(2));

      expect(roundedPointValue, expectedEMAValuesFor35P[i].value);
      expect(actualEMAValues[i].timestamp, expectedEMAValuesFor35P[i].timestamp);
    }
  });
}
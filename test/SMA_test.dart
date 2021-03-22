import 'dart:convert';

import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/SMA.dart';
import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  List<Stock> stocks;
  SMA sma;

  setUp(() async {
    String stocksJSON = await StockDataCollector().getPricesAsJSON(
        "MSFT", "1569853800", "1616429153");

    /// Get list of stocks to compute SMA
    stocks = Stock.jsonToStocks("MSFT", jsonDecode(stocksJSON));

    sma = new SMA();
  });

  test("SMA test", () async {
    List<Point> actualSMAValues = sma.compute(stocks, 50, 318);

    List<Point> expectedSMAValuesFor50P = [
      new Point(215.14, 1609425000000),
      new Point(215.20,1609770600000),
      new Point(215.26,1609857000000),
      new Point(215.18,1609943400000),
      new Point(215.34,1610029800000),
      new Point(215.47,1610116200000),
      new Point(215.77,1610375400000),
      new Point(215.97,1610461800000),
      new Point(216.25,1610548200000),
      new Point(216.46,1610634600000),
      new Point(216.59,1610721000000),
      new Point(216.59,1611066600000),
      new Point(216.61,1611153000000),
      new Point(216.63,1611239400000),
      new Point(216.79,1611325800000),
      new Point(217.16,1611585000000),
      new Point(217.47,1611671400000),
      new Point(217.82,1611757800000),
      new Point(218.27,1611844200000),
      new Point(218.56,1611930600000),
      new Point(219.07,1612189800000),
      new Point(219.64,1612276200000),
      new Point(220.25,1612362600000),
      new Point(220.88,1612449000000),
      new Point(221.52,1612535400000),
      new Point(222.09,1612794600000),
      new Point(222.69,1612881000000),
      new Point(223.24,1612967400000),
      new Point(223.85,1613053800000),
      new Point(224.43,1613140200000),
      new Point(224.99,1613485800000),
      new Point(225.59,1613572200000),
      new Point(226.18,1613658600000),
      new Point(226.72,1613745000000),
      new Point(227.09,1614004200000),
      new Point(227.52,1614090600000),
      new Point(228.00,1614177000000),
      new Point(228.31,1614263400000),
      new Point(228.67,1614349800000),
      new Point(229.13,1614609000000),
      new Point(229.42,1614695400000),
      new Point(229.59,1614781800000),
      new Point(229.75,1614868200000),
      new Point(229.93,1614954600000),
      new Point(230.00,1615213800000),
      new Point(230.25,1615300200000),
      new Point(230.45,1615386600000),
      new Point(230.69,1615473000000),
      new Point(230.92,1615559400000),
      new Point(231.18,1615815000000),
      new Point(231.49,1615901400000),
      new Point(231.88,1615987800000),
      new Point(232.13,1616074200000),
      new Point(232.50,1616160600000)
    ];

    /// Expect actual points have same length as expected points
    expect(actualSMAValues.length, expectedSMAValuesFor50P.length);

    /// Expect equal approximate content
    for (int i = 0 ; i < actualSMAValues.length ; ++i) {
      /// Round actual values to 2 decimal places doubles (for comparison)
      double roundedPointValue = double.parse(actualSMAValues[i].value.toStringAsFixed(2));

      expect(roundedPointValue, expectedSMAValuesFor50P[i].value);
      expect(actualSMAValues[i].timestamp, expectedSMAValuesFor50P[i].timestamp);
    }
  });

  test("SMA test with period = 12d", () async {
    List<Point> actualSMAValues = sma.compute(stocks, 12, 318);


    /// expected SMA values for 12d period have been taken from here: https://www.bullkhan.com/nasdaq/stock/MSFT
    List<Point> expectedSMAValuesFor12P = [
      new Point(232.53, 1609425000000),
      new Point(232.97, 1609770600000),
      new Point(232.98, 1609857000000),
      new Point(232.72, 1609943400000),
    ];


    for (int i = 0 ; i < expectedSMAValuesFor12P.length ; ++i) {
      /// Round actual values to 2 decimal places doubles (for comparison)
      int expectedSMAIndex = actualSMAValues.length - expectedSMAValuesFor12P.length + i - 1;
      double roundedPointValue = double.parse(actualSMAValues[expectedSMAIndex].value.toStringAsFixed(2));

      expect(roundedPointValue, expectedSMAValuesFor12P[i].value);
      expect(actualSMAValues[i].timestamp, expectedSMAValuesFor12P[i].timestamp);
    }
  });

  test("SMA test with period = 35d", () async {
    List<Point> actualSMAValues = sma.compute(stocks, 35, 318);


    /// expected SMA values for 35d period have been taken from here: https://www.bullkhan.com/nasdaq/stock/MSFT
    List<Point> expectedSMAValuesFor35P = [
      new Point(236.71, 1609425000000),
      new Point(236.95, 1609770600000),
      new Point(237.08, 1609857000000),
      new Point(237.02, 1609943400000),
    ];


    for (int i = 0 ; i < expectedSMAValuesFor35P.length ; ++i) {
      /// Round actual values to 2 decimal places doubles (for comparison)
      int expectedSMAIndex = actualSMAValues.length - expectedSMAValuesFor35P.length + i - 1;
      double roundedPointValue = double.parse(actualSMAValues[expectedSMAIndex].value.toStringAsFixed(2));

      expect(roundedPointValue, expectedSMAValuesFor35P[i].value);
      expect(actualSMAValues[i].timestamp, expectedSMAValuesFor35P[i].timestamp);
    }
  });
}
import 'dart:convert';
import 'dart:math';

import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/MACDAVG.dart';
import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test("MACDAVG test",() async {

    /// Get JSON response from 1th January 2020 to 1th March 2021 (2 month data)
    /// Actual data returned is from 4th January 2021 to 26th February 2021
    ///
    /// Total: 38 market days of stock prices
    String stocksJSON = await StockDataCollector().getPricesAsJSON(
        "MSFT", "1609459200", "1614556800");

    /// Get list of stocks to compute MACDAVG
    List<Stock> stocks = Stock.jsonToStocks("MSFT", jsonDecode(stocksJSON));

    MACDAVG macdavg = new MACDAVG();
    /// Compute MACDAVG for the given stocks
    List<Point> actualPoints = macdavg.compute(stocks, 0, 0);

    /// Craft expected answer
    /// From 4th of January
    /// To 26th of February
    ///
    ///
    /// Note that timestamps are for the closing hours of the day: NYSE (14:30)
    /// Values taken are approximated with two decimal places to the right.
    List<Point> expectedPoints = [
      new Point(0.0,1609770600000),
      new Point(0.01,1609857000000),
      new Point(-0.34,1609943400000),
      new Point(-0.16,1610029800000),
      new Point(0.05,1610116200000),
      new Point(0.05,1610375400000),
      new Point(-0.12,1610461800000),
      new Point(-0.13,1610548200000),
      new Point(-0.34,1610634600000),
      new Point(-0.48,1610721000000),
      new Point(-0.29,1611066600000),
      new Point(0.35,1611153000000),
      new Point(0.78,1611239400000),
      new Point(1.07,1611325800000),
      new Point(1.42,1611585000000),
      new Point(1.74,1611671400000),
      new Point(1.88,1611757800000),
      new Point(2.24,1611844200000),
      new Point(1.89,1611930600000),
      new Point(2.03,1612189800000),
      new Point(1.99,1612276200000),
      new Point(2.04,1612362600000),
      new Point(1.87,1612449000000),
      new Point(1.64,1612535400000),
      new Point(1.38,1612794600000),
      new Point(1.18,1612881000000),
      new Point(0.89,1612967400000),
      new Point(0.71,1613053800000),
      new Point(0.54,1613140200000),
      new Point(0.27,1613485800000),
      new Point(0.06,1613572200000),
      new Point(-0.15,1613658600000),
      new Point(-0.51,1613745000000),
      new Point(-1.18,1614004200000),
      new Point(-1.67,1614090600000),
      new Point(-1.85,1614177000000),
      new Point(-2.26,1614263400000),
      new Point(-2.23,1614349800000)
    ];

    /// Expect actual points have same length as expected points
    expect(actualPoints.length, expectedPoints.length);

    /// Expect equal approximate content
    for (int i = 0 ; i < actualPoints.length ; ++i) {
      /// Round actual values to 2 decimal places doubles (for comparison)
      double roundedPointValue = double.parse(actualPoints[i].value.toStringAsFixed(2));

      expect(roundedPointValue, expectedPoints[i].value);
      expect(actualPoints[i].timestamp, expectedPoints[i].timestamp);
    }

  });
}
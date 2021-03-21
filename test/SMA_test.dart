import 'dart:convert';

import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/SMA.dart';
import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("SMA test", () async {

    String stocksJSON = await StockDataCollector().getPricesAsJSON(
        "MSFT", "1609459200", "1614556800");

    /// Get list of stocks to compute SMA
    List<Stock> stocks = Stock.jsonToStocks("MSFT", jsonDecode(stocksJSON));

    SMA sma = new SMA();

    List<Point> actualSMAValues = sma.compute(stocks, 50, 65);

    List<Point> expectedSMAValuesFor50P = [
      new Point(215.20, 1609770600000),
    ];

    expect(actualSMAValues[0].value, expectedSMAValuesFor50P[0].value);
  });
}
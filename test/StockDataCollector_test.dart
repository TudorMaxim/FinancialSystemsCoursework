import 'dart:convert';

import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:financial_systems_coursework/repository/StockDataCollector.dart';

void main() {
  /// Test createURL
  test("Craft URL correctly", () {
    String expected =
        "https://query1.finance.yahoo.com/v8/finance/chart/AAPL?symbol=AAPL&period1=1612437713&period2=1614856913&interval=1d";
    String actual = new StockDataCollector()
        .createURL("AAPL", "1612437713", "1614856913")
        .toString();

    expect(actual, expected);
  });

  /// Test getPricesAsJSON
  test("Check JSON response from web", () async {
    final response = await http.get(
      new StockDataCollector().createURL("AAPL", "1612437713", "1614856913"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    /// Expect 200 OK result
    expect(response.statusCode, 200);

    /// Get actual data from StockDataCollector
    String actual = response.body;
    List<Stock> actualStocks = Stock.jsonToStocks("AAPL", jsonDecode(actual));

    /// Craft expected
    String expected = await new StockDataCollector()
        .getPricesAsJSON("AAPL", "1612437713", "1614856913");
    List<Stock> expectedStocks =
        Stock.jsonToStocks("AAPL", jsonDecode(expected));

    /// Check that stock lists have the same sizes
    expect(actualStocks.length, expectedStocks.length);

    /// Check for equality
    for (int i = 0; i < actualStocks.length; ++i) {
      expect(actualStocks[i].ticker, expectedStocks[i].ticker);
      expect(actualStocks[i].timestamp, expectedStocks[i].timestamp);
      expect(actualStocks[i].currentMarketPrice,
          expectedStocks[i].currentMarketPrice);
    }
  });
}

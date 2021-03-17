import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:financial_systems_coursework/model/Stock.dart';

void main() {

  /// Test createURL
  test("Craft URL correctly", (){
    String expected = "https://query1.finance.yahoo.com/v8/finance/chart/AAPL?symbol=AAPL&period1=1612437713&period2=1614856913&interval=1d";
    String actual = new StockDataCollector().createURL("AAPL", "1612437713", "1614856913", "1d");

    expect(actual, expected);
  });

  /// Test jsonToStocks
  test("Get correct results from JSON parsing", () async {
    /// Perform data fetch
    final response = await http.get(
      new StockDataCollector().createURL("AAPL", "1612437713", "1614856913", "1d"),
      headers: <String, String> {
        'Content-Type': 'application/json',
      },
    );

    /// Expect 200 OK result
    expect(response.statusCode, 200);

    /// Expect equal content
    List<Stock> actual = new StockDataCollector().jsonToStocks("AAPL", jsonDecode(response.body));

    /// Craft expected content
    List<int> timestamps = [
      1612449000000, 1612535400000, 1612794600000, 1612881000000,
      1612967400000, 1613053800000, 1613140200000, 1613485800000,
      1613572200000, 1613658600000, 1613745000000, 1614004200000,
      1614090600000, 1614177000000, 1614263400000, 1614349800000,
      1614609000000, 1614695400000, 1614781800000
    ];

    List<double> prices = [
      137.38999938964844, 136.75999450683594, 136.91000366210938, 136.00999450683594,
      135.38999938964844, 135.1300048828125, 135.3699951171875, 133.19000244140625,
      130.83999633789062, 129.7100067138672, 129.8699951171875, 126,
      125.86000061035156, 125.3499984741211, 120.98999786376953, 121.26000213623047,
      127.79000091552734, 125.12000274658203, 122.05999755859375
    ];

    List<Stock> expected = List.empty(growable: true);

    for (int i = 0 ; i < timestamps.length; ++i) {
      expected.add(new Stock("AAPL", timestamps[i], prices[i]));
    }

    /// Test for content equality
    for (int i = 0 ; i < expected.length; ++i) {
      expect(actual[i].symbol, expected[i].symbol);
      expect(actual[i].timestamp, expected[i].timestamp);
      expect(actual[i].currentMarketPrice, expected[i].currentMarketPrice);
    }
  });

  /// Test getPrices method which integrates the above two tested methods
  test("Get correct prices", () async {
    List<Stock> actual = await new StockDataCollector().getPrices("AAPL", "1612437713", "1614856913", "1d");

    /// Instantiate oracle data for expected content
    List<int> timestamps = [
      1612449000000, 1612535400000, 1612794600000, 1612881000000,
      1612967400000, 1613053800000, 1613140200000, 1613485800000,
      1613572200000, 1613658600000, 1613745000000, 1614004200000,
      1614090600000, 1614177000000, 1614263400000, 1614349800000,
      1614609000000, 1614695400000, 1614781800000
    ];

    List<double> prices = [
      137.38999938964844, 136.75999450683594, 136.91000366210938, 136.00999450683594,
      135.38999938964844, 135.1300048828125, 135.3699951171875, 133.19000244140625,
      130.83999633789062, 129.7100067138672, 129.8699951171875, 126,
      125.86000061035156, 125.3499984741211, 120.98999786376953, 121.26000213623047,
      127.79000091552734, 125.12000274658203, 122.05999755859375
    ];

    /// Create expected content
    List<Stock> expected = List.empty(growable: true);

    for (int i = 0 ; i < timestamps.length; ++i) {
      expected.add(new Stock("AAPL", timestamps[i], prices[i]));
    }

    /// Test length of actual stock list is equal to the lenght of expected stock list
    expect(actual.length, expected.length);

    /// Test stock contents for equality
    for (int i = 0 ; i < expected.length; ++i) {
      expect(actual[i].symbol, expected[i].symbol);
      expect(actual[i].timestamp, expected[i].timestamp);
      expect(actual[i].currentMarketPrice, expected[i].currentMarketPrice);
    }
  });

  /// Test getPrices in case the input is invalid
  test("Get null if request parameters are not correct", () async {
    List<Stock> actual_1 = await new StockDataCollector().getPrices("LPAAA123123", "1612437713", "1614856913", "1d");
    expect(actual_1, null);
    List<Stock> actual_2 = await new StockDataCollector().getPrices("AAPL", "-3", "-213", "1d");
    expect(actual_2, null);
    List<Stock> actual_3 = await new StockDataCollector().getPrices("AAPL", "1612437713", "1614856913", "112323133d");
    expect(actual_3, null);
  });
}
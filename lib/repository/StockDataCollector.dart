import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class StockDataCollector {
  static final StockDataCollector _instance = StockDataCollector._internal();

  @visibleForTesting
  static http.Client client = new http.Client();

  static final _authority = 'query1.finance.yahoo.com';
  static final _unencodedPath = '/v8/finance/chart/';
  factory StockDataCollector() {
    return _instance;
  }

  StockDataCollector._internal();

  @visibleForTesting
  Uri createURL(String ticker, String startDate, String endDate) {
    return Uri.https(_authority, _unencodedPath + ticker, {
      'symbol': ticker,
      'period1': startDate,
      'period2': endDate,
      'interval': '1d'
    });
  }

  /// ticker: company stock ticker
  /// startDate: timestamp as string
  /// endDate: timestamp as string
  ///
  /// Data sampled once a day, closing price
  ///
  /// Example of function call:
  ///    StockDataCollector.getPrices('AAPL', '1612437713', '1614856913');
  /// Corresponding URL:
  ///    https://query1.finance.yahoo.com/v8/finance/chart/AAPL?symbol=AAPL&period1=1612437713&period2=1614856913&interval=1d
  Future<String> getPricesAsJSON(
      String ticker, String startDate, String endDate) async {
    final response = await client.get(
      createURL(ticker, startDate, endDate),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }
}

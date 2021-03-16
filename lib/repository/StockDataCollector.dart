import 'dart:convert';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:http/http.dart' as http;

class StockDataCollector {
  static StockDataCollector _instance;

  StockDataCollector._internal();

  static StockDataCollector getInstance() {
    if (_instance == null) {
      _instance = StockDataCollector._internal();
    }

    return _instance;
  }

  String _createURL(
      String symbol, String startDate, String endDate, String interval) {
    return "https://query1.finance.yahoo.com/v8/finance/chart/" +
        symbol +
        "?symbol=" +
        symbol +
        "&period1=" +
        startDate +
        "&period2=" +
        endDate +
        "&interval=" +
        interval;
  }

  /**
   * symbol: company stock symbol
   * startDate: timestamp as string
   * endDate: timestamp as string
   *
   * Data sampled once a day, closing price
   *
   * Example of function call:
   *    StockDataCollector.getPrices("AAPL", "1612437713", "1614856913");
   * Corresponding URL:
   *    https://query1.finance.yahoo.com/v8/finance/chart/AAPL?symbol=AAPL&period1=1612437713&period2=1614856913&interval=1d
   */
  Future<List<Stock>> getPrices(
      String symbol, String startDate, String endDate, String interval) async {
    final response = await http.get(
      _createURL(symbol, startDate, endDate, interval),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return Stock.jsonToStocks(symbol, jsonResponse);
    } else {
      return null;
    }
  }
}

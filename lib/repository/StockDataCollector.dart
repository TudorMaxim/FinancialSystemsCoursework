import 'dart:convert';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:flutter/material.dart';
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

  /// Craft URL
  String _createURL(String symbol, String startDate, String endDate) {
    return "https://query1.finance.yahoo.com/v8/finance/chart/" + symbol +
        "?symbol=" + symbol +
        "&period1=" + startDate +
        "&period2=" + endDate +
        "&interval=1d";
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
  Future<List<Stock>> getPrices(String symbol, String startDate, String endDate) async {
    final response = await http.get(
      _createURL(symbol, startDate, endDate),
      headers: <String, String> {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return _jsonToStocks(symbol, jsonResponse);

    } else {
      return null;
    }

  }

  /**
   * Create stock objects from collected data.
   *
   * Take closing price of each day.
   */
  List<Stock> _jsonToStocks(String symbol, dynamic jsonObject) {

    List<int> timestamps = (jsonObject['chart']['result'][0]['timestamp'] as List).cast<int>().toList();
    List<double> prices = (jsonObject['chart']['result'][0]['indicators']['quote'][0]['close'] as List).cast<double>().toList();

    List<Stock> stockList = List.empty(growable: true);

    for (int i = 0 ; i < timestamps.length; ++i) {
      stockList.add(new Stock(symbol, timestamps[i], prices[i]));
    }

    return stockList;
  }

}
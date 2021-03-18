import 'dart:convert';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/repository/DBManager.dart';
import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:financial_systems_coursework/shared/interval.dart';

class StockDataProvider {
  static final StockDataProvider _instance = StockDataProvider._internal();

  StockDataProvider._internal();

  factory StockDataProvider() {
    return _instance;
  }

  Future<List<Stock>> getPrices(
      String ticker, int from, int to) async {
    List<Stock> _fromDB =
        await DBManager().getFromDBOrNull(ticker, from, to);
    if (_fromDB == null) {
      String stocksJSON = await StockDataCollector().getPricesAsJSON(
          ticker, from.toString(), to.toString());
      await DBManager().refreshCache(ticker, from, to, stocksJSON);
      return Stock.jsonToStocks(ticker, jsonDecode(stocksJSON));
    } else {
      return _fromDB;
    }
  }
}

import 'dart:convert';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/repository/DBManager.dart';
import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:financial_systems_coursework/shared/interval.dart';

class StockDataProvider {
  Future<List<Stock>> getPrices(
      String ticker, int from, int to, StockInterval interval) async {
    List<Stock> _fromDB =
        await DBManager().getFromDBOrNull(ticker, from, to, interval);
    if (_fromDB == null) {
      String stocksJSON = await StockDataCollector().getPricesAsJSON(
          ticker, from.toString(), to.toString(), interval.name);
      await DBManager().refreshCache(ticker, from, to, interval, stocksJSON);
      return Stock.jsonToStocks(ticker, jsonDecode(stocksJSON));
    } else {
      return _fromDB;
    }
  }
}

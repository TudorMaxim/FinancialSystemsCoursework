import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';
import 'package:flutter/cupertino.dart';

class EMA implements Formulae {
  @override
  List<Point> compute(List<Stock> stocks, int period) {
    if (stocks.length < period) {
      throw new ErrorDescription("Period must be smalled than the number of stocks");
    }

    if (stocks.isEmpty) return [];

    //calculate multiplier for example 10 days would be 0.1818...
    double multiplier = 2 / (period + 1);
    List<Point> indicators = [
      Point(stocks.first.currentMarketPrice, stocks.first.timestamp),
    ];
    for (int i = 1; i < stocks.length; i++) {
      double currentEMA = ((stocks[i].currentMarketPrice - indicators[i - 1].value) * multiplier) + indicators[i - 1].value;
      indicators.add(Point(currentEMA, stocks[i].timestamp));
    }
    return indicators;
  }
}